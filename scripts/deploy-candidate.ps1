param(
    [ValidateSet("Deploy", "Rollback")]
    [string]$Action = "Deploy",
    [string]$ManifestPath,
    [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9_.-]{0,63}$')]
    [string]$TargetName = "local",
    [string]$AppEnvFile = ".env",
    [string]$ServerEnvFile = ".env",
    [string]$WebsiteEnvFile = ".env",
    [ValidateSet("auto", "docker", "nerdctl")]
    [string]$ContainerFrontend = "auto",
    [string]$ContainerCli,
    [string]$StateRoot,
    [string]$WorkspacePath
)

$ErrorActionPreference = "Stop"
$specPath = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
if (-not $WorkspacePath) { $WorkspacePath = (Resolve-Path (Join-Path $specPath "..")).Path }
else { $WorkspacePath = (Resolve-Path -LiteralPath $WorkspacePath).Path }
if (-not $StateRoot) { $StateRoot = Join-Path $specPath ".artifacts\deployments" }
$bashPath = "C:\Program Files\Git\bin\bash.exe"
$componentContract = [ordered]@{
    app = [pscustomobject]@{
        Repository = "cashlenx-app"; Script = "scripts/start.sh"; StopScript = "scripts/stop.sh"
        ImageNameKey = "IMAGE_NAME"; ImageTagKey = "IMAGE_TAG"; EnvFile = $AppEnvFile
    }
    server = [pscustomobject]@{
        Repository = "cashlenx-server"; Script = "scripts/start.sh"; StopScript = "scripts/stop.sh"
        ImageNameKey = "SERVER_IMAGE_NAME"; ImageTagKey = "SERVER_IMAGE_TAG"; EnvFile = $ServerEnvFile
    }
    website = [pscustomobject]@{
        Repository = "cashlenx-website"; Script = "scripts/start.sh"; StopScript = "scripts/stop.sh"
        ImageNameKey = "WEBSITE_IMAGE_NAME"; ImageTagKey = "WEBSITE_IMAGE_TAG"; EnvFile = $WebsiteEnvFile
    }
}

function Get-Sha256([string]$Path) {
    return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
}

function Assert-Equal([string]$Actual, [string]$Expected, [string]$Label) {
    if ($Actual -cne $Expected) { throw "$Label is '$Actual'; expected '$Expected'." }
}

function Assert-SafeLeafName([string]$Name, [string]$Label) {
    if (-not $Name -or $Name -ne [IO.Path]::GetFileName($Name) -or $Name -match '[\\/]') {
        throw "$Label must be a plain file name."
    }
}

