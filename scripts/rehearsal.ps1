param(
    [ValidateSet("all", "mongodb", "mysql")]
    [string]$Database = "all",
    [switch]$KeepWorktrees
)

$ErrorActionPreference = "Stop"
$specPath = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$workspacePath = (Resolve-Path (Join-Path $specPath "..")).Path
$bashPath = "C:\Program Files\Git\bin\bash.exe"
$opensslPath = "C:\Program Files\Git\mingw64\bin\openssl.exe"
$runId = (Get-Date).ToUniversalTime().ToString("yyyyMMddTHHmmssZ") + "-" + ([Guid]::NewGuid().ToString("N").Substring(0, 8))
$worktreeRoot = Join-Path $specPath ".rehearsal-worktrees\$runId"
$evidenceRoot = Join-Path $specPath ".artifacts\rehearsal\$runId"
$createdWorktrees = [System.Collections.Generic.List[object]]::new()
$active = @{}

function Assert-LastExit([string]$operation) {
    if ($LASTEXITCODE -ne 0) { throw "$operation failed with exit code $LASTEXITCODE." }
}

function Invoke-GitBash([string]$workingDirectory, [string]$script, [hashtable]$environment = @{}) {
    $saved = @{}
    foreach ($entry in $environment.GetEnumerator()) {
        $saved[$entry.Key] = [Environment]::GetEnvironmentVariable($entry.Key, "Process")
        [Environment]::SetEnvironmentVariable($entry.Key, [string]$entry.Value, "Process")
    }
    Push-Location $workingDirectory
    try {
        & $bashPath -lc $script
        Assert-LastExit $script
    }
    finally {
        Pop-Location
        foreach ($entry in $saved.GetEnumerator()) {
            [Environment]::SetEnvironmentVariable($entry.Key, $entry.Value, "Process")
        }
    }
}

function Set-EnvValue([string]$path, [string]$key, [string]$value) {
    $lines = [System.Collections.Generic.List[string]](Get-Content -LiteralPath $path)
    $matched = $false
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match "^$([regex]::Escape($key))=") {
            $lines[$i] = "$key=$value"
            $matched = $true
        }
    }
    if (-not $matched) { $lines.Add("$key=$value") }
    Set-Content -LiteralPath $path -Value $lines -Encoding utf8NoBOM
}

function New-CleanWorktree([string]$repositoryName) {
    $source = Join-Path $workspacePath $repositoryName
    $target = Join-Path $worktreeRoot $repositoryName
    $commit = (& git -C $source rev-parse HEAD).Trim()
    Assert-LastExit "Resolve $repositoryName HEAD"
    New-Item -ItemType Directory -Path (Split-Path $target) -Force | Out-Null
    & git -C $source worktree add --detach $target $commit | Out-Host
    Assert-LastExit "Create $repositoryName clean worktree"
    $createdWorktrees.Add([pscustomobject]@{ Source = $source; Target = $target; Commit = $commit; Name = $repositoryName })
    return $target
}

function Wait-Http([string]$url, [switch]$SkipCertificateCheck) {
    for ($attempt = 0; $attempt -lt 60; $attempt++) {
        try {
            $params = @{ Uri = $url; TimeoutSec = 5; UseBasicParsing = $true }
            if ($SkipCertificateCheck) { $params.SkipCertificateCheck = $true }
            $response = Invoke-WebRequest @params
            if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 400) { return }
        }
        catch { Start-Sleep -Seconds 2 }
    }
    throw "HTTP readiness timed out: $url"
}

function Stop-Profile {
    if ($active.Ingress) { & docker rm -f $active.Ingress *> $null; $active.Ingress = $null }
    foreach ($item in @(@{Path=$active.Website; Script="scripts/stop.sh"}, @{Path=$active.App; Script="scripts/stop.sh"}, @{Path=$active.Server; Script="scripts/stop.sh"})) {
        if ($item.Path) {
            try { Invoke-GitBash $item.Path $item.Script @{ ENV_FILE = ".env.rehearsal" } } catch { Write-Warning $_ }
        }
    }
    if ($active.Server -and $active.Engine) {
        try { Invoke-GitBash $active.Server "scripts/dependencies/$($active.Engine)/stop.sh" @{ ENV_FILE = ".env.rehearsal" } } catch { Write-Warning $_ }
    }
    foreach ($volume in @($active.Volume)) {
        if ($volume -and $volume -match '^cashlenx-rehearsal-[a-z0-9-]+$') { & docker volume rm $volume *> $null }
    }
    if ($active.Network -and $active.Network -match '^cashlenx-rehearsal-[a-z0-9-]+$') { & docker network rm $active.Network *> $null }
    $script:active = @{}
}

