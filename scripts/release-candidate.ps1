param(
    [string]$Version,
    [string]$OutputRoot,
    [string]$AppEnvironment,
    [string]$AppApiScheme,
    [string]$AppApiDomain,
    [string]$AppApiPort,
    [string]$AppApiVersion,
    [switch]$ValidateOnly,
    [switch]$KeepWorktrees
)

$ErrorActionPreference = "Stop"
$specPath = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$workspacePath = (Resolve-Path (Join-Path $specPath "..")).Path
$bashPath = "C:\Program Files\Git\bin\bash.exe"
$versionPath = Join-Path $specPath "release\VERSION"

if (-not $Version) { $Version = (Get-Content -Raw -LiteralPath $versionPath).Trim() }
if (-not $OutputRoot) { $OutputRoot = Join-Path $specPath ".artifacts\release-candidates" }

if ($Version -notmatch '^[0-9]+\.[0-9]+\.[0-9]+(?:-[0-9A-Za-z.-]+)?$') {
    throw "Version must be a semantic product version without build metadata."
}
$repositories = [ordered]@{
    app = [pscustomobject]@{ Name = "cashlenx-app"; Branch = "develop" }
    server = [pscustomobject]@{ Name = "cashlenx-server"; Branch = "develop" }
    website = [pscustomobject]@{ Name = "cashlenx-website"; Branch = "develop" }
    spec = [pscustomobject]@{ Name = "cashlenx-spec"; Branch = "main" }
}
$createdWorktrees = [System.Collections.Generic.List[object]]::new()

function Assert-LastExit([string]$Operation) {
    if ($LASTEXITCODE -ne 0) { throw "$Operation failed with exit code $LASTEXITCODE." }
}

function Invoke-Git([string]$Repository, [string[]]$Arguments) {
    $output = & git -C $Repository @Arguments 2>&1
    Assert-LastExit "git $($Arguments -join ' ') in $Repository"
    return ($output -join "`n").Trim()
}

function Invoke-GitBash([string]$WorkingDirectory, [string]$Script, [hashtable]$Environment = @{}) {
    $saved = @{}
    foreach ($entry in $Environment.GetEnumerator()) {
        $saved[$entry.Key] = [Environment]::GetEnvironmentVariable($entry.Key, "Process")
        [Environment]::SetEnvironmentVariable($entry.Key, [string]$entry.Value, "Process")
    }
    Push-Location $WorkingDirectory
    try {
        & $bashPath -lc $Script
        Assert-LastExit $Script
    }
    finally {
        Pop-Location
        foreach ($entry in $saved.GetEnumerator()) {
            [Environment]::SetEnvironmentVariable($entry.Key, $entry.Value, "Process")
        }
    }
}

function Get-Match([string]$Path, [string]$Pattern, [int]$Group = 1) {
    $content = Get-Content -Raw -LiteralPath $Path
    $match = [regex]::Match($content, $Pattern, [Text.RegularExpressions.RegexOptions]::Multiline)
    if (-not $match.Success) { throw "Could not resolve the version contract from $Path." }
    return $match.Groups[$Group].Value.Trim()
}

function Assert-Equal([string]$Actual, [string]$Expected, [string]$Label) {
    if ($Actual -ne $Expected) { throw "$Label is '$Actual'; expected '$Expected'." }
}

function Assert-ContainsVersion([string]$Path) {
    $content = Get-Content -Raw -LiteralPath $Path
    if ($content -notmatch [regex]::Escape("[$Version]")) {
        throw "$Path does not contain a changelog entry for $Version."
    }
}

function Get-Sha256([string]$Path) {
    return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
}

function Get-EnvValue([string]$Path, [string]$Key, [string]$Fallback) {
    $value = $null
    foreach ($line in Get-Content -LiteralPath $Path) {
        if ($line -match ('^\s*' + [regex]::Escape($Key) + '\s*=(.*)$')) {
            $value = $Matches[1].Trim()
            if ($value.Length -ge 2 -and (($value.StartsWith('"') -and $value.EndsWith('"')) -or ($value.StartsWith("'") -and $value.EndsWith("'")))) {
                $value = $value.Substring(1, $value.Length - 2)
            }
        }
    }
    if (-not $value) { return $Fallback }
    return $value
}