function Resolve-RepositoryEnvFile([string]$RepositoryPath, [string]$Requested) {
    $candidate = if ([IO.Path]::IsPathRooted($Requested)) { $Requested } else { Join-Path $RepositoryPath $Requested }
    if (-not (Test-Path -LiteralPath $candidate -PathType Leaf)) { throw "Environment file does not exist: $Requested" }
    $resolved = (Resolve-Path -LiteralPath $candidate).Path
    $prefix = $RepositoryPath.TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
    if (-not $resolved.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Environment files must resolve inside their owning repository."
    }
    return [pscustomobject]@{
        FullPath = $resolved
        RelativePath = [IO.Path]::GetRelativePath($RepositoryPath, $resolved).Replace('\', '/')
    }
}

function Get-DotEnvValues([string]$Path) {
    $values = @{}
    foreach ($line in Get-Content -LiteralPath $Path) {
        if ($line -notmatch '^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=(.*)$') { continue }
        $key = $Matches[1]
        $value = $Matches[2].Trim()
        if ($value.Length -ge 2 -and (($value.StartsWith('"') -and $value.EndsWith('"')) -or ($value.StartsWith("'") -and $value.EndsWith("'")))) {
            $value = $value.Substring(1, $value.Length - 2)
        }
        $values[$key] = $value
    }
    return $values
}

function Get-PublicAppConfiguration([string]$Path) {
    $values = Get-DotEnvValues $Path
    function Select-Value([string]$Key, [string]$Fallback) {
        if ($values.ContainsKey($Key) -and $values[$Key]) { return [string]$values[$Key] }
        return $Fallback
    }
    $profile = Select-Value "APP_ENV" "dev"
    $scheme = Select-Value "API_SCHEME" "http"
    $domain = Select-Value "API_DOMAIN" "127.0.0.1"
    $port = Select-Value "API_PORT" "10063"
    $apiVersion = Select-Value "API_VERSION" "api/v1"
    if ($profile -notmatch '^(dev|staging|prod)$') { throw "APP_ENV must be dev, staging, or prod." }
    if ($scheme -notmatch '^https?$') { throw "API_SCHEME must be http or https." }
    if ($domain -notmatch '^[A-Za-z0-9.-]+$') { throw "API_DOMAIN must be a hostname or IP address without a path." }
    if ($port -notmatch '^\d+$' -or [int]$port -lt 1 -or [int]$port -gt 65535) { throw "API_PORT must be an integer from 1 to 65535." }
    if ($apiVersion -notmatch '^[A-Za-z0-9._/-]+$' -or $apiVersion.StartsWith('/')) { throw "API_VERSION must be a relative URL path." }
    $normalized = "APP_ENV=$profile`nAPI_SCHEME=$scheme`nAPI_DOMAIN=$domain`nAPI_PORT=$port`nAPI_VERSION=$apiVersion`n"
    $bytes = [Text.Encoding]::UTF8.GetBytes($normalized)
    $hash = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($bytes)).ToLowerInvariant()
    return [pscustomobject]@{ Profile = $profile; Sha256 = $hash }
}

function Get-TargetCoordinates {
    $coordinates = [ordered]@{ network = $null; components = [ordered]@{} }
    $settings = [ordered]@{
        app = [ordered]@{ Container = "CONTAINER_NAME"; ContainerDefault = "cashlenx-app"; Project = "APP_PROJECT_NAME"; ProjectDefault = "cashlenx-app" }
        server = [ordered]@{ Container = "BACKEND_CONTAINER_NAME"; ContainerDefault = "cashlenx-server"; Project = "SERVER_PROJECT_NAME"; ProjectDefault = "cashlenx-server" }
        website = [ordered]@{ Container = "WEBSITE_CONTAINER_NAME"; ContainerDefault = "cashlenx-website"; Project = "WEBSITE_PROJECT_NAME"; ProjectDefault = "cashlenx-website" }
    }
    foreach ($component in $componentContract.Keys) {
        $values = Get-DotEnvValues $script:envFiles[$component].FullPath
        $containerName = if ($values[$settings[$component].Container]) { $values[$settings[$component].Container] } else { $settings[$component].ContainerDefault }
        $projectName = if ($values[$settings[$component].Project]) { $values[$settings[$component].Project] } else { $settings[$component].ProjectDefault }
        $networkName = if ($values["DOCKER_NETWORK_NAME"]) { $values["DOCKER_NETWORK_NAME"] } else { "cashlenx-network" }
        if ($containerName -notmatch '^[A-Za-z0-9][A-Za-z0-9_.-]*$' -or $projectName -notmatch '^[a-z0-9][a-z0-9_-]*$' -or $networkName -notmatch '^[A-Za-z0-9][A-Za-z0-9_.-]*$') {
            throw "Target container, project, or network identity is invalid for $component."
        }
        if ($coordinates.network -and $coordinates.network -cne $networkName) { throw "All target environment files must select the same Docker network." }
        $coordinates.network = $networkName
        $coordinates.components[$component] = [ordered]@{ container = $containerName; project = $projectName }
    }
    return $coordinates
}

