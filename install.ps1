# Navim - Terminal Web Browser Installer for Windows
# https://github.com/politikl/navim

$ErrorActionPreference = "Stop"

$Repo = "politikl/navim"
$InstallDir = "$env:USERPROFILE\.local\bin"

# Display banner
Write-Host ""
Write-Host "                    _            " -ForegroundColor Cyan
Write-Host "  _ __   __ ___   _(_)_ __ ___   " -ForegroundColor Cyan
Write-Host " | '_ \ / _`` \ \ / / | '_ `` _ \  " -ForegroundColor Cyan
Write-Host " | | | | (_| |\ V /| | | | | | | " -ForegroundColor Cyan
Write-Host " |_| |_|\__,_| \_/ |_|_| |_| |_| " -ForegroundColor Cyan
Write-Host ""
Write-Host "Terminal Web Browser" -ForegroundColor White
Write-Host "https://github.com/politikl/navim" -ForegroundColor Gray
Write-Host ""

# Detect architecture
$Arch = if ([Environment]::Is64BitOperatingSystem) { "x86_64" } else { "i686" }
$Target = "$Arch-pc-windows-msvc"

Write-Host "System:  " -ForegroundColor Blue -NoNewline
Write-Host "Windows ($Arch)"
Write-Host "Target:  " -ForegroundColor Blue -NoNewline
Write-Host "$Target"
Write-Host ""

# Get latest release
Write-Host "Fetching latest release..." -ForegroundColor Yellow
$LatestRelease = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/latest"
$Latest = $LatestRelease.tag_name

if (-not $Latest) {
    Write-Host "Error: Failed to fetch latest release" -ForegroundColor Red
    exit 1
}

Write-Host "Version: " -ForegroundColor Blue -NoNewline
Write-Host "$Latest"
Write-Host ""

# Download binary
$DownloadUrl = "https://github.com/$Repo/releases/download/$Latest/navim-$Target.exe"
Write-Host "Downloading navim..." -ForegroundColor Yellow

# Create install directory
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

# Download
$OutputPath = "$InstallDir\navim.exe"
try {
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $OutputPath
    Write-Host "Download complete!" -ForegroundColor Green
} catch {
    Write-Host "Error: Download failed" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  Installation Successful!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Location: " -ForegroundColor Blue -NoNewline
Write-Host "$OutputPath"
Write-Host ""

# Check if in PATH
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($UserPath -like "*$InstallDir*") {
    Write-Host "$InstallDir is already in your PATH" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "Add to PATH" -ForegroundColor Yellow
    Write-Host "---------------------------------------------" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Option 1: Run this command (recommended):" -ForegroundColor White
    Write-Host ""
    Write-Host "  [Environment]::SetEnvironmentVariable('Path', `$env:Path + ';$InstallDir', 'User')" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Option 2: Manual setup:" -ForegroundColor White
    Write-Host ""
    Write-Host "  1. Press " -NoNewline
    Write-Host "Win + X" -ForegroundColor Cyan -NoNewline
    Write-Host ", select 'System'"
    Write-Host "  2. Click 'Advanced system settings'"
    Write-Host "  3. Click 'Environment Variables'"
    Write-Host "  4. Under 'User variables', select 'Path' and click 'Edit'"
    Write-Host "  5. Click 'New' and add: " -NoNewline
    Write-Host "$InstallDir" -ForegroundColor Cyan
    Write-Host "  6. Click OK and restart your terminal"
    Write-Host ""
}

Write-Host "Usage" -ForegroundColor Yellow
Write-Host "---------------------------------------------" -ForegroundColor Yellow
Write-Host ""
Write-Host "  navim <query>" -ForegroundColor Cyan -NoNewline
Write-Host "      Search the web"
Write-Host "  navim about" -ForegroundColor Cyan -NoNewline
Write-Host "        Show about information"
Write-Host "  navim -h" -ForegroundColor Cyan -NoNewline
Write-Host "           View browsing history"
Write-Host ""

Write-Host "Examples" -ForegroundColor Yellow
Write-Host "---------------------------------------------" -ForegroundColor Yellow
Write-Host ""
Write-Host "  navim rust programming" -ForegroundColor Cyan
Write-Host "  navim how to exit vim" -ForegroundColor Cyan
Write-Host "  navim kubernetes pod restart" -ForegroundColor Cyan
Write-Host ""

Write-Host "Keybindings" -ForegroundColor Yellow
Write-Host "---------------------------------------------" -ForegroundColor Yellow
Write-Host ""
Write-Host "  i" -ForegroundColor White -NoNewline
Write-Host "          Enter insert/browse mode"
Write-Host "  Esc" -ForegroundColor White -NoNewline
Write-Host "        Return to normal mode"
Write-Host "  j/k" -ForegroundColor White -NoNewline
Write-Host "        Navigate up/down"
Write-Host "  Enter" -ForegroundColor White -NoNewline
Write-Host "      Open selected result"
Write-Host "  q" -ForegroundColor White -NoNewline
Write-Host "          Quit / Go back"
Write-Host ""

Write-Host "Enjoy using Navim!" -ForegroundColor Green
Write-Host ""