function Get-RepositoryState([string]$Key) {
    $repo = $repositories[$Key]
    $path = Join-Path $workspacePath $repo.Name
    if (-not (Test-Path -LiteralPath (Join-Path $path ".git"))) { throw "Missing Git repository: $path" }
    $status = Invoke-Git $path @("status", "--porcelain")
    if ($status) { throw "$($repo.Name) must be clean before release-candidate packaging." }
    $branch = Invoke-Git $path @("branch", "--show-current")
    Assert-Equal $branch $repo.Branch "$($repo.Name) branch"
    $upstream = Invoke-Git $path @("rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{upstream}")
    $counts = (Invoke-Git $path @("rev-list", "--left-right", "--count", "HEAD...$upstream")) -split '\s+'
    if ($counts.Count -ne 2 -or $counts[0] -ne "0" -or $counts[1] -ne "0") {
        throw "$($repo.Name) must be synchronized with $upstream before packaging."
    }
    $tag = Invoke-Git $path @("tag", "--list", "v$Version")
    if ($tag) { throw "Immutable tag v$Version already exists in $($repo.Name)." }
    return [pscustomobject]@{
        Key = $Key
        Name = $repo.Name
        Path = $path
        Branch = $branch
        Upstream = $upstream
        Commit = Invoke-Git $path @("rev-parse", "HEAD")
        Tree = Invoke-Git $path @("rev-parse", "HEAD^{tree}")
    }
}

function New-CleanWorktree([object]$State, [string]$Root) {
    $target = Join-Path $Root $State.Name
    New-Item -ItemType Directory -Path (Split-Path $target) -Force | Out-Null
    & git -C $State.Path worktree add --detach $target $State.Commit | Out-Host
    Assert-LastExit "Create $($State.Name) clean worktree"
    $createdWorktrees.Add([pscustomobject]@{ Source = $State.Path; Target = $target })
    return $target
}

function Invoke-PackagePass([hashtable]$Worktrees, [string]$PassRoot, [hashtable]$States) {
    foreach ($key in @("app", "server", "website")) {
        $output = Join-Path $PassRoot $key
        $environment = @{
            RELEASE_OUTPUT_DIR = $output
            PRODUCT_VERSION = $Version
            GIT_COMMIT = $States[$key].Commit
            ENV_FILE = ".env.example"
        }
        if ($key -eq "app") {
            $environment.APP_ENV = $AppEnvironment
            $environment.API_SCHEME = $AppApiScheme
            $environment.API_DOMAIN = $AppApiDomain
            $environment.API_PORT = $AppApiPort
            $environment.API_VERSION = $AppApiVersion
        }
        Invoke-GitBash $Worktrees[$key] 'scripts/package-image.sh "$RELEASE_OUTPUT_DIR"' $environment
    }
}

if (-not (Test-Path -LiteralPath $bashPath)) { throw "Git Bash is required at $bashPath." }

$states = @{}
foreach ($key in $repositories.Keys) { $states[$key] = Get-RepositoryState $key }

$appEnvironmentPath = Join-Path $states.app.Path ".env.example"
if (-not $PSBoundParameters.ContainsKey("AppEnvironment")) { $AppEnvironment = Get-EnvValue $appEnvironmentPath "APP_ENV" "dev" }
if (-not $PSBoundParameters.ContainsKey("AppApiScheme")) { $AppApiScheme = Get-EnvValue $appEnvironmentPath "API_SCHEME" "http" }
if (-not $PSBoundParameters.ContainsKey("AppApiDomain")) { $AppApiDomain = Get-EnvValue $appEnvironmentPath "API_DOMAIN" "127.0.0.1" }
if (-not $PSBoundParameters.ContainsKey("AppApiPort")) { $AppApiPort = Get-EnvValue $appEnvironmentPath "API_PORT" "10063" }
if (-not $PSBoundParameters.ContainsKey("AppApiVersion")) { $AppApiVersion = Get-EnvValue $appEnvironmentPath "API_VERSION" "api/v1" }
if ($AppEnvironment -notmatch '^(dev|staging|prod)$') { throw "AppEnvironment must be dev, staging, or prod." }
if ($AppApiScheme -notmatch '^https?$') { throw "AppApiScheme must be http or https." }
if ($AppApiDomain -notmatch '^[A-Za-z0-9.-]+$') { throw "AppApiDomain must be a hostname or IP address without a path." }
if ($AppApiPort -notmatch '^\d+$' -or [int]$AppApiPort -lt 1 -or [int]$AppApiPort -gt 65535) { throw "AppApiPort must be an integer from 1 to 65535." }
if ($AppApiVersion -notmatch '^[A-Za-z0-9._/-]+$' -or $AppApiVersion.StartsWith('/')) { throw "AppApiVersion must be a relative URL path." }

$appVersion = Get-Match (Join-Path $states.app.Path "pubspec.yaml") '^version:\s*([^\s]+)$'
$appProductVersion = ($appVersion -split '\+', 2)[0]
Assert-Equal $appProductVersion $Version "App product version"
Assert-Equal (Get-Match (Join-Path $states.server.Path "model\version.go") '^const Version = "([^"]+)"$') $Version "Server runtime version"
Assert-Equal (Get-Match (Join-Path $states.server.Path "docs\openapi.yaml") '^\s*version:\s*([^\s]+)$') $Version "Server OpenAPI version"
Assert-Equal (Get-Match (Join-Path $states.app.Path "server\docs\openapi.yaml") '^\s*version:\s*([^\s]+)$') $Version "App OpenAPI copy version"

