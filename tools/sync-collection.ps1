[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('bangumi', 'game')]
    [string]$Collection,

    [string]$Proxy = $env:BLOG_SYNC_PROXY,

    [switch]$AllowEmptyCategory
)

$ErrorActionPreference = 'Stop'

$blogRoot = Split-Path -Parent $PSScriptRoot
$dataFile = Join-Path $blogRoot "source\_data\$($Collection)s.json"
$hexoCommand = Join-Path $blogRoot 'node_modules\.bin\hexo.cmd'
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupDirectory = Join-Path $blogRoot "备份\collection-sync\$timestamp-$Collection"
$backupFile = Join-Path $backupDirectory "$($Collection)s.json"

function Read-CollectionData {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Collection file does not exist: $Path"
    }

    $data = Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json
    foreach ($listName in @('wantWatch', 'watching', 'watched')) {
        if ($null -eq $data.PSObject.Properties[$listName]) {
            throw "Collection file is missing '$listName': $Path"
        }
    }
    return $data
}

function Get-CollectionCounts {
    param($Data)

    $want = @($Data.wantWatch).Count
    $watching = @($Data.watching).Count
    $watched = @($Data.watched).Count
    return [pscustomobject]@{
        WantWatch = $want
        Watching = $watching
        Watched = $watched
        Total = $want + $watching + $watched
    }
}

function Restore-EnvironmentVariable {
    param(
        [string]$Name,
        [AllowNull()][string]$Value
    )

    if ($null -eq $Value) {
        Remove-Item "Env:$Name" -ErrorAction SilentlyContinue
    } else {
        Set-Item "Env:$Name" $Value
    }
}

function Test-ProxyEndpoint {
    param([uri]$ProxyUri)

    $port = if ($ProxyUri.IsDefaultPort) {
        if ($ProxyUri.Scheme -eq 'https') { 443 } else { 80 }
    } else {
        $ProxyUri.Port
    }

    $client = [System.Net.Sockets.TcpClient]::new()
    try {
        $connection = $client.BeginConnect($ProxyUri.Host, $port, $null, $null)
        if (-not $connection.AsyncWaitHandle.WaitOne(2000)) {
            throw "Proxy connection timed out: $($ProxyUri.Host):$port"
        }
        $client.EndConnect($connection)
    } catch {
        throw "Proxy is unavailable at $($ProxyUri.Host):$port"
    } finally {
        $client.Dispose()
    }
}

if (-not (Test-Path -LiteralPath $hexoCommand)) {
    throw "Hexo command was not found: $hexoCommand"
}

$oldData = Read-CollectionData -Path $dataFile
$oldCounts = Get-CollectionCounts -Data $oldData

New-Item -ItemType Directory -Force -Path $backupDirectory | Out-Null
Copy-Item -LiteralPath $dataFile -Destination $backupFile

$previousHttpProxy = $env:HTTP_PROXY
$previousHttpsProxy = $env:HTTPS_PROXY
$previousNoProxy = $env:NO_PROXY
$failure = $null
$newCounts = $null

try {
    if (-not [string]::IsNullOrWhiteSpace($Proxy)) {
        $proxyUri = [uri]$Proxy
        if (-not $proxyUri.IsAbsoluteUri -or $proxyUri.Scheme -notin @('http', 'https')) {
            throw "Only an HTTP proxy URL is supported: $Proxy"
        }

        Test-ProxyEndpoint -ProxyUri $proxyUri
        $env:HTTP_PROXY = $Proxy
        $env:HTTPS_PROXY = $Proxy
        $env:NO_PROXY = 'localhost,127.0.0.1'
        Write-Host "Using proxy: $Proxy"
    }

    & $hexoCommand $Collection '-u'
    if ($LASTEXITCODE -ne 0) {
        throw "Hexo $Collection update failed with exit code $LASTEXITCODE"
    }

    $newData = Read-CollectionData -Path $dataFile
    $newCounts = Get-CollectionCounts -Data $newData

    if ($newCounts.Total -eq 0) {
        throw 'Updated data contains no collection entries'
    }

    if (-not $AllowEmptyCategory) {
        foreach ($property in @('WantWatch', 'Watching', 'Watched')) {
            if ($oldCounts.$property -gt 0 -and $newCounts.$property -eq 0) {
                throw "Updated '$property' category unexpectedly became empty"
            }
        }
    }

    foreach ($item in @($newData.wantWatch) + @($newData.watching) + @($newData.watched)) {
        if ([string]::IsNullOrWhiteSpace([string]$item.id) -or
            [string]::IsNullOrWhiteSpace([string]$item.title)) {
            throw 'Updated data contains an entry without id or title'
        }
    }
} catch {
    $failure = $_
    Copy-Item -LiteralPath $backupFile -Destination $dataFile -Force
} finally {
    Restore-EnvironmentVariable -Name 'HTTP_PROXY' -Value $previousHttpProxy
    Restore-EnvironmentVariable -Name 'HTTPS_PROXY' -Value $previousHttpsProxy
    Restore-EnvironmentVariable -Name 'NO_PROXY' -Value $previousNoProxy
}

if ($failure) {
    Write-Error "Collection update failed; restored $dataFile from $backupFile. $($failure.Exception.Message)"
    exit 1
}

Write-Host (
    "{0} updated successfully: {1}/{2}/{3} -> {4}/{5}/{6} (total {7} -> {8})" -f
    $Collection,
    $oldCounts.WantWatch,
    $oldCounts.Watching,
    $oldCounts.Watched,
    $newCounts.WantWatch,
    $newCounts.Watching,
    $newCounts.Watched,
    $oldCounts.Total,
    $newCounts.Total
)
Write-Host "Backup: $backupFile"
