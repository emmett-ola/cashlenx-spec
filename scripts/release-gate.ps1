param(
    [ValidateSet("all", "mongodb", "mysql")]
    [string]$Database = "all",
    [string]$JiraPreflightReference,
    [switch]$TechnicalOnly
)

$ErrorActionPreference = "Stop"
$specPath = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$workspacePath = (Resolve-Path (Join-Path $specPath "..")).Path
$bashPath = "C:\Program Files\Git\bin\bash.exe"
$version = (Get-Content -Raw -LiteralPath (Join-Path $specPath "release\VERSION")).Trim()
$runId = (Get-Date).ToUniversalTime().ToString("yyyyMMddTHHmmssZ") + "-" + ([Guid]::NewGuid().ToString("N").Substring(0, 8))
$gateRoot = Join-Path $specPath ".artifacts\release-gates\$runId"
$repositories = [ordered]@{
    app = [pscustomobject]@{ Name = "cashlenx-app"; Branch = "develop" }
    server = [pscustomobject]@{ Name = "cashlenx-server"; Branch = "develop" }
    website = [pscustomobject]@{ Name = "cashlenx-website"; Branch = "develop" }
    spec = [pscustomobject]@{ Name = "cashlenx-spec"; Branch = "main" }
}

function Assert-LastExit([string]$Operation) {
    if ($LASTEXITCODE -ne 0) { throw "$Operation failed with exit code $LASTEXITCODE." }
}

function Get-Sha256([string]$Path) {
    return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
}

function Invoke-Git([string]$Repository, [string[]]$Arguments) {
    $output = & git -C $Repository @Arguments 2>&1
    Assert-LastExit "git $($Arguments -join ' ') in $Repository"
    return ($output -join "`n").Trim()
}

function Get-RepositoryState([string]$Key) {
    $definition = $repositories[$Key]
    $path = Join-Path $workspacePath $definition.Name
    if (-not (Test-Path -LiteralPath (Join-Path $path ".git"))) { throw "Missing Git repository: $path" }
    if (Invoke-Git $path @("status", "--porcelain")) { throw "$($definition.Name) must be clean before the release gate." }
    $branch = Invoke-Git $path @("branch", "--show-current")
    if ($branch -ne $definition.Branch) { throw "$($definition.Name) is on $branch; expected $($definition.Branch)." }
    $upstream = Invoke-Git $path @("rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{upstream}")
    $counts = (Invoke-Git $path @("rev-list", "--left-right", "--count", "HEAD...$upstream")) -split '\s+'
    if ($counts.Count -ne 2 -or $counts[0] -ne "0" -or $counts[1] -ne "0") {
        throw "$($definition.Name) must be synchronized with $upstream before the release gate."
    }
    return [ordered]@{
        name = $definition.Name
        path = $path
        branch = $branch
        upstream = $upstream
        commit = Invoke-Git $path @("rev-parse", "HEAD")
        tree = Invoke-Git $path @("rev-parse", "HEAD^{tree}")
    }
}

function Get-EnvironmentValue([string]$Path, [string]$Key) {
    foreach ($line in Get-Content -LiteralPath $Path) {
        if ($line -match ('^' + [regex]::Escape($Key) + '=(.+)$')) { return $Matches[1].Trim() }
    }
    throw "Missing $Key in $Path."
}

function Invoke-ContainerValidation(
    [string]$Label,
    [string]$RepositoryPath,
    [string]$Image,
    [string]$Shell,
    [string]$Command,
    [string[]]$AdditionalArguments = @()
) {
    & docker run --rm --volume "${RepositoryPath}:/workspace" --workdir /workspace @AdditionalArguments $Image $Shell -lc $Command
    Assert-LastExit $Label
}

if (-not (Test-Path -LiteralPath $bashPath -PathType Leaf)) { throw "Git Bash is required at $bashPath." }
if (-not $TechnicalOnly -and [string]::IsNullOrWhiteSpace($JiraPreflightReference)) {
    throw "JiraPreflightReference is required unless TechnicalOnly is selected."
}
if ($TechnicalOnly -and -not [string]::IsNullOrWhiteSpace($JiraPreflightReference)) {
    throw "Do not supply JiraPreflightReference with TechnicalOnly."
}
& docker version *> $null
Assert-LastExit "Docker availability check"

$states = [ordered]@{}
foreach ($key in $repositories.Keys) { $states[$key] = Get-RepositoryState $key }
New-Item -ItemType Directory -Path $gateRoot -Force | Out-Null

$appImages = Join-Path $states.app.path "docker\images.env"
$serverImages = Join-Path $states.server.path "docker\images.env"
$websiteImages = Join-Path $states.website.path "docker\images.env"

$appValidation = @{
    Label = "App analysis and tests"
    RepositoryPath = $states.app.path
    Image = Get-EnvironmentValue $appImages "FLUTTER_BUILD_IMAGE"
    Shell = "bash"
    Command = 'flutter pub get --enforce-lockfile && flutter --version --machine | grep -F ''"frameworkVersion": "3.44.0"'' >/dev/null && dart --version 2>&1 | grep -F "Dart SDK version: 3.12.0" >/dev/null && flutter analyze && flutter test'
}
Invoke-ContainerValidation @appValidation

