$ErrorActionPreference = "Stop"
$specPath = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$deployScript = Join-Path $PSScriptRoot "deploy-candidate.ps1"
$testRoot = Join-Path ([IO.Path]::GetTempPath()) ("cashlenx-deploy-smoke-" + [Guid]::NewGuid().ToString("N"))
$workspace = Join-Path $testRoot "workspace"
$stateRoot = Join-Path $testRoot "state"
$operationsLog = Join-Path $testRoot "operations.log"
$runtimeState = Join-Path $testRoot "images.json"
$fakeRuntime = Join-Path $testRoot "fake-container.ps1"

function Get-Sha256([string]$Path) {
    return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
}

function Get-TextSha256([string]$Value) {
    return [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes($Value))).ToLowerInvariant()
}

function Assert-True([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
}

function New-FakeRepository([string]$Name, [string]$Component) {
    $repository = Join-Path $workspace $Name
    New-Item -ItemType Directory -Path (Join-Path $repository "scripts") -Force | Out-Null
    $imageNameKey = switch ($Component) { "app" { "IMAGE_NAME" } "server" { "SERVER_IMAGE_NAME" } default { "WEBSITE_IMAGE_NAME" } }
    $imageTagKey = switch ($Component) { "app" { "IMAGE_TAG" } "server" { "SERVER_IMAGE_TAG" } default { "WEBSITE_IMAGE_TAG" } }
    $start = @"
#!/usr/bin/env bash
set -euo pipefail
image_name="`${$imageNameKey}"
image_tag="`${$imageTagKey}"
printf 'start:${Component}:%s:%s\n' "`$image_name" "`$image_tag" >> "`$OPERATIONS_LOG"
if [[ "`${FAIL_COMPONENT:-}" == "$Component" ]]; then
  exit 17
fi
"@
    $stop = @"
#!/usr/bin/env bash
set -euo pipefail
printf 'stop:$Component\n' >> "`$OPERATIONS_LOG"
"@
    Set-Content -LiteralPath (Join-Path $repository "scripts\start.sh") -Value $start -Encoding utf8NoBOM
    Set-Content -LiteralPath (Join-Path $repository "scripts\stop.sh") -Value $stop -Encoding utf8NoBOM
    if ($Component -eq "app") {
        Set-Content -LiteralPath (Join-Path $repository ".env") -Encoding utf8NoBOM -Value @(
            "APP_ENV=dev", "API_SCHEME=http", "API_DOMAIN=127.0.0.1", "API_PORT=10063", "API_VERSION=api/v1"
        )
        Set-Content -LiteralPath (Join-Path $repository ".env-mismatch") -Encoding utf8NoBOM -Value @(
            "APP_ENV=staging", "API_SCHEME=https", "API_DOMAIN=example.invalid", "API_PORT=443", "API_VERSION=api/v1"
        )
    }
    else { Set-Content -LiteralPath (Join-Path $repository ".env") -Value "CONTAINER_FRONTEND=auto" -Encoding utf8NoBOM }
}

function New-Candidate([string]$Version, [int]$Seed, [switch]$MutableTag) {
    $root = Join-Path $testRoot "candidate-$Seed"
    $artifactsPath = Join-Path $root "artifacts"
    New-Item -ItemType Directory -Path $artifactsPath -Force | Out-Null
    $commits = [ordered]@{
        app = (Get-TextSha256 "app-$Seed").Substring(0, 40)
        server = (Get-TextSha256 "server-$Seed").Substring(0, 40)
        website = (Get-TextSha256 "website-$Seed").Substring(0, 40)
        spec = (Get-TextSha256 "spec-$Seed").Substring(0, 40)
    }
    $normalized = "APP_ENV=dev`nAPI_SCHEME=http`nAPI_DOMAIN=127.0.0.1`nAPI_PORT=10063`nAPI_VERSION=api/v1`n"
    $publicHash = Get-TextSha256 $normalized
    $images = [ordered]@{}
    foreach ($component in @("app", "server", "website")) {
        $revision = $commits[$component]
        $tag = if ($MutableTag) { "latest" } elseif ($component -eq "app") {
            "$Version-$($revision.Substring(0, 12))-dev-$($publicHash.Substring(0, 12))"
        } else { "$Version-$($revision.Substring(0, 12))" }
        $imageRef = "cashlenx-${component}-candidate:$tag"
        $imageId = "sha256:$(Get-TextSha256 "$imageRef-$Seed")"
        $artifact = "cashlenx-$component-$Version-$Seed.image.tar"
        $archivePath = Join-Path $artifactsPath $artifact
        [ordered]@{ image_ref = $imageRef; image_id = $imageId } | ConvertTo-Json -Compress | Set-Content -LiteralPath $archivePath -Encoding utf8NoBOM
        $artifactSha = Get-Sha256 $archivePath
        $metadata = [ordered]@{
            schema_version = 2; component = $component; artifact = $artifact; artifact_sha256 = $artifactSha
            image_id = $imageId; image_ref = $imageRef; input_set_sha256 = ("f" * 64); revision = $revision; version = $Version
        }
        if ($component -eq "app") {
            $metadata.configuration_profile = "dev"
            $metadata.public_configuration_sha256 = $publicHash
        }
        $metadata | ConvertTo-Json -Compress | Set-Content -LiteralPath "$archivePath.json" -Encoding utf8NoBOM
        Set-Content -LiteralPath "$archivePath.sha256" -Value "$artifactSha  $artifact" -Encoding ascii
        $images[$component] = $metadata
    }
    $checksumFiles = Get-ChildItem -LiteralPath $artifactsPath -File | Sort-Object Name
    Set-Content -LiteralPath (Join-Path $artifactsPath "SHA256SUMS") -Encoding ascii -Value @(
        $checksumFiles | ForEach-Object { "$(Get-Sha256 $_.FullName)  $($_.Name)" }
    )
    $artifactList = @(
        Get-ChildItem -LiteralPath $artifactsPath -File | Sort-Object Name | ForEach-Object {
            [ordered]@{ name = $_.Name; sha256 = Get-Sha256 $_.FullName; bytes = $_.Length }
        }
    )
    $repositories = [ordered]@{}
    foreach ($component in @("app", "server", "website", "spec")) {
        $repositories[$component] = [ordered]@{ commit = $commits[$component]; branch = "test"; upstream = "origin/test"; tree = ("e" * 40) }
    }
    $manifest = [ordered]@{
        schema_version = 2; state = "passed"; candidate = "untagged-non-production"; version = $Version
        generated_at = (Get-Date).ToUniversalTime().ToString("o"); repositories = $repositories; artifacts = $artifactList
        images = $images; secrets_recorded = $false
    }
    $manifestPath = Join-Path $root "manifest.json"
    $manifest | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $manifestPath -Encoding utf8NoBOM
    Set-Content -LiteralPath "$manifestPath.sha256" -Value "$(Get-Sha256 $manifestPath)  manifest.json" -Encoding ascii
    return $manifestPath
}

function Invoke-Deploy([string]$Action, [string]$Manifest, [string]$AppEnv = ".env") {
    $parameters = @{
        Action = $Action; TargetName = "smoke"; AppEnvFile = $AppEnv; ServerEnvFile = ".env"; WebsiteEnvFile = ".env"
        ContainerFrontend = "docker"; ContainerCli = $fakeRuntime; StateRoot = $stateRoot; WorkspacePath = $workspace
    }
    if ($Manifest) { $parameters.ManifestPath = $Manifest }
    & $deployScript @parameters | Out-Null
}

function Assert-FailsWithoutLifecycle([scriptblock]$Operation, [string]$Label) {
    $before = if (Test-Path -LiteralPath $operationsLog) { Get-Content -Raw -LiteralPath $operationsLog } else { "" }
    $failed = $false
    try { & $Operation } catch { $failed = $true }
    Assert-True $failed "$Label did not fail."
    $after = if (Test-Path -LiteralPath $operationsLog) { Get-Content -Raw -LiteralPath $operationsLog } else { "" }
    Assert-True ($before -ceq $after) "$Label mutated the lifecycle before rejection."
}

New-Item -ItemType Directory -Path $workspace -Force | Out-Null
try {
    New-FakeRepository "cashlenx-app" "app"
    New-FakeRepository "cashlenx-server" "server"
    New-FakeRepository "cashlenx-website" "website"
    Set-Content -LiteralPath $runtimeState -Value "{}" -Encoding utf8NoBOM
    Set-Content -LiteralPath $operationsLog -Value "" -Encoding utf8NoBOM
    Set-Content -LiteralPath $fakeRuntime -Encoding utf8NoBOM -Value @'
param([Parameter(ValueFromRemainingArguments = $true)][string[]]$CommandArgs)
$ErrorActionPreference = "Stop"
$statePath = $env:FAKE_CONTAINER_STATE
$state = if (Test-Path -LiteralPath $statePath) { Get-Content -Raw -LiteralPath $statePath | ConvertFrom-Json -AsHashtable } else { @{} }
if ($CommandArgs[0] -eq "version") { Write-Output "Docker version 29.0.0"; exit 0 }
if ($CommandArgs[0] -eq "image" -and $CommandArgs[1] -eq "inspect") {
    $reference = $CommandArgs[2]
    if (-not $state.ContainsKey($reference)) { exit 1 }
    Write-Output $state[$reference]
    exit 0
}
if ($CommandArgs[0] -eq "image" -and $CommandArgs[1] -eq "load") {
    $archive = $CommandArgs[3]
    $record = Get-Content -Raw -LiteralPath $archive | ConvertFrom-Json
    $state[$record.image_ref] = $record.image_id
    $state | ConvertTo-Json | Set-Content -LiteralPath $statePath -Encoding utf8NoBOM
    Write-Output "Loaded image: $($record.image_ref)"
    exit 0
}
exit 2
'@
    $env:OPERATIONS_LOG = $operationsLog
    $env:FAKE_CONTAINER_STATE = $runtimeState

    $candidateA = New-Candidate "1.0.0-rc.1" 1
    $candidateB = New-Candidate "1.0.0-rc.2" 2
    $candidateC = New-Candidate "1.0.0-rc.3" 3
    Invoke-Deploy "Deploy" $candidateA
    Invoke-Deploy "Deploy" $candidateA
    $state = Get-Content -Raw -LiteralPath (Join-Path $stateRoot "smoke\state.json") | ConvertFrom-Json
    Assert-True ($state.current.version -eq "1.0.0-rc.1" -and -not $state.rollback_candidate) "Repeated deploy was not idempotent."

    Invoke-Deploy "Deploy" $candidateB
    Invoke-Deploy "Rollback" $null
    Invoke-Deploy "Rollback" $null
    $state = Get-Content -Raw -LiteralPath (Join-Path $stateRoot "smoke\state.json") | ConvertFrom-Json
    Assert-True ($state.current.version -eq "1.0.0-rc.1" -and $state.last_action -eq "rollback") "Rollback did not restore candidate A."

    Invoke-Deploy "Deploy" $candidateB
    $imageState = Get-Content -Raw -LiteralPath $runtimeState | ConvertFrom-Json -AsHashtable
    $manifestA = Get-Content -Raw -LiteralPath $candidateA | ConvertFrom-Json
    foreach ($component in @("app", "server", "website")) { $imageState.Remove($manifestA.images.$component.image_ref) }
    $imageState | ConvertTo-Json | Set-Content -LiteralPath $runtimeState -Encoding utf8NoBOM
    Assert-FailsWithoutLifecycle { Invoke-Deploy "Rollback" $null } "Missing rollback image"
    foreach ($component in @("app", "server", "website")) { $imageState[$manifestA.images.$component.image_ref] = $manifestA.images.$component.image_id }
    $imageState | ConvertTo-Json | Set-Content -LiteralPath $runtimeState -Encoding utf8NoBOM

    Assert-FailsWithoutLifecycle { Invoke-Deploy "Deploy" $candidateB ".env-mismatch" } "Configuration fingerprint mismatch"
    $mutable = New-Candidate "1.0.0-rc.4" 4 -MutableTag
    Assert-FailsWithoutLifecycle { Invoke-Deploy "Deploy" $mutable } "Mutable tag"
    $tampered = New-Candidate "1.0.0-rc.5" 5
    $tamperedManifest = Get-Content -Raw -LiteralPath $tampered | ConvertFrom-Json
    Add-Content -LiteralPath (Join-Path (Join-Path (Split-Path $tampered) "artifacts") $tamperedManifest.images.app.artifact) -Value "tampered"
    Assert-FailsWithoutLifecycle { Invoke-Deploy "Deploy" $tampered } "Tampered archive"
    $revisionTampered = New-Candidate "1.0.0-rc.6" 6
    $revisionManifest = Get-Content -Raw -LiteralPath $revisionTampered | ConvertFrom-Json -AsHashtable
    $revisionManifest.repositories.app.commit = "0" * 40
    $revisionManifest | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $revisionTampered -Encoding utf8NoBOM
    Set-Content -LiteralPath "$revisionTampered.sha256" -Value "$(Get-Sha256 $revisionTampered)  manifest.json" -Encoding ascii
    Assert-FailsWithoutLifecycle { Invoke-Deploy "Deploy" $revisionTampered } "Revision mismatch"

    $stateBeforePartial = Get-Content -Raw -LiteralPath (Join-Path $stateRoot "smoke\state.json")
    $env:FAIL_COMPONENT = "app"
    $partialFailed = $false
    try { Invoke-Deploy "Deploy" $candidateC } catch { $partialFailed = $true }
    finally { Remove-Item Env:FAIL_COMPONENT -ErrorAction SilentlyContinue }
    Assert-True $partialFailed "Partial-start scenario did not fail."
    $stateAfterPartial = Get-Content -Raw -LiteralPath (Join-Path $stateRoot "smoke\state.json")
    Assert-True ($stateBeforePartial -ceq $stateAfterPartial) "Partial-start failure changed deployment state."
    $operations = Get-Content -Raw -LiteralPath $operationsLog
    Assert-True ($operations -match 'start:server:cashlenx-server-candidate:1\.0\.0-rc\.3-' -and $operations -match 'start:server:cashlenx-server-candidate:1\.0\.0-rc\.2-') "Partial-start recovery did not restore the recorded candidate."
    Assert-True ($operations -notmatch '(?i)database|volume|pull|latest') "Deployment lifecycle touched a prohibited database, volume, pull, or latest path."

    Invoke-Deploy "Rollback" $null
    $finalState = Get-Content -Raw -LiteralPath (Join-Path $stateRoot "smoke\state.json") | ConvertFrom-Json
    Assert-True ($finalState.current.version -eq "1.0.0-rc.1") "Final rollback did not restore candidate A."
    $evidence = Get-ChildItem -LiteralPath (Join-Path $stateRoot "smoke") -Filter "*.json" | Where-Object Name -ne "state.json"
    Assert-True ($evidence.Count -ge 10) "Expected deployment evidence was not written."
    foreach ($file in $evidence) {
        $record = Get-Content -Raw -LiteralPath $file.FullName | ConvertFrom-Json
        Assert-True ($record.secrets_recorded -eq $false -and $record.database_action -eq "none") "Evidence contract is incomplete."
    }
    Write-Output "Candidate deployment smoke tests passed."
}
finally {
    Remove-Item Env:OPERATIONS_LOG -ErrorAction SilentlyContinue
    Remove-Item Env:FAKE_CONTAINER_STATE -ErrorAction SilentlyContinue
    Remove-Item Env:FAIL_COMPONENT -ErrorAction SilentlyContinue
    if (Test-Path -LiteralPath $testRoot) { Remove-Item -LiteralPath $testRoot -Recurse -Force }
}