$websitePackage = Get-Content -Raw -LiteralPath (Join-Path $states.website.Path "package.json") | ConvertFrom-Json -AsHashtable
$websiteLock = Get-Content -Raw -LiteralPath (Join-Path $states.website.Path "package-lock.json") | ConvertFrom-Json -AsHashtable
Assert-Equal $websitePackage["version"] $Version "Website package version"
Assert-Equal $websiteLock["version"] $Version "Website lockfile version"
Assert-Equal ((Get-Content -Raw -LiteralPath $versionPath).Trim()) $Version "Spec release version"

$serverOpenApi = Get-Sha256 (Join-Path $states.server.Path "docs\openapi.yaml")
$appOpenApi = Get-Sha256 (Join-Path $states.app.Path "server\docs\openapi.yaml")
Assert-Equal $appOpenApi $serverOpenApi "OpenAPI copy SHA-256"

foreach ($key in $repositories.Keys) { Assert-ContainsVersion (Join-Path $states[$key].Path "CHANGELOG.md") }
$releaseNote = Join-Path $states.spec.Path "release\notes\$Version.md"
if (-not (Test-Path -LiteralPath $releaseNote)) { throw "Missing release note: $releaseNote" }
if ((Get-Content -Raw -LiteralPath $releaseNote) -notmatch [regex]::Escape($Version)) { throw "Release note does not name $Version." }

if ($ValidateOnly) {
    Write-Output "Release-candidate contract validation passed for $Version."
    exit 0
}

$runId = (Get-Date).ToUniversalTime().ToString("yyyyMMddTHHmmssZ") + "-" + ([Guid]::NewGuid().ToString("N").Substring(0, 8))
$runRoot = Join-Path $OutputRoot "$Version\$runId"
$worktreeRoot = Join-Path $specPath ".release-worktrees\$runId"
$passOne = Join-Path $runRoot ".pass-1"
$passTwo = Join-Path $runRoot ".pass-2"
$artifactRoot = Join-Path $runRoot "artifacts"
New-Item -ItemType Directory -Path $passOne, $passTwo, $artifactRoot, $worktreeRoot -Force | Out-Null

