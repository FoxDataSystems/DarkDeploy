# Download Standard DarkRP Content
# Downloads the rp_downtown_v2 map and DarkRP Mod Collection

param(
    [string]$ServerPath = ".\gmod-server",
    [string]$SteamCMDPath = ".\steamcmd"
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Downloading Standard DarkRP Content" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Normalize paths
if (-not ([System.IO.Path]::IsPathRooted($ServerPath))) {
    $ServerPath = [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $ServerPath))
}
if (Test-Path $ServerPath) {
    $ServerPath = (Resolve-Path $ServerPath).Path
}

if (-not ([System.IO.Path]::IsPathRooted($SteamCMDPath))) {
    $SteamCMDPath = [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $SteamCMDPath))
}
if (Test-Path $SteamCMDPath) {
    $SteamCMDPath = (Resolve-Path $SteamCMDPath).Path
}

$SteamCMDExe = Join-Path $SteamCMDPath "steamcmd.exe"

# Check if SteamCMD exists
if (-not (Test-Path $SteamCMDExe)) {
    Write-Host "Error: steamcmd.exe not found at: $SteamCMDExe" -ForegroundColor Red
    Write-Host "Please run the setup script first to install SteamCMD." -ForegroundColor Yellow
    exit 1
}

# Workshop IDs
$DarkRPCollectionId = "2079133718"  # DarkRP Mod Collection

# GitHub map download
$MapGitHubUrl = "https://github.com/KryptonNetworks/rp_downtown_v4c_v2/raw/master/rp_downtown_v4c_v2.bsp"
$MapName = "rp_downtown_v4c_v2"

Write-Host "This will download:" -ForegroundColor Yellow
Write-Host "1. rp_downtown_v4c_v2 map (from GitHub)" -ForegroundColor Cyan
Write-Host "2. DarkRP Mod Collection (Collection ID: $DarkRPCollectionId)" -ForegroundColor Cyan
Write-Host ""
Write-Host "Note: The collection will be downloaded automatically" -ForegroundColor Gray
Write-Host "when the server starts with +host_workshop_collection." -ForegroundColor Gray
Write-Host ""

$Confirm = Read-Host "Continue? (Y/N, default: Y)"
if ($Confirm -ne "" -and $Confirm -ne "Y" -and $Confirm -ne "y") {
    Write-Host "Cancelled." -ForegroundColor Yellow
    exit
}

# Download the map from GitHub
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Downloading rp_downtown_v4c_v2 map from GitHub..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$MapsPath = Join-Path $ServerPath "garrysmod\maps"
if (-not (Test-Path $MapsPath)) {
    New-Item -ItemType Directory -Path $MapsPath -Force | Out-Null
}

$MapFilePath = Join-Path $MapsPath "$MapName.bsp"

try {
    Write-Host "Downloading map from GitHub..." -ForegroundColor Yellow
    Write-Host "URL: $MapGitHubUrl" -ForegroundColor Gray
    
    # Download the BSP file
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $MapGitHubUrl -OutFile $MapFilePath -UseBasicParsing
    
    if (Test-Path $MapFilePath) {
        $FileSize = (Get-Item $MapFilePath).Length / 1MB
        Write-Host "Map downloaded successfully! ($([math]::Round($FileSize, 2)) MB)" -ForegroundColor Green
        Write-Host "  Installed map: $MapName.bsp" -ForegroundColor Green
        
        # Try to download .nav file if it exists
        $NavGitHubUrl = "https://github.com/KryptonNetworks/rp_downtown_v4c_v2/raw/master/rp_downtown_v4c_v2.nav"
        $NavFilePath = Join-Path $MapsPath "$MapName.nav"
        
        try {
            Invoke-WebRequest -Uri $NavGitHubUrl -OutFile $NavFilePath -UseBasicParsing -ErrorAction Stop
            if (Test-Path $NavFilePath) {
                Write-Host "  Installed nav: $MapName.nav" -ForegroundColor Gray
            }
        }
        catch {
            Write-Host "  Note: Navigation file (.nav) not found, skipping..." -ForegroundColor Gray
        }
    }
    else {
        Write-Host "Warning: Map download failed" -ForegroundColor Yellow
        Write-Host "The map will need to be downloaded manually." -ForegroundColor Gray
    }
}
catch {
    Write-Host "Error downloading map from GitHub: $_" -ForegroundColor Red
    Write-Host "You may need to download the map manually from:" -ForegroundColor Yellow
    Write-Host "  $MapGitHubUrl" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Or download from Steam Workshop and place it in:" -ForegroundColor Yellow
    Write-Host "  $MapsPath" -ForegroundColor Gray
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Collection Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "The DarkRP Mod Collection (ID: $DarkRPCollectionId) will be downloaded." -ForegroundColor Yellow
Write-Host ""
Write-Host "IMPORTANT:" -ForegroundColor Red
Write-Host "The collection will be automatically downloaded when you start the server" -ForegroundColor Yellow
Write-Host "with the +host_workshop_collection parameter." -ForegroundColor Yellow
Write-Host ""
Write-Host "Your start-server.bat has been updated to include:" -ForegroundColor Cyan
Write-Host "  +host_workshop_collection $DarkRPCollectionId" -ForegroundColor White
Write-Host ""
Write-Host "When you start the server, it will automatically download all addons" -ForegroundColor Green
Write-Host "from the collection. This may take some time on first start." -ForegroundColor Gray
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Download completed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Start your server with: .\start-server.bat" -ForegroundColor Cyan
Write-Host "2. The collection addons will download automatically" -ForegroundColor Gray
Write-Host "3. The server will use rp_downtown_v4c_v2 as the default map" -ForegroundColor Gray