function Get-ContainerRuntime {
    $candidates = if ($ContainerCli) { @($ContainerCli) } elseif ($ContainerFrontend -eq "docker") { @("docker") } elseif ($ContainerFrontend -eq "nerdctl") { @("nerdctl") } else { @("docker", "nerdctl") }
    foreach ($candidate in $candidates) {
        if (-not (Get-Command $candidate -ErrorAction SilentlyContinue)) { continue }
        $output = (& $candidate version 2>&1 | Out-String)
        if ($LASTEXITCODE -ne 0) { continue }
        $isNerdctl = $output -match '(?im)nerdctl(?:\s+version)?\s+v?(\d+)\.(\d+)'
        if ($isNerdctl) {
            $major = [int]$Matches[1]; $minor = [int]$Matches[2]
            if ($major -lt 2 -or ($major -eq 2 -and $minor -lt 2)) { throw "nerdctl 2.2 or newer is required." }
            if ($ContainerFrontend -eq "docker") { throw "The selected Docker command reports nerdctl behavior." }
            return [pscustomobject]@{ Command = $candidate; Kind = "nerdctl" }
        }
        if ($ContainerFrontend -eq "nerdctl") { throw "The selected command does not report nerdctl behavior." }
        return [pscustomobject]@{ Command = $candidate; Kind = "docker" }
    }
    throw "Docker Compose or nerdctl 2.2+ is required."
}

function Invoke-Container([string[]]$Arguments, [switch]$AllowFailure) {
    $output = & $script:runtime.Command @Arguments 2>&1
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0 -and -not $AllowFailure) { throw "Container command failed: $($Arguments -join ' ')" }
    return [pscustomobject]@{ ExitCode = $exitCode; Output = (($output | Out-String).Trim()) }
}

function Get-LocalImageId([string]$ImageRef, [switch]$AllowMissing) {
    $result = Invoke-Container @("image", "inspect", $ImageRef, "--format", "{{.Id}}") -AllowFailure
    if ($result.ExitCode -ne 0) {
        if ($AllowMissing) { return $null }
        throw "Required local image is missing: $ImageRef"
    }
    return ($result.Output -split "`r?`n")[-1].Trim()
}

function Test-ContainerExists([string]$ContainerName) {
    $result = Invoke-Container @("container", "inspect", $ContainerName, "--format", "{{.Id}}") -AllowFailure
    return $result.ExitCode -eq 0
}

function Import-Image([string]$ArchivePath) {
    if ($script:runtime.Kind -eq "nerdctl") { [void](Invoke-Container @("load", "--input", $ArchivePath)) }
    else { [void](Invoke-Container @("image", "load", "--input", $ArchivePath)) }
}

function Split-ImageRef([string]$ImageRef) {
    $separator = $ImageRef.LastIndexOf(':')
    if ($separator -le 0 -or $ImageRef.Contains('@')) { throw "Only exact immutable tag references are accepted: $ImageRef" }
    return [pscustomobject]@{ Name = $ImageRef.Substring(0, $separator); Tag = $ImageRef.Substring($separator + 1) }
}

function Read-VerifiedState([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $null }
    $sidecar = "$Path.sha256"
    if (-not (Test-Path -LiteralPath $sidecar -PathType Leaf)) { throw "Deployment state checksum is missing." }
    $line = (Get-Content -Raw -LiteralPath $sidecar).Trim()
    if ($line -notmatch '^([0-9a-f]{64})  state\.json$') { throw "Deployment state checksum format is invalid." }
    Assert-Equal (Get-Sha256 $Path) $Matches[1] "Deployment state SHA-256"
    return Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json -AsHashtable
}

function Write-JsonAtomically([string]$Path, [object]$Value) {
    $directory = Split-Path $Path
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    $temporary = "$Path.$([Guid]::NewGuid().ToString('N')).tmp"
    $Value | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $temporary -Encoding utf8NoBOM
    Move-Item -LiteralPath $temporary -Destination $Path -Force
}

function Write-State([string]$Path, $State) {
    Write-JsonAtomically $Path $State
    Set-Content -LiteralPath "$Path.sha256" -Value "$(Get-Sha256 $Path)  state.json" -Encoding ascii
}

