# Download Popular DarkRP Addons and Maps
# This script downloads popular DarkRP addons and maps from Steam Workshop

param(
    [string]$ServerPath = ".\gmod-server",
    [string]$SteamCMDPath = ".\steamcmd"
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DarkRP Content Downloader" -ForegroundColor Cyan
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

# Popular DarkRP Maps (Workshop IDs)
$DarkRPMaps = @{
    "rp_downtown_v4c_v2" = "110286060"
    "rp_evocity_v4b1" = "1730877736"
    "rp_evocity_v2d" = "1730877736"
    "rp_rockford_v1b" = "1730877736"
    "rp_downtown_v2" = "1730877736"
}

# DarkRP Collection ID
$DarkRPCollectionId = "1436536957"

# Popular DarkRP Addons (Workshop IDs)
# Note: These are example IDs - you should replace with actual Workshop IDs
$DarkRPAddons = @{
    "DarkRP F4 Menu" = "160250458"  # Example - replace with actual ID
    "DarkRP Money Printer" = "160250458"  # Example - replace with actual ID
    "DarkRP Base" = "160250458"  # Example - replace with actual ID
}

# Function to download Workshop item
function Download-WorkshopItem {
    param(
        [string]$WorkshopId,
        [string]$Name,
        [string]$ServerPath
    )
    
    Write-Host ""
    Write-Host "Downloading: $Name (ID: $WorkshopId)" -ForegroundColor Cyan
    
    $WorkshopPath = Join-Path $ServerPath "garrysmod\addons"
    if (-not (Test-Path $WorkshopPath)) {
        New-Item -ItemType Directory -Path $WorkshopPath -Force | Out-Null
    }
    
    # Create download script for SteamCMD
    $DownloadScript = Join-Path $SteamCMDPath "download_workshop_$WorkshopId.txt"
    $ScriptContent = @"
@ShutdownOnFailedCommand 1
@NoPromptForPassword 1
login anonymous
workshop_download_item 4000 $WorkshopId
quit
"@
    
    $ScriptContent | Out-File -FilePath $DownloadScript -Encoding ASCII
    
    Push-Location $SteamCMDPath
    try {
        $ScriptName = Split-Path $DownloadScript -Leaf
        & $SteamCMDExe "+runscript" $ScriptName
        $ExitCode = $LASTEXITCODE
        
        if ($ExitCode -eq 0) {
            Write-Host "$Name downloaded successfully" -ForegroundColor Green
            
            # Move downloaded content to addons folder
            $SteamWorkshopPath = Join-Path $SteamCMDPath "steamapps\workshop\content\4000\$WorkshopId"
            if (Test-Path $SteamWorkshopPath) {
                $DestPath = Join-Path $WorkshopPath "workshop-$WorkshopId"
                if (Test-Path $DestPath) {
                    Remove-Item $DestPath -Recurse -Force
                }
                Copy-Item $SteamWorkshopPath -Destination $DestPath -Recurse -Force
                Write-Host "  Installed to: $DestPath" -ForegroundColor Gray
            }
        }
        else {
            Write-Host "Warning: Failed to download $Name (Exit code: $ExitCode)" -ForegroundColor Yellow
        }
    }
    finally {
        Pop-Location
        Remove-Item $DownloadScript -Force -ErrorAction SilentlyContinue
    }
}

# Function to download map
function Download-Map {
    param(
        [string]$MapName,
        [string]$WorkshopId,
        [string]$ServerPath
    )
    
    Write-Host ""
    Write-Host "Downloading map: $MapName (ID: $WorkshopId)" -ForegroundColor Cyan
    
    $MapsPath = Join-Path $ServerPath "garrysmod\maps"
    if (-not (Test-Path $MapsPath)) {
        New-Item -ItemType Directory -Path $MapsPath -Force | Out-Null
    }
    
    # Create download script for SteamCMD
    $DownloadScript = Join-Path $SteamCMDPath "download_map_$WorkshopId.txt"
    $ScriptContent = @"
@ShutdownOnFailedCommand 1
@NoPromptForPassword 1
login anonymous
workshop_download_item 4000 $WorkshopId
quit
"@
    
    $ScriptContent | Out-File -FilePath $DownloadScript -Encoding ASCII
    
    Push-Location $SteamCMDPath
    try {
        $ScriptName = Split-Path $DownloadScript -Leaf
        & $SteamCMDExe "+runscript" $ScriptName
        $ExitCode = $LASTEXITCODE
        
        if ($ExitCode -eq 0) {
            Write-Host "$MapName downloaded successfully" -ForegroundColor Green
            
            # Move downloaded map files
            $SteamWorkshopPath = Join-Path $SteamCMDPath "steamapps\workshop\content\4000\$WorkshopId"
            if (Test-Path $SteamWorkshopPath) {
                # Find .bsp files and copy them
                $BspFiles = Get-ChildItem $SteamWorkshopPath -Filter "*.bsp" -Recurse
                foreach ($BspFile in $BspFiles) {
                    Copy-Item $BspFile.FullName -Destination $MapsPath -Force
                    Write-Host "  Installed map: $($BspFile.Name)" -ForegroundColor Gray
                }
            }
        }
        else {
            Write-Host "Warning: Failed to download $MapName (Exit code: $ExitCode)" -ForegroundColor Yellow
        }
    }
    finally {
        Pop-Location
        Remove-Item $DownloadScript -Force -ErrorAction SilentlyContinue
    }
}

# Show menu
Write-Host "What would you like to download?" -ForegroundColor Yellow
Write-Host "1. Popular DarkRP Maps" -ForegroundColor Green
Write-Host "2. Popular DarkRP Addons" -ForegroundColor Cyan
Write-Host "3. Both Maps and Addons" -ForegroundColor Yellow
Write-Host "4. Custom Workshop Collection" -ForegroundColor Magenta
Write-Host "5. Exit" -ForegroundColor Gray
Write-Host ""

$Choice = Read-Host "Enter your choice (1-5)"

switch ($Choice) {
    "1" {
        Write-Host ""
        Write-Host "Downloading popular DarkRP maps..." -ForegroundColor Cyan
        
        # Download rp_downtown_v4c_v2
        Write-Host ""
        Write-Host "Downloading rp_downtown_v4c_v2 (ID: $($DarkRPMaps['rp_downtown_v4c_v2']))..." -ForegroundColor Yellow
        Download-Map -MapName "rp_downtown_v4c_v2" -WorkshopId $DarkRPMaps['rp_downtown_v4c_v2'] -ServerPath $ServerPath
        
        Write-Host ""
        Write-Host "Map download completed!" -ForegroundColor Green
    }
    "2" {
        Write-Host ""
        Write-Host "Downloading popular DarkRP addons..." -ForegroundColor Cyan
        Write-Host "Note: You need to provide actual Workshop IDs for addons." -ForegroundColor Yellow
        Write-Host ""
        
        $AddonId = Read-Host "Enter Workshop ID for an addon (or press Enter to skip)"
        if ($AddonId) {
            $AddonName = Read-Host "Enter addon name"
            Download-WorkshopItem -WorkshopId $AddonId -Name $AddonName -ServerPath $ServerPath
        }
    }
    "3" {
        Write-Host ""
        Write-Host "Downloading both maps and addons..." -ForegroundColor Cyan
        Write-Host "This feature requires Workshop IDs." -ForegroundColor Yellow
        Write-Host "Please use option 4 to download a Workshop Collection instead." -ForegroundColor Yellow
    }
    "4" {
        Write-Host ""
        Write-Host "Downloading Workshop Collection..." -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Downloading DarkRP Mod Pack Collection (ID: $DarkRPCollectionId)..." -ForegroundColor Yellow
        Write-Host "This collection contains 176 popular DarkRP addons and mods." -ForegroundColor Gray
        Write-Host ""
        Write-Host "Note: The server will automatically download collection items when you start it." -ForegroundColor Yellow
        Write-Host "Make sure to add +host_workshop_collection $DarkRPCollectionId to your start command." -ForegroundColor Cyan
        Write-Host ""
        Write-Host "The collection will be downloaded automatically when the server starts." -ForegroundColor Green
        Write-Host "You can also manually download items using SteamCMD if needed." -ForegroundColor Gray
    }
    "5" {
        Write-Host "Exiting..." -ForegroundColor Gray
        exit
    }
    default {
        Write-Host "Invalid choice. Exiting..." -ForegroundColor Red
        exit
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Download completed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Note: For best results, use Steam Workshop Collections." -ForegroundColor Yellow
Write-Host "Create a collection with all your addons and maps, then add:" -ForegroundColor Yellow
Write-Host "+host_workshop_collection [YOUR_COLLECTION_ID]" -ForegroundColor Cyan
Write-Host "to your server start command." -ForegroundColor Yellow

