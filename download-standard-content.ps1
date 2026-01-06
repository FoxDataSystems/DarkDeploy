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
$DowntownMapId = "107982746"  # rp_downtown_v2
$DarkRPCollectionId = "2079133718"  # DarkRP Mod Collection

Write-Host "This will download:" -ForegroundColor Yellow
Write-Host "1. rp_downtown_v2 map (Workshop ID: $DowntownMapId)" -ForegroundColor Cyan
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

# Download the map
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Downloading rp_downtown_v2 map..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$MapsPath = Join-Path $ServerPath "garrysmod\maps"
if (-not (Test-Path $MapsPath)) {
    New-Item -ItemType Directory -Path $MapsPath -Force | Out-Null
}

$DownloadScript = Join-Path $SteamCMDPath "download_map_$DowntownMapId.txt"
$ScriptContent = @"
@ShutdownOnFailedCommand 1
@NoPromptForPassword 1
login anonymous
workshop_download_item 4000 $DowntownMapId
quit
"@

$ScriptContent | Out-File -FilePath $DownloadScript -Encoding ASCII

Push-Location $SteamCMDPath
try {
    $ScriptName = Split-Path $DownloadScript -Leaf
    Write-Host "Downloading map from Workshop..." -ForegroundColor Yellow
    & $SteamCMDExe "+runscript" $ScriptName
    $ExitCode = $LASTEXITCODE
    
    if ($ExitCode -eq 0) {
        Write-Host "Map downloaded successfully!" -ForegroundColor Green
        
        # Copy map files to maps directory
        $SteamWorkshopPath = Join-Path $SteamCMDPath "steamapps\workshop\content\4000\$DowntownMapId"
        if (Test-Path $SteamWorkshopPath) {
            $BspFiles = Get-ChildItem $SteamWorkshopPath -Filter "*.bsp" -Recurse
            foreach ($BspFile in $BspFiles) {
                Copy-Item $BspFile.FullName -Destination $MapsPath -Force
                Write-Host "  Installed map: $($BspFile.Name)" -ForegroundColor Green
            }
            
            # Also copy .nav files if they exist
            $NavFiles = Get-ChildItem $SteamWorkshopPath -Filter "*.nav" -Recurse
            foreach ($NavFile in $NavFiles) {
                Copy-Item $NavFile.FullName -Destination $MapsPath -Force
                Write-Host "  Installed nav: $($NavFile.Name)" -ForegroundColor Gray
            }
        }
    }
    else {
        Write-Host "Warning: Map download failed (Exit code: $ExitCode)" -ForegroundColor Yellow
        Write-Host "The map will be downloaded automatically when the server starts." -ForegroundColor Gray
    }
}
finally {
    Pop-Location
    Remove-Item $DownloadScript -Force -ErrorAction SilentlyContinue
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
Write-Host "3. The server will use rp_downtown_v2 as the default map" -ForegroundColor Gray