function Invoke-Lifecycle([string]$Component, [string]$Script, $Image, [switch]$Stop) {
    $contract = $componentContract[$Component]
    $repositoryPath = Join-Path $WorkspacePath $contract.Repository
    $imageParts = Split-ImageRef $Image.image_ref
    $saved = @{}
    $environment = [ordered]@{
        ENV_FILE = $script:envFiles[$Component].RelativePath
        CONTAINER_FRONTEND = $ContainerFrontend
        CONTAINER_CLI = if ($ContainerCli) { $runtime.Command } else { "" }
    }
    $environment[$contract.ImageNameKey] = $imageParts.Name
    $environment[$contract.ImageTagKey] = $imageParts.Tag
    foreach ($entry in $environment.GetEnumerator()) {
        $saved[$entry.Key] = [Environment]::GetEnvironmentVariable($entry.Key, "Process")
        if ($entry.Value) { [Environment]::SetEnvironmentVariable($entry.Key, [string]$entry.Value, "Process") }
        else { [Environment]::SetEnvironmentVariable($entry.Key, $null, "Process") }
    }
    Push-Location $repositoryPath
    try {
        $selected = if ($Stop) { $contract.StopScript } else { $Script }
        & $bashPath -lc "./$selected"
        if ($LASTEXITCODE -ne 0) { throw "$Component lifecycle command failed." }
    }
    finally {
        Pop-Location
        foreach ($entry in $saved.GetEnumerator()) { [Environment]::SetEnvironmentVariable($entry.Key, $entry.Value, "Process") }
    }
}

function Assert-LocalImages($Deployment) {
    foreach ($component in $componentContract.Keys) {
        $image = $Deployment.images[$component]
        Assert-Equal (Get-LocalImageId $image.image_ref) $image.image_id "$component local image identity"
    }
}

function Start-Deployment($Deployment, $RecoveryDeployment) {
    Assert-LocalImages $Deployment
    $started = [Collections.Generic.List[string]]::new()
    try {
        foreach ($component in @("server", "app", "website")) {
            $started.Add($component)
            Invoke-Lifecycle $component $componentContract[$component].Script $Deployment.images[$component]
        }
    }
    catch {
        $failure = $_.Exception.Message
        if ($RecoveryDeployment) {
            try {
                Assert-LocalImages $RecoveryDeployment
                foreach ($component in @("server", "app", "website")) {
                    Invoke-Lifecycle $component $componentContract[$component].Script $RecoveryDeployment.images[$component]
                }
            }
            catch { throw "Deployment failed ($failure), and automatic recovery failed: $($_.Exception.Message)" }
            throw "Deployment failed ($failure); the previously recorded image identities were restored."
        }
        for ($index = $started.Count - 1; $index -ge 0; $index--) {
            try { Invoke-Lifecycle $started[$index] $componentContract[$started[$index]].StopScript $Deployment.images[$started[$index]] -Stop } catch { }
        }
        throw "Deployment failed ($failure); newly started application containers were stopped. Database services and volumes were not changed."
    }
}