try {
    $worktrees = @{}
    $imageMetadata = [ordered]@{}
    foreach ($key in $repositories.Keys) { $worktrees[$key] = New-CleanWorktree $states[$key] $worktreeRoot }

    Invoke-PackagePass $worktrees $passOne $states
    Invoke-PackagePass $worktrees $passTwo $states

    foreach ($key in @("app", "server", "website")) {
        $firstMetadataPath = Get-ChildItem -LiteralPath (Join-Path $passOne $key) -Filter "*.image.tar.json" | Select-Object -ExpandProperty FullName -First 1
        $secondMetadataPath = Get-ChildItem -LiteralPath (Join-Path $passTwo $key) -Filter "*.image.tar.json" | Select-Object -ExpandProperty FullName -First 1
        if (-not $firstMetadataPath -or -not $secondMetadataPath) { throw "Missing $key package metadata." }
        $first = Get-Content -Raw -LiteralPath $firstMetadataPath | ConvertFrom-Json
        $second = Get-Content -Raw -LiteralPath $secondMetadataPath | ConvertFrom-Json
        Assert-Equal ([string]$first.schema_version) "2" "$key package metadata schema"
        Assert-Equal $first.component $key "$key package metadata component"
        Assert-Equal $first.version $Version "$key package metadata version"
        Assert-Equal $first.revision $states[$key].Commit "$key package metadata revision"
        if ($first.image_ref -match '(^|:)latest$') { throw "$key package metadata uses a mutable latest tag." }
        Assert-Equal $second.image_id $first.image_id "$key replayed image identity"
        Assert-Equal $second.image_ref $first.image_ref "$key replayed image reference"
        Assert-Equal $second.artifact_sha256 $first.artifact_sha256 "$key replayed artifact SHA-256"
        if ($key -eq "app") {
            if ($first.configuration_profile -notmatch '^(dev|staging|prod)$') { throw "App package metadata has an invalid configuration profile." }
            if ($first.public_configuration_sha256 -notmatch '^[0-9a-f]{64}$') { throw "App package metadata has an invalid public configuration fingerprint." }
            Assert-Equal $second.configuration_profile $first.configuration_profile "app replayed configuration profile"
            Assert-Equal $second.public_configuration_sha256 $first.public_configuration_sha256 "app replayed public configuration fingerprint"
        }
        $imageMetadata[$key] = [ordered]@{
            component = $first.component
            artifact = $first.artifact
            artifact_sha256 = $first.artifact_sha256
            image_id = $first.image_id
            image_ref = $first.image_ref
            input_set_sha256 = $first.input_set_sha256
            revision = $first.revision
            version = $first.version
        }
        if ($key -eq "app") {
            $imageMetadata[$key]["configuration_profile"] = $first.configuration_profile
            $imageMetadata[$key]["public_configuration_sha256"] = $first.public_configuration_sha256
        }
        Copy-Item -LiteralPath (Join-Path (Split-Path $firstMetadataPath) $first.artifact) -Destination $artifactRoot
        Copy-Item -LiteralPath $firstMetadataPath -Destination $artifactRoot
        Copy-Item -LiteralPath "$((Join-Path (Split-Path $firstMetadataPath) $first.artifact)).sha256" -Destination $artifactRoot
    }

    foreach ($key in $repositories.Keys) {
        $name = "$($states[$key].Name)-$Version-$($states[$key].Commit.Substring(0,12)).source.zip"
        $firstArchive = Join-Path $passOne $name
        $secondArchive = Join-Path $passTwo $name
        & git -C $states[$key].Path archive --format=zip --output=$firstArchive $states[$key].Commit
        Assert-LastExit "Archive $($states[$key].Name) pass one"
        & git -C $states[$key].Path archive --format=zip --output=$secondArchive $states[$key].Commit
        Assert-LastExit "Archive $($states[$key].Name) pass two"
        Assert-Equal (Get-Sha256 $secondArchive) (Get-Sha256 $firstArchive) "$($states[$key].Name) replayed source archive SHA-256"
        Copy-Item -LiteralPath $firstArchive -Destination $artifactRoot
    }

    Copy-Item -LiteralPath $releaseNote -Destination (Join-Path $artifactRoot "release-notes-$Version.md")
    $artifactFiles = Get-ChildItem -LiteralPath $artifactRoot -File | Sort-Object Name
    $checksums = foreach ($file in $artifactFiles) { "$(Get-Sha256 $file.FullName)  $($file.Name)" }
    Set-Content -LiteralPath (Join-Path $artifactRoot "SHA256SUMS") -Value $checksums -Encoding ascii

    $artifacts = foreach ($file in (Get-ChildItem -LiteralPath $artifactRoot -File | Sort-Object Name)) {
        [ordered]@{ name = $file.Name; sha256 = Get-Sha256 $file.FullName; bytes = $file.Length }
    }
    $manifest = [ordered]@{
        schema_version = 2
        state = "passed"
        candidate = "untagged-non-production"
        version = $Version
        generated_at = (Get-Date).ToUniversalTime().ToString("o")
        repositories = [ordered]@{}
        validations = [ordered]@{
            clean_synchronized_sources = "passed"
            version_and_changelog_contract = "passed"
            openapi_copy_identity = "passed"
            absent_target_tags = "passed"
            repeated_image_identity = "passed"
            repeated_artifact_sha256 = "passed"
            repeated_source_archive_sha256 = "passed"
        }
        artifacts = $artifacts
        images = $imageMetadata
        migration_classification = "No database change is introduced by CLX-19 release tooling."
        requested_delivery_actions = @()
        performed_delivery_actions = @()
        deployment_state = "Not deployed"
        secrets_recorded = $false
        known_limits = @("Local replay uses the same controlled Docker cache; CLX-30 will compose this artifact gate with the full release-candidate acceptance gate.")
    }
    foreach ($key in $repositories.Keys) {
        $manifest.repositories[$key] = [ordered]@{
            branch = $states[$key].Branch
            upstream = $states[$key].Upstream
            commit = $states[$key].Commit
            tree = $states[$key].Tree
        }
    }
    $manifestPath = Join-Path $runRoot "manifest.json"
    $manifest | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $manifestPath -Encoding utf8NoBOM
    $manifestHash = Get-Sha256 $manifestPath
    Set-Content -LiteralPath "$manifestPath.sha256" -Value "$manifestHash  manifest.json" -Encoding ascii

    Remove-Item -LiteralPath $passOne, $passTwo -Recurse -Force
    Write-Output "Release candidate passed: $manifestPath"
}
finally {
    if (-not $KeepWorktrees) {
        for ($index = $createdWorktrees.Count - 1; $index -ge 0; $index--) {
            $worktree = $createdWorktrees[$index]
            & git -C $worktree.Source worktree remove --force $worktree.Target *> $null
        }
        if (Test-Path -LiteralPath $worktreeRoot) { Remove-Item -LiteralPath $worktreeRoot -Recurse -Force }
    }
}