function Invoke-Profile([string]$engine, [string]$appPath, [string]$serverPath, [string]$websitePath, [int]$basePort) {
    $suffix = "$engine-$($runId.ToLower() -replace '[^a-z0-9]','-')"
    $network = "cashlenx-rehearsal-$suffix"
    $serverContainer = "cashlenx-rehearsal-server-$suffix"
    $appContainer = "cashlenx-rehearsal-app-$suffix"
    $websiteContainer = "cashlenx-rehearsal-website-$suffix"
    $databaseContainer = "cashlenx-rehearsal-$engine-$suffix"
    $ingressContainer = "cashlenx-rehearsal-ingress-$suffix"
    $volume = "cashlenx-rehearsal-$engine-data-$suffix"
    $serverPort, $appPort, $websitePort, $ingressPort = $basePort, ($basePort + 1), ($basePort + 2), ($basePort + 3)
    $dbName = "cashlenx_rehearsal_$($runId -replace '[^A-Za-z0-9]','_')"
    $jwt = -join ((1..64) | ForEach-Object { '{0:x}' -f (Get-Random -Maximum 16) })
    $adminPassword = "Rehearsal-$([Guid]::NewGuid().ToString('N'))!"
    $dbPassword = [Guid]::NewGuid().ToString("N") + [Guid]::NewGuid().ToString("N")
    $backupKey = Join-Path $serverPath ".env.rehearsal-backup-key"
    Set-Content -LiteralPath $backupKey -Value ([Guid]::NewGuid().ToString("N") + [Guid]::NewGuid().ToString("N")) -Encoding utf8NoBOM

    $serverEnv = Join-Path $serverPath ".env.rehearsal"
    Copy-Item (Join-Path $serverPath ".env.example") $serverEnv
    $serverSettings = @{
        ENV="prod"; SERVER_PORT="$serverPort"; DB_TYPE=$engine; DB_NAME=$dbName; JWT_SECRET=$jwt;
        ADMIN_USERNAME="rehearsal-admin"; ADMIN_PASSWORD=$adminPassword; CORS_ORIGINS="https://rehearsal.cashlenx.invalid:$ingressPort";
        METRICS_ENABLED="false"; DOCKER_NETWORK_NAME=$network; SERVER_PROJECT_NAME="cashlenx-rehearsal-server-$suffix";
        BACKEND_CONTAINER_NAME=$serverContainer; SERVER_IMAGE_NAME="cashlenx-rehearsal-server"; SERVER_IMAGE_TAG=$runId;
        SERVER_LOG_PATH="./logs/rehearsal-$suffix"; MONGO_CONTAINER_NAME=$databaseContainer; MYSQL_CONTAINER_NAME=$databaseContainer;
        MONGO_PROJECT_NAME="cashlenx-rehearsal-mongodb-$suffix"; MYSQL_PROJECT_NAME="cashlenx-rehearsal-mysql-$suffix";
        MONGO_ROOT_USERNAME="rehearsal"; MONGO_ROOT_PASSWORD=$dbPassword; MYSQL_ROOT_PASSWORD=$dbPassword;
        MYSQL_USER="rehearsal"; MYSQL_PASSWORD=$dbPassword; MONGO_DATA_VOLUME_NAME=$volume; MYSQL_DATA_VOLUME_NAME=$volume;
        BACKUP_ROOT="./backups/rehearsal-$suffix"; BACKUP_ENCRYPTION_KEY_FILE="./.env.rehearsal-backup-key"; BACKUP_MIN_FREE_MIB="1"
    }
    foreach ($entry in $serverSettings.GetEnumerator()) { Set-EnvValue $serverEnv $entry.Key $entry.Value }

    $appEnv = Join-Path $appPath ".env.rehearsal"
    Copy-Item (Join-Path $appPath ".env.example") $appEnv
    $appSettings = @{ APP_ENV="prod"; API_SCHEME="https"; API_DOMAIN="rehearsal.cashlenx.invalid"; API_PORT="$ingressPort"; DOCKER_NETWORK_NAME=$network;
        APP_PROJECT_NAME="cashlenx-rehearsal-app-$suffix"; CONTAINER_NAME=$appContainer; IMAGE_NAME="cashlenx-rehearsal-app"; IMAGE_TAG=$runId; WEB_PORT="$appPort" }
    foreach ($entry in $appSettings.GetEnumerator()) { Set-EnvValue $appEnv $entry.Key $entry.Value }

    $websiteEnv = Join-Path $websitePath ".env.rehearsal"
    Copy-Item (Join-Path $websitePath ".env.example") $websiteEnv
    $websiteSettings = @{ DOCKER_NETWORK_NAME=$network; WEBSITE_PROJECT_NAME="cashlenx-rehearsal-website-$suffix";
        WEBSITE_CONTAINER_NAME=$websiteContainer; WEBSITE_IMAGE_NAME="cashlenx-rehearsal-website"; WEBSITE_IMAGE_TAG=$runId; WEBSITE_PORT="$websitePort" }
    foreach ($entry in $websiteSettings.GetEnumerator()) { Set-EnvValue $websiteEnv $entry.Key $entry.Value }

    $script:active = @{ Engine=$engine; Server=$serverPath; App=$appPath; Website=$websitePath; Network=$network; Volume=$volume; Ingress=$null }
    try {
        Invoke-GitBash $serverPath "scripts/build.sh" @{ ENV_FILE=".env.rehearsal" }
        Invoke-GitBash $appPath "scripts/build.sh" @{ ENV_FILE=".env.rehearsal" }
        Invoke-GitBash $websitePath "scripts/build.sh" @{ ENV_FILE=".env.rehearsal" }
        Invoke-GitBash $serverPath "scripts/dependencies/$engine/build.sh" @{ ENV_FILE=".env.rehearsal" }
        Invoke-GitBash $serverPath "scripts/dependencies/$engine/start.sh" @{ ENV_FILE=".env.rehearsal" }
        Invoke-GitBash $serverPath "scripts/start.sh" @{ ENV_FILE=".env.rehearsal" }
        Invoke-GitBash $appPath "scripts/start.sh" @{ ENV_FILE=".env.rehearsal" }
        Invoke-GitBash $websitePath "scripts/start.sh" @{ ENV_FILE=".env.rehearsal" }

        $ingressDir = Join-Path $worktreeRoot "ingress-$engine"
        New-Item -ItemType Directory -Path $ingressDir -Force | Out-Null
        & $opensslPath req -x509 -newkey rsa:2048 -sha256 -nodes -days 2 -subj "/CN=localhost" -keyout (Join-Path $ingressDir "tls.key") -out (Join-Path $ingressDir "tls.crt") *> $null
        Assert-LastExit "Generate rehearsal TLS certificate"
        $nginx = @"
events {}
http { server { listen 443 ssl; ssl_certificate /etc/rehearsal/tls.crt; ssl_certificate_key /etc/rehearsal/tls.key;
location /api/ { proxy_pass http://${serverContainer}:${serverPort}; }
location /website/ { proxy_pass http://${websiteContainer}:8080/; }
location / { proxy_pass http://${appContainer}:8080; } } }
"@
        Set-Content -LiteralPath (Join-Path $ingressDir "nginx.conf") -Value $nginx -Encoding utf8NoBOM
        $nginxImage = ((Get-Content (Join-Path $appPath "docker/images.env") | Where-Object { $_ -like "NGINX_IMAGE=*" }) -replace '^NGINX_IMAGE=','')
        & docker run --detach --rm --name $ingressContainer --network $network -p "127.0.0.1:${ingressPort}:443" `
            -v "${ingressDir}:/etc/rehearsal:ro" -v "$(Join-Path $ingressDir 'nginx.conf'):/etc/nginx/nginx.conf:ro" $nginxImage *> $null
        Assert-LastExit "Start local TLS ingress"
        $script:active.Ingress = $ingressContainer

        Wait-Http "https://127.0.0.1:$ingressPort/" -SkipCertificateCheck
        Wait-Http "https://127.0.0.1:$ingressPort/website/" -SkipCertificateCheck
        Wait-Http "https://127.0.0.1:$ingressPort/api/v0/open/health" -SkipCertificateCheck

        $smokeUser = "rehearsal_$($engine)_$($runId -replace '[^A-Za-z0-9]','')"
        Invoke-GitBash $serverPath "test/scripts/api-smoke.sh" @{
            BASE_URL="http://127.0.0.1:$serverPort/api/v0"; ADMIN_USERNAME="rehearsal-admin"; ADMIN_PASSWORD=$adminPassword;
            SMOKE_USERNAME=$smokeUser; SMOKE_PASSWORD="RehearsalUserPass123!"; SMOKE_NEW_PASSWORD="RehearsalUserPass456!"
        }

        & docker restart $databaseContainer *> $null
        Assert-LastExit "Restart $engine"
        Start-Sleep -Seconds 5
        Wait-Http "https://127.0.0.1:$ingressPort/api/v0/open/health" -SkipCertificateCheck
        $loginBody = @{ username=$smokeUser; password="RehearsalUserPass456!"; device_id="rehearsal-persistence"; device_name="Rehearsal" } | ConvertTo-Json -Compress
        $login = Invoke-RestMethod -Uri "https://127.0.0.1:$ingressPort/api/v0/open/auth/login" -Method Post -ContentType "application/json" -Body $loginBody -SkipCertificateCheck
        if ($login.code -ne 200 -or -not $login.data.access_token) { throw "$engine persistence login failed after database restart." }

        Invoke-GitBash $serverPath "scripts/data-protection/backup.sh daily" @{ ENV_FILE=".env.rehearsal" }
        $backup = Get-ChildItem (Join-Path $serverPath "backups/rehearsal-$suffix/daily") -Filter "*.tar.gz.enc" | Select-Object -First 1
        $backupRelative = $backup.FullName.Substring($serverPath.Length + 1).Replace('\','/')
        Invoke-GitBash $serverPath "scripts/data-protection/restore-drill.sh '$backupRelative'" @{ ENV_FILE=".env.rehearsal" }

        $images = @{}
        foreach ($name in @("cashlenx-rehearsal-server:$runId", "cashlenx-rehearsal-app:$runId", "cashlenx-rehearsal-website:$runId")) {
            $images[$name] = (& docker image inspect --format '{{.Id}}' $name).Trim(); Assert-LastExit "Inspect $name"
        }
        $manifest = [ordered]@{
            schema_version=1; run_id=$runId; database=$engine; result="passed"; completed_at=(Get-Date).ToUniversalTime().ToString("o");
            commits=[ordered]@{ app=(& git -C $appPath rev-parse HEAD).Trim(); server=(& git -C $serverPath rev-parse HEAD).Trim(); website=(& git -C $websitePath rev-parse HEAD).Trim(); spec=(& git -C $specPath rev-parse HEAD).Trim() };
            images=$images; checks=[ordered]@{ ingress=$true; health=$true; api_smoke=$true; database_restart=$true; persistence=$true; encrypted_backup=$true; disposable_restore=$true };
            delivery_actions=@(); secrets_recorded=$false
        }
        $manifestPath = Join-Path $evidenceRoot "manifest-$engine.json"
        $manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $manifestPath -Encoding utf8NoBOM
        $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $manifestPath).Hash.ToLowerInvariant()
        Set-Content -LiteralPath "$manifestPath.sha256" -Value "$hash  $([IO.Path]::GetFileName($manifestPath))" -Encoding ascii
    }
    finally { Stop-Profile }
}

try {
    foreach ($required in @("git", "docker")) { if (-not (Get-Command $required -ErrorAction SilentlyContinue)) { throw "$required is required." } }
    if (-not (Test-Path -LiteralPath $bashPath)) { throw "Git Bash is required at $bashPath" }
    if (-not (Test-Path -LiteralPath $opensslPath)) { throw "Git OpenSSL is required at $opensslPath" }
    New-Item -ItemType Directory -Path $worktreeRoot, $evidenceRoot -Force | Out-Null
    $appPath = New-CleanWorktree "cashlenx-app"
    $serverPath = New-CleanWorktree "cashlenx-server"
    $websitePath = New-CleanWorktree "cashlenx-website"

    $targets = if ($Database -eq "all") { @("mongodb", "mysql") } else { @($Database) }
    $port = 24000 + (Get-Random -Maximum 10000)
    foreach ($target in $targets) { Invoke-Profile $target $appPath $serverPath $websitePath $port }
    Write-Host "Production-like rehearsal passed. Evidence: $evidenceRoot"
}
finally {
    Stop-Profile
    if (-not $KeepWorktrees) {
        for ($index = $createdWorktrees.Count - 1; $index -ge 0; $index--) {
            $worktree = $createdWorktrees[$index]
            & git -C $worktree.Source worktree remove --force $worktree.Target *> $null
        }
        if (Test-Path -LiteralPath $worktreeRoot) { Remove-Item -LiteralPath $worktreeRoot -Recurse -Force }
    }
}