function Get-VerifiedCandidate([string]$Path) {
    if (-not $Path) { throw "ManifestPath is required for Deploy." }
    $resolvedManifest = (Resolve-Path -LiteralPath $Path).Path
    $manifestSidecar = "$resolvedManifest.sha256"
    if (-not (Test-Path -LiteralPath $manifestSidecar -PathType Leaf)) { throw "Manifest checksum sidecar is missing." }
    $manifestChecksumLine = (Get-Content -Raw -LiteralPath $manifestSidecar).Trim()
    if ($manifestChecksumLine -notmatch '^([0-9a-f]{64})  manifest\.json$') { throw "Manifest checksum format is invalid." }
    $manifestHash = Get-Sha256 $resolvedManifest
    Assert-Equal $manifestHash $Matches[1] "Manifest SHA-256"
    $manifest = Get-Content -Raw -LiteralPath $resolvedManifest | ConvertFrom-Json -AsHashtable
    Assert-Equal ([string]$manifest.schema_version) "2" "Manifest schema version"
    Assert-Equal $manifest.state "passed" "Manifest state"
    Assert-Equal $manifest.candidate "untagged-non-production" "Manifest candidate classification"
    if ($manifest.secrets_recorded -ne $false) { throw "Manifest must assert that no secrets were recorded." }
    if ($manifest.version -notmatch '^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$') { throw "Manifest version is invalid." }
    $artifactRoot = Join-Path (Split-Path $resolvedManifest) "artifacts"
    if (-not (Test-Path -LiteralPath $artifactRoot -PathType Container)) { throw "Candidate artifact directory is missing." }
    $artifactIndex = @{}
    foreach ($artifact in $manifest.artifacts) {
        Assert-SafeLeafName $artifact.name "Artifact name"
        $artifactPath = Join-Path $artifactRoot $artifact.name
        if (-not (Test-Path -LiteralPath $artifactPath -PathType Leaf)) { throw "Candidate artifact is missing: $($artifact.name)" }
        Assert-Equal (Get-Sha256 $artifactPath) $artifact.sha256 "Artifact SHA-256 for $($artifact.name)"
        if ((Get-Item -LiteralPath $artifactPath).Length -ne [long]$artifact.bytes) { throw "Artifact byte length is invalid for $($artifact.name)." }
        $artifactIndex[$artifact.name] = $artifact
    }
    $sumPath = Join-Path $artifactRoot "SHA256SUMS"
    if (-not $artifactIndex.ContainsKey("SHA256SUMS")) { throw "SHA256SUMS is absent from the manifest." }
    $sumNames = @{}
    foreach ($line in Get-Content -LiteralPath $sumPath) {
        if ($line -notmatch '^([0-9a-f]{64})  (.+)$') { throw "SHA256SUMS contains an invalid line." }
        $name = $Matches[2]; Assert-SafeLeafName $name "SHA256SUMS artifact name"
        if (-not $artifactIndex.ContainsKey($name)) { throw "SHA256SUMS references an unlisted artifact: $name" }
        Assert-Equal (Get-Sha256 (Join-Path $artifactRoot $name)) $Matches[1] "SHA256SUMS entry for $name"
        $sumNames[$name] = $true
    }
    foreach ($name in $artifactIndex.Keys) {
        if ($name -ne "SHA256SUMS" -and -not $sumNames.ContainsKey($name)) { throw "SHA256SUMS omits a listed artifact: $name" }
    }
    $images = [ordered]@{}
    foreach ($component in $componentContract.Keys) {
        if (-not $manifest.images.ContainsKey($component)) { throw "Manifest image entry is missing: $component" }
        $image = $manifest.images[$component]
        Assert-Equal ([string]$image.component) $component "$component image component"
        Assert-Equal ([string]$image.version) $manifest.version "$component image version"
        Assert-Equal ([string]$image.revision) ([string]$manifest.repositories[$component].commit) "$component image revision"
        if ($image.revision -notmatch '^[0-9a-f]{40}$' -or $image.image_id -notmatch '^sha256:[0-9a-f]{64}$' -or $image.artifact_sha256 -notmatch '^[0-9a-f]{64}$') {
            throw "$component image identity fields are invalid."
        }
        $expectedPattern = if ($component -eq "app") {
            '^cashlenx-app-candidate:' + [regex]::Escape($manifest.version) + '-' + $image.revision.Substring(0, 12) + '-(dev|staging|prod)-[0-9a-f]{12}$'
        } else {
            '^cashlenx-' + $component + '-candidate:' + [regex]::Escape($manifest.version) + '-' + $image.revision.Substring(0, 12) + '$'
        }
        if ($image.image_ref -notmatch $expectedPattern -or $image.image_ref -match '(^|:)latest$') { throw "$component image reference is not an exact candidate identity." }
        Assert-SafeLeafName $image.artifact "$component image artifact"
        foreach ($name in @($image.artifact, "$($image.artifact).json", "$($image.artifact).sha256")) {
            if (-not $artifactIndex.ContainsKey($name)) { throw "$component package file is absent from the manifest: $name" }
        }
        $metadataPath = Join-Path $artifactRoot "$($image.artifact).json"
        $metadata = Get-Content -Raw -LiteralPath $metadataPath | ConvertFrom-Json -AsHashtable
        foreach ($field in @("component", "artifact", "artifact_sha256", "image_id", "image_ref", "input_set_sha256", "revision", "version")) {
            Assert-Equal ([string]$metadata[$field]) ([string]$image[$field]) "$component metadata field $field"
        }
        Assert-Equal ([string]$metadata.schema_version) "2" "$component metadata schema"
        $packageSidecar = (Get-Content -Raw -LiteralPath (Join-Path $artifactRoot "$($image.artifact).sha256")).Trim()
        if ($packageSidecar -notmatch '^([0-9a-f]{64})  (.+)$') { throw "$component package checksum format is invalid." }
        Assert-Equal $Matches[1] $image.artifact_sha256 "$component package checksum"
        Assert-Equal $Matches[2] $image.artifact "$component package checksum name"
        if ($component -eq "app") {
            foreach ($field in @("configuration_profile", "public_configuration_sha256")) {
                Assert-Equal ([string]$metadata[$field]) ([string]$image[$field]) "app metadata field $field"
            }
            if ($image.configuration_profile -notmatch '^(dev|staging|prod)$' -or $image.public_configuration_sha256 -notmatch '^[0-9a-f]{64}$') {
                throw "App public configuration identity is invalid."
            }
            Assert-Equal $script:appPublicConfiguration.Profile $image.configuration_profile "App configuration profile"
            Assert-Equal $script:appPublicConfiguration.Sha256 $image.public_configuration_sha256 "App public configuration SHA-256"
        }
        $images[$component] = [ordered]@{}
        foreach ($field in $image.Keys) { $images[$component][$field] = $image[$field] }
    }
    return [ordered]@{
        manifest_path = $resolvedManifest
        manifest_sha256 = $manifestHash
        version = $manifest.version
        images = $images
        configuration_profile = $images.app.configuration_profile
        public_configuration_sha256 = $images.app.public_configuration_sha256
    }
}