$serverValidation = @{
    Label = "Server build and tests"
    RepositoryPath = $states.server.path
    Image = Get-EnvironmentValue $serverImages "GO_BUILD_IMAGE"
    Shell = "sh"
    Command = 'go mod download && go mod verify && test "$(go env GOVERSION)" = "go1.23.12" && go build -mod=readonly ./... && go test -mod=readonly -race -covermode=atomic -coverprofile=/tmp/coverage.out ./...'
}
Invoke-ContainerValidation @serverValidation

$websiteValidation = @{
    Label = "Website audit and build"
    RepositoryPath = $states.website.path
    Image = Get-EnvironmentValue $websiteImages "BUN_BUILD_IMAGE"
    Shell = "sh"
    Command = 'test "$(bun --version)" = "1.4.0" && bun --no-env-file install --frozen-lockfile && scripts/audit-dependencies.sh && bun --no-env-file run build'
    AdditionalArguments = @("--mount", "type=volume,destination=/workspace/node_modules", "--tmpfs", "/workspace/dist")
}
Invoke-ContainerValidation @websiteValidation

$candidateRoot = Join-Path $gateRoot "release-candidate"
& (Join-Path $PSScriptRoot "release-candidate.ps1") -OutputRoot $candidateRoot
$candidateManifest = Get-ChildItem -LiteralPath $candidateRoot -Recurse -Filter "manifest.json" | Select-Object -ExpandProperty FullName -First 1
if (-not $candidateManifest) { throw "Release-candidate evidence manifest was not created." }

$rehearsalRoot = Join-Path $gateRoot "rehearsal"
& (Join-Path $PSScriptRoot "rehearsal.ps1") -Database $Database -OutputRoot $rehearsalRoot
$rehearsalManifest = Get-ChildItem -LiteralPath $rehearsalRoot -Recurse -Filter "manifest.json" | Select-Object -ExpandProperty FullName -First 1
if (-not $rehearsalManifest) { throw "Production-like rehearsal evidence manifest was not created." }

$browserRoot = Join-Path $gateRoot "browser"
$savedEvidenceRoot = [Environment]::GetEnvironmentVariable("EVIDENCE_ROOT", "Process")
[Environment]::SetEnvironmentVariable("EVIDENCE_ROOT", $browserRoot, "Process")
try {
    Push-Location $specPath
    & $bashPath -lc "scripts/whole-product-acceptance.sh"
    Assert-LastExit "Whole-product browser acceptance"
}
finally {
    Pop-Location
    [Environment]::SetEnvironmentVariable("EVIDENCE_ROOT", $savedEvidenceRoot, "Process")
}
$browserManifest = Get-ChildItem -LiteralPath $browserRoot -Recurse -Filter "manifest.txt" | Select-Object -ExpandProperty FullName -First 1
if (-not $browserManifest) { throw "Whole-product browser evidence manifest was not created." }

foreach ($key in $repositories.Keys) {
    $after = Get-RepositoryState $key
    if ($after.commit -ne $states[$key].commit -or $after.tree -ne $states[$key].tree) {
        throw "$($states[$key].name) changed while the release gate was running."
    }
}

$manifest = [ordered]@{
    schema_version = 1
    run_id = $runId
    result = if ($TechnicalOnly) { "technical-passed" } else { "passed" }
    release_ready = -not $TechnicalOnly
    version = $version
    completed_at = (Get-Date).ToUniversalTime().ToString("o")
    execution = [ordered]@{
        container_frontend = "docker"
        nerdctl = "contract compatibility only"
        database_profiles = $Database
    }
    repositories = [ordered]@{}
    validations = [ordered]@{
        jira_preflight = if ($TechnicalOnly) { "not recorded; release readiness not asserted" } else { "passed: $JiraPreflightReference" }
        repository_static_and_unit = "passed"
        reproducible_candidate = "passed"
        production_like_rehearsal = "passed"
        whole_product_browser = "passed"
    }
    evidence = [ordered]@{
        release_candidate = [ordered]@{ path = [IO.Path]::GetRelativePath($gateRoot, $candidateManifest); sha256 = Get-Sha256 $candidateManifest }
        rehearsal = [ordered]@{ path = [IO.Path]::GetRelativePath($gateRoot, $rehearsalManifest); sha256 = Get-Sha256 $rehearsalManifest }
        browser = [ordered]@{ path = [IO.Path]::GetRelativePath($gateRoot, $browserManifest); sha256 = Get-Sha256 $browserManifest }
    }
    migration_classification = "No database change is introduced by this release-gate orchestration."
    requested_delivery_actions = @()
    performed_delivery_actions = @()
    deployment_state = "Not deployed"
    secrets_recorded = $false
}
foreach ($key in $repositories.Keys) {
    $manifest.repositories[$key] = [ordered]@{
        branch = $states[$key].branch
        upstream = $states[$key].upstream
        commit = $states[$key].commit
        tree = $states[$key].tree
    }
}

$manifestPath = Join-Path $gateRoot "manifest.json"
$manifest | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $manifestPath -Encoding utf8NoBOM
$manifestHash = Get-Sha256 $manifestPath
Set-Content -LiteralPath "$manifestPath.sha256" -Value "$manifestHash  manifest.json" -Encoding ascii
Write-Output "Release gate passed: $manifestPath"
Write-Output "manifest_sha256=$manifestHash"
