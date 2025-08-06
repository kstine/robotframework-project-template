#Requires -Version 5.1

<#
.SYNOPSIS
    Verifies Python installation on Windows machine.
.DESCRIPTION
    This script checks for Python installations across multiple locations including:
    - PATH environment variable
    - Program Files directories
    - User AppData directory
    - Windows Registry
    - Python Launcher

    It validates version requirements and provides recommendations.
.PARAMETER MinVersion
    Minimum required Python version (default: 3.12)
.PARAMETER ExactVersion
    Exact Python version required (optional)
.EXAMPLE
    .\verify_python_installation.ps1
.EXAMPLE
    .\verify_python_installation.ps1 -MinVersion "3.11"
.EXAMPLE
    .\verify_python_installation.ps1 -ExactVersion "3.12.10"
#>

param(
    [string]$MinVersion = "3.12",
    [string]$ExactVersion = ""
)

# Set error action preference
$ErrorActionPreference = "Continue"

# Initialize variables
$pythonInstallations = @()
$bestPythonVersion = $null
$bestPythonPath = $null

Write-Host "Checking for Python installations on this Windows machine..." -ForegroundColor Cyan
Write-Host ""

# Function to get Python version from executable
function Get-PythonVersion {
    param([string]$PythonPath)

    try {
        $versionOutput = & $PythonPath --version 2>$null
        if ($versionOutput -match "Python (\d+\.\d+\.\d+)") {
            return $matches[1]
        }
    }
    catch {
        return $null
    }
    return $null
}

# Function to compare version strings
function Compare-Version {
    param([string]$Version1, [string]$Version2)

    $v1 = [System.Version]::Parse($Version1)
    $v2 = [System.Version]::Parse($Version2)
    return $v1.CompareTo($v2)
}

# Function to check Python installation
function Test-PythonInstallation {
    param([string]$PythonPath)

    if (Test-Path $PythonPath) {
        $version = Get-PythonVersion -PythonPath $PythonPath
        if ($version) {
            $installation = [PSCustomObject]@{
                Path = $PythonPath
                Version = $version
            }
            $script:pythonInstallations += $installation
            Write-Host "[FOUND] Python $version at $PythonPath" -ForegroundColor Green
            return $installation
        }
    }
    return $null
}

# Check Python installations from PATH
Write-Host "[INFO] Checking Python installations in PATH..." -ForegroundColor Yellow
$pythonCommands = @("python", "python3")
foreach ($cmd in $pythonCommands) {
    $paths = Get-Command $cmd -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
    foreach ($path in $paths) {
        Test-PythonInstallation -PythonPath $path
    }
}

# Check Python installations in Program Files
Write-Host "[INFO] Checking Python installations in Program Files..." -ForegroundColor Yellow
$programFilesPaths = @(
    "C:\Program Files\Python*",
    "C:\Program Files (x86)\Python*"
)

foreach ($basePath in $programFilesPaths) {
    if (Test-Path $basePath) {
        Get-ChildItem -Path $basePath -Directory | ForEach-Object {
            $pythonExe = Join-Path $_.FullName "python.exe"
            Test-PythonInstallation -PythonPath $pythonExe
        }
    }
}

# Check Python installations in user directory
Write-Host "[INFO] Checking Python installations in user directory..." -ForegroundColor Yellow
$userPythonPath = Join-Path $env:USERPROFILE "AppData\Local\Programs\Python*"
if (Test-Path $userPythonPath) {
    Get-ChildItem -Path $userPythonPath -Directory | ForEach-Object {
        $pythonExe = Join-Path $_.FullName "python.exe"
        Test-PythonInstallation -PythonPath $pythonExe
    }
}

# Check Windows Registry for Python installations
Write-Host "[INFO] Checking Windows Registry for Python installations..." -ForegroundColor Yellow
$registryPaths = @(
    "HKLM:\SOFTWARE\Python\PythonCore",
    "HKCU:\SOFTWARE\Python\PythonCore"
)