if (-not (Test-Path -LiteralPath $bashPath -PathType Leaf)) { throw "Git Bash is required at $bashPath." }
$envFiles = @{}
foreach ($component in $componentContract.Keys) {
    $repositoryPath = Join-Path $WorkspacePath $componentContract[$component].Repository
    if (-not (Test-Path -LiteralPath $repositoryPath -PathType Container)) { throw "Repository is missing: $repositoryPath" }
    $envFiles[$component] = Resolve-RepositoryEnvFile $repositoryPath $componentContract[$component].EnvFile
}
$appPublicConfiguration = Get-PublicAppConfiguration $envFiles.app.FullPath
$runtime = Get-ContainerRuntime
$targetCoordinates = Get-TargetCoordinates
$targetRoot = Join-Path $StateRoot $TargetName
$statePath = Join-Path $targetRoot "state.json"
New-Item -ItemType Directory -Path $targetRoot -Force | Out-Null
$lockPath = Join-Path $targetRoot "deployment.lock"
$lock = $null
$operationStartedAt = (Get-Date).ToUniversalTime().ToString("o")
try {
    $lock = [IO.File]::Open($lockPath, [IO.FileMode]::OpenOrCreate, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)
    $state = Read-VerifiedState $statePath
    if ($state) {
        Assert-Equal ([string]$state.schema_version) "1" "Deployment state schema"
        Assert-Equal ([string]$state.target) $TargetName "Deployment state target"
        Assert-Equal ($state.coordinates | ConvertTo-Json -Depth 10 -Compress) ($targetCoordinates | ConvertTo-Json -Depth 10 -Compress) "Deployment target coordinates"
    }
    $startedAt = $operationStartedAt
    if ($Action -eq "Deploy") {
        $candidate = Get-VerifiedCandidate $ManifestPath
        if (-not $state) {
            foreach ($component in $componentContract.Keys) {
                $containerName = $targetCoordinates.components[$component].container
                if (Test-ContainerExists $containerName) { throw "Unrecorded target container already exists: $containerName" }
            }
        }
        foreach ($component in $componentContract.Keys) {
            $image = $candidate.images[$component]
            $existingId = Get-LocalImageId $image.image_ref -AllowMissing
            if ($existingId -and $existingId -cne $image.image_id) { throw "$component candidate tag already points to a different local image identity." }
        }
        foreach ($component in $componentContract.Keys) {
            $image = $candidate.images[$component]
            if (-not (Get-LocalImageId $image.image_ref -AllowMissing)) {
                Import-Image (Join-Path (Join-Path (Split-Path $candidate.manifest_path) "artifacts") $image.artifact)
            }
            Assert-Equal (Get-LocalImageId $image.image_ref) $image.image_id "$component loaded image identity"
        }
        $previous = if ($state) { $state.current } else { $null }
        Start-Deployment $candidate $previous
        $rollbackCandidate = if ($state -and $state.current.manifest_sha256 -cne $candidate.manifest_sha256) { $state.current } elseif ($state) { $state.rollback_candidate } else { $null }
        $newState = [ordered]@{
            schema_version = 1; target = $TargetName; coordinates = $targetCoordinates; current = $candidate; rollback_candidate = $rollbackCandidate
            last_action = "deploy"; updated_at = (Get-Date).ToUniversalTime().ToString("o")
        }
        Write-State $statePath $newState
        $effective = $candidate
        $result = if ($state -and $state.current.manifest_sha256 -ceq $candidate.manifest_sha256) { "already-current" } else { "deployed" }
    }
    else {
        if (-not $state) { throw "No verified deployment state exists for target '$TargetName'." }
        if (-not $state.rollback_candidate) {
            if ($state.last_action -eq "rollback") {
                Write-Output "Rollback is already effective for target '$TargetName'."
                exit 0
            }
            throw "No previously recorded deployment identity is available for rollback."
        }
        $rollback = $state.rollback_candidate
        Start-Deployment $rollback $state.current
        $newState = [ordered]@{
            schema_version = 1; target = $TargetName; coordinates = $targetCoordinates; current = $rollback; rollback_candidate = $null
            last_action = "rollback"; updated_at = (Get-Date).ToUniversalTime().ToString("o")
        }
        Write-State $statePath $newState
        $effective = $rollback
        $result = "rolled-back"
    }
    $evidence = [ordered]@{
        schema_version = 1
        target = $TargetName
        action = $Action.ToLowerInvariant()
        result = $result
        requested_manifest_sha256 = if ($Action -eq "Deploy") { $candidate.manifest_sha256 } else { $state.rollback_candidate.manifest_sha256 }
        effective_manifest_sha256 = $effective.manifest_sha256
        effective_version = $effective.version
        configuration_profile = $effective.configuration_profile
        public_configuration_sha256 = $effective.public_configuration_sha256
        images = [ordered]@{}
        started_at = $startedAt
        completed_at = (Get-Date).ToUniversalTime().ToString("o")
        database_action = "none"
        secrets_recorded = $false
    }
    foreach ($component in $componentContract.Keys) {
        $evidence.images[$component] = [ordered]@{
            requested = if ($Action -eq "Deploy") { $candidate.images[$component].image_ref } else { $state.rollback_candidate.images[$component].image_ref }
            effective = $effective.images[$component].image_ref
            image_id = $effective.images[$component].image_id
        }
    }
    $evidenceName = "$([DateTime]::UtcNow.ToString('yyyyMMddTHHmmssfffZ'))-$($Action.ToLowerInvariant()).json"
    Write-JsonAtomically (Join-Path $targetRoot $evidenceName) $evidence
    Write-Output "$Action completed for target '$TargetName': $($effective.version) ($($effective.manifest_sha256))."
}
catch {
    $failureEvidence = [ordered]@{
        schema_version = 1
        target = $TargetName
        action = $Action.ToLowerInvariant()
        result = "failed"
        requested_manifest_sha256 = if ($candidate) { $candidate.manifest_sha256 } else { $null }
        started_at = $operationStartedAt
        completed_at = (Get-Date).ToUniversalTime().ToString("o")
        database_action = "none"
        secrets_recorded = $false
        failure = $_.Exception.Message
    }
    $failureName = "$([DateTime]::UtcNow.ToString('yyyyMMddTHHmmssfffZ'))-$($Action.ToLowerInvariant())-failed.json"
    Write-JsonAtomically (Join-Path $targetRoot $failureName) $failureEvidence
    throw
}
finally {
    if ($lock) { $lock.Dispose() }
}
