[CmdletBinding()]
param(
    [switch]$ValidateOnly
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding

$blogRoot = Split-Path -Parent $PSScriptRoot
$hexoCommand = Join-Path $blogRoot 'node_modules\.bin\hexo.cmd'
$syncCommand = Join-Path $PSScriptRoot 'sync-collection.ps1'
$gameProxy = if ([string]::IsNullOrWhiteSpace($env:BLOG_SYNC_PROXY)) {
    'http://127.0.0.1:7890'
} else {
    $env:BLOG_SYNC_PROXY
}

function Write-Step {
    param(
        [int]$Number,
        [string]$Message
    )

    Write-Host ''
    Write-Host "[$Number/8] $Message"
}

function Invoke-ExternalCommand {
    param(
        [string]$FilePath,
        [string[]]$Arguments
    )

    & $FilePath @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "$FilePath failed with exit code $LASTEXITCODE"
    }
}

try {
    Set-Location $blogRoot

    if (-not (Test-Path -LiteralPath $hexoCommand)) {
        throw "Hexo command was not found: $hexoCommand"
    }
    if (-not (Test-Path -LiteralPath $syncCommand)) {
        throw "Collection sync script was not found: $syncCommand"
    }

    if ($ValidateOnly -or $env:HEXO_DEPLOY_VALIDATE_ONLY -eq '1') {
        Write-Host 'Deployment launcher validation succeeded.'
        exit 0
    }

    Write-Host '======================================================='
    Write-Host '             Hexo Blog Deployment v3.4'
    Write-Host '======================================================='

    Write-Step -Number 1 -Message 'Updating post timestamps...'
    Invoke-ExternalCommand -FilePath 'python.exe' -Arguments @('update.py')

    Write-Step -Number 2 -Message 'Cleaning generated files...'
    Invoke-ExternalCommand -FilePath $hexoCommand -Arguments @('clean')

    Write-Step -Number 3 -Message 'Refreshing Douban books...'
    Invoke-ExternalCommand -FilePath $hexoCommand -Arguments @('douban', '-b')

    Write-Step -Number 4 -Message 'Refreshing Bilibili bangumis...'
    Invoke-ExternalCommand -FilePath 'powershell.exe' -Arguments @(
        '-NoProfile',
        '-ExecutionPolicy', 'Bypass',
        '-File', $syncCommand,
        '-Collection', 'bangumi'
    )

    Write-Step -Number 5 -Message "Refreshing Bangumi games through $gameProxy..."
    Invoke-ExternalCommand -FilePath 'powershell.exe' -Arguments @(
        '-NoProfile',
        '-ExecutionPolicy', 'Bypass',
        '-File', $syncCommand,
        '-Collection', 'game',
        '-Proxy', $gameProxy
    )

    Write-Step -Number 6 -Message 'Generating the static site...'
    Invoke-ExternalCommand -FilePath $hexoCommand -Arguments @('generate')

    Write-Step -Number 7 -Message 'Deploying GitHub Pages...'
    Invoke-ExternalCommand -FilePath $hexoCommand -Arguments @('deploy')

    Write-Step -Number 8 -Message 'Backing up source code to the hexo branch...'
    Invoke-ExternalCommand -FilePath 'git.exe' -Arguments @('add', '--all')

    & git.exe diff --cached --quiet
    $diffExitCode = $LASTEXITCODE
    if ($diffExitCode -eq 1) {
        $commitMessage = "Site Update: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        Invoke-ExternalCommand -FilePath 'git.exe' -Arguments @('commit', '-m', $commitMessage)
    } elseif ($diffExitCode -gt 1) {
        throw "git diff failed with exit code $diffExitCode"
    } else {
        Write-Host 'No source changes to commit.'
    }

    Invoke-ExternalCommand -FilePath 'git.exe' -Arguments @('push', 'origin', 'hexo')

    Write-Host ''
    Write-Host '======================================================='
    Write-Host ' SUCCESS: deploy and source backup completed.'
    Write-Host '======================================================='
    exit 0
} catch {
    Write-Host ''
    Write-Host '=======================================================' -ForegroundColor Red
    Write-Host " FAILED: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ' The workflow stopped before the next step.' -ForegroundColor Red
    Write-Host '=======================================================' -ForegroundColor Red
    exit 1
}