foreach ($regPath in $registryPaths) {
    if (Test-Path $regPath) {
        Get-ChildItem -Path $regPath -Recurse | ForEach-Object {
            $installPath = Get-ItemProperty -Path $_.PSPath -Name "InstallPath" -ErrorAction SilentlyContinue
            if ($installPath) {
                $pythonExe = Join-Path $installPath.InstallPath "python.exe"
                Test-PythonInstallation -PythonPath $pythonExe
            }
        }
    }
}

# Check for Python Launcher
Write-Host "[INFO] Checking Python Launcher installations..." -ForegroundColor Yellow
$pyLauncherPath = "C:\Windows\py.exe"
if (Test-Path $pyLauncherPath) {
    Write-Host "[FOUND] Python Launcher found at $pyLauncherPath" -ForegroundColor Green
    Write-Host "[INFO] Available Python versions via launcher:" -ForegroundColor Yellow
    try {
        & $pyLauncherPath --list 2>$null
    }
    catch {
        Write-Host "Unable to list Python versions via launcher" -ForegroundColor Red
    }
    Write-Host ""
}

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SUMMARY OF PYTHON INSTALLATIONS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($pythonInstallations.Count -eq 0) {
    Write-Host "[ERROR] No Python installations found on this machine." -ForegroundColor Red
    Write-Host "[INFO] Please install Python $MinVersion or higher from https://www.python.org/downloads/" -ForegroundColor Yellow
    exit 1
}
else {
    Write-Host "[INFO] Found $($pythonInstallations.Count) Python installation(s)" -ForegroundColor Green

    # Find the best Python version (highest that meets minimum requirement)
    $validInstallations = $pythonInstallations | Where-Object {
        (Compare-Version -Version1 $_.Version -Version2 $MinVersion) -ge 0
    }

    if ($validInstallations) {
        $bestInstallation = $validInstallations | Sort-Object Version -Descending | Select-Object -First 1
        $script:bestPythonVersion = $bestInstallation.Version
        $script:bestPythonPath = $bestInstallation.Path
        Write-Host "[BEST] Recommended Python version: $bestPythonVersion at $bestPythonPath" -ForegroundColor Green
    }
}

# Validate version requirements
if ($bestPythonVersion) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "VERSION VERIFICATION" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan

    # Check minimum version requirement
    if ((Compare-Version -Version1 $bestPythonVersion -Version2 $MinVersion) -lt 0) {
        Write-Host "[WARNING] Best Python version $bestPythonVersion is below minimum required $MinVersion.x" -ForegroundColor Yellow
        Write-Host "[INFO] Consider upgrading to Python $MinVersion or higher for optimal compatibility." -ForegroundColor Yellow
        exit 1
    }
    else {
        Write-Host "[OK] Best Python version $bestPythonVersion meets minimum requirement of $MinVersion.x" -ForegroundColor Green
    }

    # Check exact version requirement if specified
    if ($ExactVersion) {
        Write-Host ""
        Write-Host "[INFO] Checking for exact Python version: $ExactVersion" -ForegroundColor Yellow

        $exactInstallation = $pythonInstallations | Where-Object { $_.Version -eq $ExactVersion } | Select-Object -First 1

        if ($exactInstallation) {
            Write-Host "[OK] Exact Python version $ExactVersion found at $($exactInstallation.Path)" -ForegroundColor Green
            Write-Host "[INFO] Using exact version for optimal compatibility." -ForegroundColor Green
        }
        else {
            Write-Host "[ERROR] Exact Python version $ExactVersion not found on this machine." -ForegroundColor Red
            Write-Host "[INFO] Found versions: $($pythonInstallations.Version -join ', ')" -ForegroundColor Yellow
            Write-Host "[INFO] Please install Python $ExactVersion for exact compatibility." -ForegroundColor Yellow
            $downloadVersion = $ExactVersion -replace '\.', '-'
            Write-Host "[INFO] Download from: https://www.python.org/downloads/release/python-$downloadVersion/" -ForegroundColor Yellow
            exit 1
        }
    }
}

Write-Host ""
Write-Host "All Python installations have been checked." -ForegroundColor Green
exit 0