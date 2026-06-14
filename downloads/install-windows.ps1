#Requires -Version 5.1
<#
.SYNOPSIS
Build and install jsling on Windows.

.DESCRIPTION
Native PowerShell installer for Windows users. It builds the current
COMPILER_CPP source tree with CMake, installs jsling.exe under a prefix, and
can optionally add the install bin directory to the current user's PATH.

.EXAMPLE
powershell -ExecutionPolicy Bypass -File .\scripts\install-windows.ps1

.EXAMPLE
.\scripts\install-windows.ps1 -Prefix "$env:USERPROFILE\bin\jsling" -AddToPath

.EXAMPLE
.\scripts\install-windows.ps1 -Uninstall
#>

[CmdletBinding()]
param(
    [string]$Prefix = "$env:LOCALAPPDATA\jsling",
    [ValidateSet("Debug", "Release", "RelWithDebInfo", "MinSizeRel")]
    [string]$BuildType = "Release",
    [string]$Generator = "",
    [switch]$AddToPath,
    [switch]$Uninstall
)

$ErrorActionPreference = "Stop"

function Write-Info($Message) {
    Write-Host "info  $Message" -ForegroundColor Blue
}

function Write-Done($Message) {
    Write-Host "done  $Message" -ForegroundColor Green
}

function Write-Warn($Message) {
    Write-Host "warn  $Message" -ForegroundColor Yellow
}

function Fail($Message) {
    Write-Host "error $Message" -ForegroundColor Red
    exit 1
}

function Require-Command($Name, $InstallHint) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        Fail "$Name not found. $InstallHint"
    }
}

function Add-UserPath($Directory) {
    $fullPath = [System.IO.Path]::GetFullPath($Directory)
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $parts = @()
    if ($currentPath) {
        $parts = $currentPath.Split(";") | Where-Object { $_ -ne "" }
    }

    $exists = $false
    foreach ($part in $parts) {
        if ([string]::Equals(
            [System.IO.Path]::GetFullPath($part),
            $fullPath,
            [System.StringComparison]::OrdinalIgnoreCase
        )) {
            $exists = $true
            break
        }
    }

    if ($exists) {
        Write-Info "User PATH already includes $fullPath"
        return
    }

    $newPath = if ($currentPath) { "$currentPath;$fullPath" } else { $fullPath }
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    $env:Path = "$env:Path;$fullPath"
    Write-Done "Added to user PATH: $fullPath"
    Write-Warn "Open a new terminal for PATH changes to appear everywhere."
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectDir = (Resolve-Path (Join-Path $scriptDir "..")).Path
$Prefix = [System.IO.Path]::GetFullPath($Prefix)
$installBin = Join-Path $Prefix "bin"
$exePath = Join-Path $installBin "jsling.exe"

Write-Host ""
Write-Host "jsling Windows installer" -ForegroundColor White
Write-Host "========================="
Write-Host ""

if ($Uninstall) {
    if (Test-Path $exePath) {
        Write-Info "Removing $exePath"
        Remove-Item $exePath -Force
        Write-Done "jsling uninstalled"
    } else {
        Write-Warn "No installation found at $exePath"
    }
    exit 0
}

if (-not (Test-Path (Join-Path $projectDir "CMakeLists.txt"))) {
    Fail "CMakeLists.txt not found in $projectDir"
}

Require-Command "cmake" "Install with: winget install Kitware.CMake"

Write-Info "Source directory: $projectDir"
Write-Info "Install prefix: $Prefix"
Write-Info "Build type: $BuildType"

$buildDir = Join-Path $projectDir "build-windows"
New-Item -ItemType Directory -Force -Path $buildDir | Out-Null
New-Item -ItemType Directory -Force -Path $installBin | Out-Null

$configureArgs = @(
    "-S", $projectDir,
    "-B", $buildDir,
    "-DCMAKE_BUILD_TYPE=$BuildType",
    "-DCMAKE_INSTALL_PREFIX=$Prefix",
    "-DCMAKE_CXX_STANDARD=17"
)

if ($Generator -ne "") {
    $configureArgs = @("-G", $Generator) + $configureArgs
}

Write-Info "Configuring with CMake..."
& cmake @configureArgs
if ($LASTEXITCODE -ne 0) {
    Fail "CMake configuration failed. Install Visual Studio Build Tools, LLVM, or MinGW, then try again."
}

Write-Info "Building jsling..."
& cmake --build $buildDir --config $BuildType
if ($LASTEXITCODE -ne 0) {
    Fail "Build failed"
}

Write-Info "Installing jsling..."
& cmake --install $buildDir --config $BuildType
if ($LASTEXITCODE -ne 0) {
    Fail "Install failed"
}

if (-not (Test-Path $exePath)) {
    Fail "Installed binary not found at $exePath"
}

Write-Done "Installed: $exePath"

$version = & $exePath --version 2>$null
if (-not $version) {
    $version = "unknown"
}

Write-Host ""
Write-Host "jsling installed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "  Binary:  $exePath"
Write-Host "  Version: $version"

if ($AddToPath) {
    Add-UserPath $installBin
} else {
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if (-not $userPath -or -not ($userPath.Split(";") -contains $installBin)) {
        Write-Host ""
        Write-Warn "$installBin is not in your user PATH."
        Write-Host "  Re-run with -AddToPath to add it automatically."
    }
}

Write-Host ""
Write-Host "Quick start:"
Write-Host "  jsling"
Write-Host "  jsling script.js"
Write-Host "  jsling -e `"console.log(1 + 2)`""
Write-Host ""
