# Install ULX and ULib for DarkRP Server
# ULX is a popular admin mod for Garry's Mod

param(
    [string]$ServerPath = "$PSScriptRoot\gmod-server"
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ULX/ULib Installation Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if server path exists
if (-not (Test-Path $ServerPath)) {
    Write-Host "Error: Server path not found: $ServerPath" -ForegroundColor Red
    Write-Host "Please run this script from the darkrp directory or specify -ServerPath" -ForegroundColor Yellow
    exit 1
}

$AddonsPath = Join-Path $ServerPath "garrysmod\addons"
$DataPath = Join-Path $ServerPath "garrysmod\data"

# Create directories if they don't exist
if (-not (Test-Path $AddonsPath)) {
    New-Item -ItemType Directory -Path $AddonsPath -Force | Out-Null
}
if (-not (Test-Path $DataPath)) {
    New-Item -ItemType Directory -Path $DataPath -Force | Out-Null
}

Write-Host "Installing ULX and ULib..." -ForegroundColor Yellow
Write-Host ""

# ULX GitHub repository
$ULXUrl = "https://github.com/TeamUlysses/ulx/archive/master.zip"
$ULibUrl = "https://github.com/TeamUlysses/ulib/archive/master.zip"

$TempDir = "$env:TEMP\ulx-install"
if (Test-Path $TempDir) {
    Remove-Item $TempDir -Recurse -Force
}
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

# Function to download and extract
function Download-Extract-Addon {
    param(
        [string]$Url,
        [string]$Name
    )
    
    Write-Host "Downloading $Name..." -ForegroundColor Yellow
    $ZipFile = "$TempDir\$Name.zip"
    
    try {
        Invoke-WebRequest -Uri $Url -OutFile $ZipFile -UseBasicParsing
        Write-Host "Extracting $Name..." -ForegroundColor Yellow
        
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $ExtractPath = "$TempDir\$Name"
        [System.IO.Compression.ZipFile]::ExtractToDirectory($ZipFile, $ExtractPath)
        
        # Find the actual addon folder
        $AddonFolder = Get-ChildItem -Path $ExtractPath -Recurse -Directory | Where-Object { $_.Name -eq $Name -or $_.Name -like "*$Name*" } | Select-Object -First 1
        
        if ($AddonFolder) {
            $TargetPath = Join-Path $AddonsPath $Name
            if (Test-Path $TargetPath) {
                Remove-Item $TargetPath -Recurse -Force
            }
            Copy-Item -Path $AddonFolder.FullName -Destination $TargetPath -Recurse -Force
            Write-Host "$Name installed successfully" -ForegroundColor Green
        }
        else {
            Write-Host "Warning: Could not find $Name folder in extracted files" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Error downloading/extracting $Name : $_" -ForegroundColor Red
    }
}

# Install ULib first (ULX depends on it)
Download-Extract-Addon -Url $ULibUrl -Name "ulib"

# Install ULX
Download-Extract-Addon -Url $ULXUrl -Name "ulx"

# Create ULX users file if it doesn't exist
$ULXUsersPath = Join-Path $DataPath "ulib\users.txt"
$ULibDir = Join-Path $DataPath "ulib"
if (-not (Test-Path $ULibDir)) {
    New-Item -ItemType Directory -Path $ULibDir -Force | Out-Null
}

if (-not (Test-Path $ULXUsersPath)) {
    Write-Host "Creating ULX users file..." -ForegroundColor Yellow
    $UsersContent = @"
"users"
{
	"STEAM_0:0:418798673"
	{
		"group"		"superadmin"
	}
	"STEAM_0:1:457684139"
	{
		"group"		"superadmin"
		"name"		"DiggerNick"
	}
}
"@
    $UsersContent | Out-File -FilePath $ULXUsersPath -Encoding ASCII
    Write-Host "ULX users file created" -ForegroundColor Green
}
else {
    Write-Host "ULX users file already exists" -ForegroundColor Gray
}

# Cleanup
Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "ULX and ULib have been installed." -ForegroundColor Green
Write-Host "Restart your server for changes to take effect." -ForegroundColor Yellow
Write-Host ""
Write-Host "To add more admins:" -ForegroundColor Cyan
Write-Host "1. Edit: $ULXUsersPath" -ForegroundColor Gray
Write-Host "2. Or use in-game: ulx adduser <steamid> superadmin" -ForegroundColor Gray
Write-Host ""

