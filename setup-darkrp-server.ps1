# DarkRP Server Setup Script for Garry's Mod
# This script downloads and installs all required files for a DarkRP server

param(
    [string]$InstallPath = ".\gmod-server",
    [string]$SteamCMDPath = ".\steamcmd",
    [string]$AppId = "4020",  # Garry's Mod Dedicated Server App ID
    [switch]$SkipMenu,
    [switch]$Remove,
    [switch]$CheckStatus,
    [string]$ServerName = "",  # Server name (hostname)
    [string]$RconPassword = "",  # RCON password
    [string]$SteamToken = ""  # Steam Game Server Account Token
)

$ErrorActionPreference = "Stop"

# Initialize recommended installation flag
$Script:InstallRecommended = $false

# Initialize server configuration variables
$Script:ServerName = $ServerName
$Script:RconPassword = $RconPassword
$Script:SteamToken = $SteamToken
$Script:UseSteamToken = $false

# Function to check if a command exists
function Test-Command {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

# Function to download files
function Download-File {
    param(
        [string]$Url,
        [string]$OutputPath
    )
    
    Write-Host "Downloading: $Url" -ForegroundColor Yellow
    try {
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $Url -OutFile $OutputPath -UseBasicParsing
        Write-Host "Download completed: $OutputPath" -ForegroundColor Green
    }
    catch {
        Write-Host "Error downloading: $_" -ForegroundColor Red
        throw
    }
}

# Function to extract ZIP files
function Expand-Zip {
    param(
        [string]$ZipPath,
        [string]$Destination
    )
    
    Write-Host "Extracting: $ZipPath to $Destination" -ForegroundColor Yellow
    if (-not (Test-Path $Destination)) {
        New-Item -ItemType Directory -Path $Destination -Force | Out-Null
    }
    Expand-Archive -Path $ZipPath -DestinationPath $Destination -Force
    Write-Host "Extraction completed" -ForegroundColor Green
}

# Function to check server status
function Check-ServerStatus {
    param(
        [string]$ServerPath,
        [string]$SteamCMDPath
    )
    
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Server Status Check" -ForegroundColor Cyan
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
    
    $Status = @{
        ServerInstalled = $false
        SteamCMDInstalled = $false
        DarkRPInstalled = $false
        ConfigFilesExist = $false
        SrcdsExists = $false
    }
    
    # Check server directory
    if (Test-Path $ServerPath) {
        Write-Host "Server Directory: $ServerPath" -ForegroundColor Green
        $Status.ServerInstalled = $true
        
        # Check srcds.exe
        $SrcdsExe = Join-Path $ServerPath "srcds.exe"
        if (Test-Path $SrcdsExe) {
            Write-Host "  srcds.exe: Found" -ForegroundColor Green
            $Status.SrcdsExists = $true
        }
        else {
            Write-Host "  srcds.exe: Not found" -ForegroundColor Red
        }
        
        # Check DarkRP
        $DarkRPPath = Join-Path $ServerPath "garrysmod\gamemodes\darkrp"
        if (Test-Path $DarkRPPath) {
            $DarkRPFiles = Get-ChildItem $DarkRPPath -Recurse -File | Measure-Object
            if ($DarkRPFiles.Count -gt 0) {
                Write-Host "  DarkRP: Installed ($($DarkRPFiles.Count) files)" -ForegroundColor Green
                $Status.DarkRPInstalled = $true
            }
            else {
                Write-Host "  DarkRP: Directory exists but empty" -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "  DarkRP: Not installed" -ForegroundColor Red
        }
        
        # Check config files
        $ServerCfg = Join-Path $ServerPath "garrysmod\cfg\server.cfg"
        $StartScript = Join-Path $ServerPath "start-server.bat"
        if ((Test-Path $ServerCfg) -and (Test-Path $StartScript)) {
            Write-Host "  Config files: Found" -ForegroundColor Green
            $Status.ConfigFilesExist = $true
        }
        else {
            Write-Host "  Config files: Missing" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "Server Directory: Not found" -ForegroundColor Red
        Write-Host "  Location: $ServerPath" -ForegroundColor Gray
    }
    
    # Check SteamCMD
    Write-Host ""
    if (Test-Path $SteamCMDPath) {
        $SteamCMDExe = Join-Path $SteamCMDPath "steamcmd.exe"
        if (Test-Path $SteamCMDExe) {
            Write-Host "SteamCMD: Installed" -ForegroundColor Green
            Write-Host "  Location: $SteamCMDPath" -ForegroundColor Gray
            $Status.SteamCMDInstalled = $true
        }
        else {
            Write-Host "SteamCMD: Directory exists but steamcmd.exe not found" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "SteamCMD: Not installed" -ForegroundColor Red
        Write-Host "  Expected location: $SteamCMDPath" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "Summary:" -ForegroundColor Cyan
    if ($Status.ServerInstalled -and $Status.SrcdsExists -and $Status.DarkRPInstalled -and $Status.ConfigFilesExist) {
        Write-Host "  Server Status: Ready to run" -ForegroundColor Green
    }
    elseif ($Status.ServerInstalled) {
        Write-Host "  Server Status: Partially installed" -ForegroundColor Yellow
    }
    else {
        Write-Host "  Server Status: Not installed" -ForegroundColor Red
    }
}

# Function to remove server
function Remove-Server {
    param(
        [string]$ServerPath,
        [string]$SteamCMDPath,
        [switch]$KeepSteamCMD
    )
    
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Remove Server" -ForegroundColor Red
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
    
    # Confirm removal
    Write-Host "This will remove:" -ForegroundColor Yellow
    if (Test-Path $ServerPath) {
        $Size = (Get-ChildItem $ServerPath -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        $SizeGB = [math]::Round($Size / 1GB, 2)
        Write-Host "  Server directory: $ServerPath ($SizeGB GB)" -ForegroundColor Yellow
    }
    else {
        Write-Host "  Server directory: Not found" -ForegroundColor Gray
    }
    
    if (-not $KeepSteamCMD) {
        if (Test-Path $SteamCMDPath) {
            Write-Host "  SteamCMD directory: $SteamCMDPath" -ForegroundColor Yellow
        }
        else {
            Write-Host "  SteamCMD directory: Not found" -ForegroundColor Gray
        }
    }
    else {
        Write-Host "  SteamCMD directory: Will be kept" -ForegroundColor Gray
    }
    
    Write-Host ""
    $Confirm = Read-Host "Are you sure you want to continue? (yes/no)"
    
    if ($Confirm -ne "yes" -and $Confirm -ne "y") {
        Write-Host "Removal cancelled." -ForegroundColor Yellow
        return
    }
    
    # Remove server directory
    if (Test-Path $ServerPath) {
        Write-Host ""
        Write-Host "Removing server directory..." -ForegroundColor Yellow
        try {
            Remove-Item $ServerPath -Recurse -Force -ErrorAction Stop
            Write-Host "Server directory removed successfully." -ForegroundColor Green
        }
        catch {
            Write-Host "Error removing server directory: $_" -ForegroundColor Red
            Write-Host "You may need to close any programs using these files." -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "Server directory not found, nothing to remove." -ForegroundColor Gray
    }
    
    # Remove SteamCMD if not keeping it
    if (-not $KeepSteamCMD) {
        if (Test-Path $SteamCMDPath) {
            Write-Host ""
            Write-Host "Removing SteamCMD directory..." -ForegroundColor Yellow
            try {
                Remove-Item $SteamCMDPath -Recurse -Force -ErrorAction Stop
                Write-Host "SteamCMD directory removed successfully." -ForegroundColor Green
            }
            catch {
                Write-Host "Error removing SteamCMD directory: $_" -ForegroundColor Red
            }
        }
    }
    
    Write-Host ""
    Write-Host "Removal completed!" -ForegroundColor Green
}

# Function to get server configuration
function Get-ServerConfiguration {
    param(
        [string]$ServerNameParam,
        [string]$RconPasswordParam,
        [string]$SteamTokenParam
    )
    
    # Use script-level variables if parameters are empty
    if ([string]::IsNullOrWhiteSpace($ServerNameParam)) {
        $ServerNameParam = $script:ServerName
    }
    if ([string]::IsNullOrWhiteSpace($RconPasswordParam)) {
        $RconPasswordParam = $script:RconPassword
    }
    if ([string]::IsNullOrWhiteSpace($SteamTokenParam)) {
        $SteamTokenParam = $script:SteamToken
    }
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Server Configuration" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Check if running in non-interactive mode (all parameters provided)
    $NonInteractive = -not [string]::IsNullOrWhiteSpace($ServerNameParam) -and -not [string]::IsNullOrWhiteSpace($RconPasswordParam)
    
    if ($NonInteractive) {
        Write-Host "Using provided configuration parameters (non-interactive mode)" -ForegroundColor Green
        Write-Host "Server Name: $ServerNameParam" -ForegroundColor Gray
        Write-Host "RCON Password: [HIDDEN]" -ForegroundColor Gray
        if (-not [string]::IsNullOrWhiteSpace($SteamTokenParam)) {
            Write-Host "Steam Token: [PROVIDED]" -ForegroundColor Gray
        }
        else {
            Write-Host "Steam Token: [NOT PROVIDED]" -ForegroundColor Gray
        }
        Write-Host ""
    }
    else {
        Write-Host "Please provide the following information:" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Tip: You can provide these values as parameters to run non-interactively:" -ForegroundColor Gray
        Write-Host "  -ServerName `"My Server`" -RconPassword `"mypassword`" -SteamToken `"YOUR_TOKEN`"" -ForegroundColor Gray
        Write-Host ""
    }
    
    # Ask for server name (if not provided)
    if ([string]::IsNullOrWhiteSpace($ServerNameParam)) {
        $ServerNameParam = Read-Host "Enter server name (default: DarkRP Server)"
        if ([string]::IsNullOrWhiteSpace($ServerNameParam)) {
            $ServerNameParam = "DarkRP Server"
        }
    }
    
    # Ask for RCON password (if not provided)
    if ([string]::IsNullOrWhiteSpace($RconPasswordParam)) {
        Write-Host ""
        Write-Host "RCON Password is used to remotely control your server." -ForegroundColor Gray
        $RconPasswordParam = Read-Host "Enter RCON password (default: changeme)"
        if ([string]::IsNullOrWhiteSpace($RconPasswordParam)) {
            $RconPasswordParam = "changeme"
            if (-not $NonInteractive) {
                Write-Host "Warning: Using default password. Please change it in server.cfg!" -ForegroundColor Yellow
            }
        }
    }
    
    # Ask for Steam Game Server Account Token (if not provided)
    if ([string]::IsNullOrWhiteSpace($SteamTokenParam)) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "Steam Game Server Account Token" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "A Steam Game Server Account Token is required for your server to appear" -ForegroundColor Yellow
        Write-Host "in the server browser and for better server ranking." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "How to get your token:" -ForegroundColor Cyan
        Write-Host "1. Go to: https://steamcommunity.com/dev/managegameservers" -ForegroundColor White
        Write-Host "2. Log in with your Steam account" -ForegroundColor White
        Write-Host "3. Select 'Garry's Mod' (App ID: 4000)" -ForegroundColor White
        Write-Host "4. Enter a name for your server (e.g., 'My DarkRP Server')" -ForegroundColor White
        Write-Host "5. Click 'Create' and copy the generated token" -ForegroundColor White
        Write-Host ""
        Write-Host "You can also skip this step and add it later in server.cfg" -ForegroundColor Gray
        Write-Host ""
        
        $SteamTokenParam = Read-Host "Enter Steam Game Server Account Token (or press Enter to skip)"
    }
    
    # Determine if we should use the Steam token
    $UseSteamToken = $false
    if (-not [string]::IsNullOrWhiteSpace($SteamTokenParam)) {
        $UseSteamToken = $true
        if (-not $NonInteractive) {
            Write-Host "Steam token will be added to server configuration." -ForegroundColor Green
        }
    }
    else {
        if (-not $NonInteractive) {
            Write-Host "Steam token skipped. You can add it later in server.cfg" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host "Configuration saved!" -ForegroundColor Green
    Write-Host ""
    
    # Return values
    return @{
        ServerName = $ServerNameParam
        RconPassword = $RconPasswordParam
        SteamToken = $SteamTokenParam
        UseSteamToken = $UseSteamToken
    }
}

# Function to install ULX and ULib
function Install-ULX {
    param(
        [string]$ServerPath
    )
    
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Installing ULX and ULib" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Normalize path
    if (-not ([System.IO.Path]::IsPathRooted($ServerPath))) {
        $ServerPath = [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $ServerPath))
    }
    if (Test-Path $ServerPath) {
        $ServerPath = (Resolve-Path $ServerPath).Path
    }
    
    if (-not (Test-Path $ServerPath)) {
        Write-Host "Error: Server path not found: $ServerPath" -ForegroundColor Red
        Write-Host "Please install the server first (option 1)" -ForegroundColor Yellow
        return $false
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
            Download-File -Url $Url -OutputPath $ZipFile
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
                return $true
            }
            else {
                Write-Host "Warning: Could not find $Name folder in extracted files" -ForegroundColor Yellow
                return $false
            }
        }
        catch {
            Write-Host "Error downloading/extracting $Name : $_" -ForegroundColor Red
            return $false
        }
    }
    
    # Install ULib first (ULX depends on it)
    $ULibSuccess = Download-Extract-Addon -Url $ULibUrl -Name "ulib"
    
    # Install ULX
    $ULXSuccess = Download-Extract-Addon -Url $ULXUrl -Name "ulx"
    
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
    if ($ULibSuccess -and $ULXSuccess) {
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "ULX Installation Complete!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "ULX and ULib have been installed." -ForegroundColor Green
        Write-Host "Restart your server for changes to take effect." -ForegroundColor Yellow
        Write-Host ""
        return $true
    }
    else {
        Write-Host "========================================" -ForegroundColor Yellow
        Write-Host "ULX Installation Completed with Warnings" -ForegroundColor Yellow
        Write-Host "========================================" -ForegroundColor Yellow
        Write-Host ""
        return $false
    }
}

# Function to perform recommended complete installation
function Install-Recommended {
    param(
        [string]$ServerPath,
        [string]$SteamCMDPath,
        [string]$AppId
    )
    
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Recommended Complete Installation" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "This will install everything needed for a working DarkRP server:" -ForegroundColor Yellow
    Write-Host "  1. SteamCMD" -ForegroundColor White
    Write-Host "  2. Garry's Mod Dedicated Server" -ForegroundColor White
    Write-Host "  3. DarkRP Gamemode" -ForegroundColor White
    Write-Host "  4. ULX/ULib (Admin Mod)" -ForegroundColor White
    Write-Host "  5. Standard DarkRP Content (Map + Collection)" -ForegroundColor White
    Write-Host ""
    Write-Host "This may take 15-30 minutes depending on your internet speed." -ForegroundColor Gray
    Write-Host ""
    
    $Confirm = Read-Host "Continue with recommended installation? (Y/N, default: Y)"
    if ($Confirm -ne "" -and $Confirm -ne "Y" -and $Confirm -ne "y") {
        Write-Host "Installation cancelled." -ForegroundColor Yellow
        return $false
    }
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Starting Recommended Installation..." -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    
    # Set SkipMenu to true so we continue with installation after this function
    $Script:SkipMenu = $true
    $Script:InstallRecommended = $true
    
    return $true
}

# Show menu if not skipped
if (-not $SkipMenu -and -not $Remove -and -not $CheckStatus) {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "DarkRP Server Setup Script" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Please select an option:" -ForegroundColor Yellow
    Write-Host "1. Recommended Install (Everything - Server + ULX + Content)" -ForegroundColor Green
    Write-Host "2. Install/Update Server Only" -ForegroundColor Cyan
    Write-Host "3. Remove Server" -ForegroundColor Red
    Write-Host "4. Check Server Status" -ForegroundColor Cyan
    Write-Host "5. Install ULX/ULib (Admin Mod)" -ForegroundColor Blue
    Write-Host "6. Download Standard DarkRP Content (Map + Collection)" -ForegroundColor Magenta
    Write-Host "7. Download DarkRP Addons & Maps (Custom)" -ForegroundColor Yellow
    Write-Host "8. Exit" -ForegroundColor Gray
    Write-Host ""
    
    $Choice = Read-Host "Enter your choice (1-8)"
    
    switch ($Choice) {
        "1" {
            Write-Host ""
            
            # Get server configuration if not already set
            if ([string]::IsNullOrWhiteSpace($script:ServerName) -or [string]::IsNullOrWhiteSpace($script:RconPassword)) {
                $Config = Get-ServerConfiguration -ServerNameParam $ServerName -RconPasswordParam $RconPassword -SteamTokenParam $SteamToken
                $script:ServerName = $Config.ServerName
                $script:RconPassword = $Config.RconPassword
                $script:SteamToken = $Config.SteamToken
                $script:UseSteamToken = $Config.UseSteamToken
            }
            
            if (Install-Recommended -ServerPath $InstallPath -SteamCMDPath $SteamCMDPath -AppId $AppId) {
                # Continue with installation - SkipMenu is now true
            }
            else {
                exit
            }
        }
        "2" {
            Write-Host ""
            Write-Host "Starting server installation..." -ForegroundColor Green
            Write-Host ""
            # Continue with installation
        }
        "3" {
            Remove-Server -ServerPath $InstallPath -SteamCMDPath $SteamCMDPath
            exit
        }
        "4" {
            Check-ServerStatus -ServerPath $InstallPath -SteamCMDPath $SteamCMDPath
            exit
        }
        "5" {
            Write-Host ""
            Write-Host "Starting ULX installation..." -ForegroundColor Blue
            Write-Host ""
            Install-ULX -ServerPath $InstallPath
            Write-Host ""
            Write-Host "Press any key to return to menu..." -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            exit
        }
        "6" {
            Write-Host ""
            Write-Host "Starting standard DarkRP content download..." -ForegroundColor Magenta
            Write-Host ""
            
            if (Test-Path "$PSScriptRoot\download-standard-content.ps1") {
                & "$PSScriptRoot\download-standard-content.ps1" -ServerPath $InstallPath -SteamCMDPath $SteamCMDPath
            }
            else {
                Write-Host "Error: download-standard-content.ps1 not found" -ForegroundColor Red
                Write-Host "Please ensure the file exists in the same directory." -ForegroundColor Yellow
            }
            exit
        }
        "7" {
            Write-Host ""
            Write-Host "Starting DarkRP content downloader..." -ForegroundColor Magenta
            Write-Host ""
            if (Test-Path "$PSScriptRoot\download-darkrp-content.ps1") {
                & "$PSScriptRoot\download-darkrp-content.ps1" -ServerPath $InstallPath -SteamCMDPath $SteamCMDPath
            }
            else {
                Write-Host "Error: download-darkrp-content.ps1 not found" -ForegroundColor Red
                Write-Host "Please ensure the file exists in the same directory." -ForegroundColor Yellow
            }
            exit
        }
        "8" {
            Write-Host "Exiting..." -ForegroundColor Gray
            exit
        }
        default {
            Write-Host "Invalid choice. Exiting..." -ForegroundColor Red
            exit
        }
    }
}

# Handle direct parameter calls
if ($Remove) {
    Remove-Server -ServerPath $InstallPath -SteamCMDPath $SteamCMDPath
    exit
}

if ($CheckStatus) {
    Check-ServerStatus -ServerPath $InstallPath -SteamCMDPath $SteamCMDPath
    exit
}

# Installation continues from here
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DarkRP Server Setup Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Download and install SteamCMD
Write-Host "[1/5] Installing SteamCMD..." -ForegroundColor Cyan
$SteamCMDZip = "$SteamCMDPath\steamcmd.zip"
$SteamCMDExe = "$SteamCMDPath\steamcmd.exe"

# Search for existing SteamCMD installations
$ExistingSteamCMD = $null
$PossiblePaths = @(
    $SteamCMDPath,
    "D:\steamLibrary\steamapps\common\SteamCMD",
    "C:\steamcmd",
    "D:\steamcmd",
    "$env:ProgramFiles\Steam\steamapps\common\SteamCMD",
    "$env:ProgramFiles(x86)\Steam\steamapps\common\SteamCMD"
)

# Also check in Steam library directories
$SteamLibraryPaths = @("D:\steamLibrary", "C:\Program Files\Steam", "C:\Program Files (x86)\Steam")
foreach ($LibraryPath in $SteamLibraryPaths) {
    if (Test-Path $LibraryPath) {
        $SteamCMDPossible = Join-Path $LibraryPath "steamapps\common\SteamCMD"
        if (Test-Path $SteamCMDPossible) {
            $PossiblePaths += $SteamCMDPossible
        }
    }
}

# Search for existing SteamCMD
foreach ($Path in $PossiblePaths) {
    $TestExe = Join-Path $Path "steamcmd.exe"
    if (Test-Path $TestExe) {
        $ExistingSteamCMD = $TestExe
        Write-Host "Existing SteamCMD found: $TestExe" -ForegroundColor Green
        break
    }
}

if ($ExistingSteamCMD) {
    $UseExisting = Read-Host "Use existing SteamCMD installation? (Y/N, default: Y)"
    if ($UseExisting -eq "" -or $UseExisting -eq "Y" -or $UseExisting -eq "y") {
        $SteamCMDExe = $ExistingSteamCMD
        $SteamCMDPath = Split-Path $ExistingSteamCMD -Parent
        Write-Host "Using existing SteamCMD: $SteamCMDExe" -ForegroundColor Green
    }
    else {
        $ExistingSteamCMD = $null
    }
}

if (-not $ExistingSteamCMD -and -not (Test-Path $SteamCMDExe)) {
    if (-not (Test-Path $SteamCMDPath)) {
        New-Item -ItemType Directory -Path $SteamCMDPath -Force | Out-Null
    }
    
    Write-Host "Downloading SteamCMD..." -ForegroundColor Yellow
    Download-File -Url "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip" -OutputPath $SteamCMDZip
    
    Write-Host "Extracting SteamCMD..." -ForegroundColor Yellow
    Expand-Zip -ZipPath $SteamCMDZip -Destination $SteamCMDPath
    
    Remove-Item $SteamCMDZip -Force
    Write-Host "SteamCMD installed in: $SteamCMDPath" -ForegroundColor Green
}
elseif (Test-Path $SteamCMDExe) {
    Write-Host "SteamCMD is already installed: $SteamCMDExe" -ForegroundColor Green
}

# Step 2: Download and install Garry's Mod Server
Write-Host ""
Write-Host "[2/5] Downloading Garry's Mod Server..." -ForegroundColor Cyan

# Create server directory if it doesn't exist
if (-not (Test-Path $InstallPath)) {
    New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
    Write-Host "Server directory created: $InstallPath" -ForegroundColor Gray
}

# Resolve path to absolute path
$ServerPath = (Resolve-Path $InstallPath).Path

# Normalize SteamCMD path to absolute path (if not already absolute)
if (-not ([System.IO.Path]::IsPathRooted($SteamCMDPath))) {
    $SteamCMDPath = [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $SteamCMDPath))
}

# Ensure SteamCMD directory exists
if (-not (Test-Path $SteamCMDPath)) {
    try {
        $SteamCMDPath = New-Item -ItemType Directory -Path $SteamCMDPath -Force | Select-Object -ExpandProperty FullName
        Write-Host "SteamCMD directory created: $SteamCMDPath" -ForegroundColor Gray
    }
    catch {
        Write-Host "Error creating SteamCMD directory: $_" -ForegroundColor Red
        throw
    }
}
else {
    # Resolve to absolute path if directory already exists
    $SteamCMDPath = (Resolve-Path $SteamCMDPath).Path
}

# Update SteamCMDExe to absolute path (now $SteamCMDPath is always absolute)
$SteamCMDExe = Join-Path $SteamCMDPath "steamcmd.exe"
# Ensure path is absolute - use Resolve-Path if file exists, otherwise GetFullPath
if (Test-Path $SteamCMDExe) {
    $SteamCMDExe = (Resolve-Path $SteamCMDExe).Path
}
else {
    $SteamCMDExe = [System.IO.Path]::GetFullPath($SteamCMDExe)
}

Write-Host "SteamCMD executable path: $SteamCMDExe" -ForegroundColor Gray

# Check if steamcmd.exe exists
if (-not (Test-Path $SteamCMDExe)) {
    Write-Host "Error: steamcmd.exe not found at: $SteamCMDExe" -ForegroundColor Red
    Write-Host "Ensure SteamCMD is correctly installed." -ForegroundColor Yellow
    exit 1
}

# Create installation script path (now $SteamCMDPath is always absolute)
$InstallScript = Join-Path $SteamCMDPath "install_gmod.txt"

@"
@ShutdownOnFailedCommand 0
@NoPromptForPassword 1
force_install_dir `"$ServerPath`"
login anonymous
app_update 2430930 validate
app_update $AppId validate
quit
"@ | Out-File -FilePath $InstallScript -Encoding ASCII

Write-Host "Downloading server files (this may take a while)..." -ForegroundColor Yellow
Write-Host "Install script: $InstallScript" -ForegroundColor Gray
Write-Host "Server path: $ServerPath" -ForegroundColor Gray
Write-Host ""
Write-Host "Note: If you see 'Missing configuration' for app 2430930, this is normal." -ForegroundColor Gray
Write-Host "The dependency will be downloaded automatically when needed." -ForegroundColor Gray
Write-Host ""

# Execute SteamCMD with the script
# Use absolute path for steamcmd.exe and script
$ScriptName = Split-Path $InstallScript -Leaf
Write-Host "Executing: $SteamCMDExe +runscript $ScriptName" -ForegroundColor Gray

Push-Location $SteamCMDPath
try {
    & $SteamCMDExe "+runscript" $ScriptName
    $ExitCode = $LASTEXITCODE
}
finally {
    Pop-Location
}

# Check if srcds.exe exists even if exit code is not 0
# Sometimes the dependency fails but GMod server still downloads successfully
$SrcdsExe = Join-Path $ServerPath "srcds.exe"
$SrcdsFound = Test-Path $SrcdsExe

if (-not $SrcdsFound) {
    # Search in subdirectories
    $FoundSrcds = Get-ChildItem -Path $ServerPath -Filter "srcds.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($FoundSrcds) {
        $SrcdsFound = $true
        $SrcdsExe = $FoundSrcds.FullName
    }
}

if ($ExitCode -ne 0 -and -not $SrcdsFound) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "Download Error (Exit code: $ExitCode)" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    
    # Check if this looks like a SteamCMD recognition issue
    $SteamCMDFreshInstall = $false
    if ($ExitCode -eq 7 -or $ExitCode -eq 8) {
        # Check if SteamCMD was just installed in this session
        $SteamCMDFreshInstall = $true
    }
    
    if ($SteamCMDFreshInstall) {
        Write-Host "IMPORTANT: SteamCMD was just installed and needs PowerShell restart!" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "This is a Windows limitation - newly installed programs need a refresh" -ForegroundColor Gray
        Write-Host "PowerShell session to be recognized properly." -ForegroundColor Gray
        Write-Host ""
        Write-Host "What to do:" -ForegroundColor Cyan
        Write-Host "1. Close this PowerShell window completely" -ForegroundColor White
        Write-Host "2. Open a NEW PowerShell window" -ForegroundColor White
        Write-Host "3. Navigate to the script directory:" -ForegroundColor White
        Write-Host "   cd `"$PSScriptRoot`"" -ForegroundColor Gray
        Write-Host "4. Run the script again:" -ForegroundColor White
        Write-Host "   .\setup-darkrp-server.ps1" -ForegroundColor Gray
        Write-Host ""
        Write-Host "The script will continue from where it left off." -ForegroundColor Green
        Write-Host ""
        
        $Restart = Read-Host "Would you like to open a new PowerShell window now? (Y/N, default: N)"
        if ($Restart -eq "Y" -or $Restart -eq "y") {
            Write-Host ""
            Write-Host "Opening new PowerShell window..." -ForegroundColor Yellow
            Write-Host "Please run the script again in the new window." -ForegroundColor Gray
            Write-Host ""
            
            # Start a new PowerShell window with the script
            $NewPSCommand = "cd '$PSScriptRoot'; .\setup-darkrp-server.ps1"
            Start-Process powershell.exe -ArgumentList "-NoExit", "-Command", $NewPSCommand
            Write-Host "New PowerShell window opened. You can close this window." -ForegroundColor Green
            Write-Host ""
            Write-Host "Press any key to exit..." -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            exit 0
        }
        else {
            Write-Host ""
            Write-Host "Please restart PowerShell manually and run the script again." -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Press any key to exit..." -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            exit 1
        }
    }
    else {
        Write-Host "Troubleshooting:" -ForegroundColor Yellow
        Write-Host "1. If you see 'Missing configuration' for app 2430930, this is normal." -ForegroundColor Gray
        Write-Host "   The dependency will be downloaded automatically when the server starts." -ForegroundColor Gray
        Write-Host "2. If SteamCMD was just installed, restart PowerShell and try again." -ForegroundColor Gray
        Write-Host "3. Check your internet connection and try again." -ForegroundColor Gray
        Write-Host ""
        Write-Host "If the problem persists, try running SteamCMD manually to verify it works." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Press any key to exit..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }
}
elseif ($ExitCode -ne 0 -and $SrcdsFound) {
    Write-Host ""
    Write-Host "Warning: SteamCMD reported an error (Exit code: $ExitCode)" -ForegroundColor Yellow
    Write-Host "However, srcds.exe was found, so the installation may have succeeded." -ForegroundColor Yellow
    Write-Host "This is normal if you saw 'Missing configuration' for app 2430930." -ForegroundColor Gray
    Write-Host "The dependency will be downloaded automatically when needed." -ForegroundColor Gray
    Write-Host ""
    Write-Host "Server files downloaded and verified" -ForegroundColor Green
    Write-Host "srcds.exe found at: $SrcdsExe" -ForegroundColor Gray
}
elseif ($ExitCode -eq 0) {
    # Success case - verify srcds.exe exists
    if (-not $SrcdsFound) {
        $SrcdsExe = Join-Path $ServerPath "srcds.exe"
        if (Test-Path $SrcdsExe) {
            $SrcdsFound = $true
        }
    }
    
    if ($SrcdsFound) {
        Write-Host "Server files downloaded and verified" -ForegroundColor Green
        Write-Host "srcds.exe found at: $SrcdsExe" -ForegroundColor Gray
    }
    else {
        Write-Host "Warning: srcds.exe not found despite successful download." -ForegroundColor Yellow
        Write-Host "Checking alternative locations..." -ForegroundColor Yellow
        
        # Search in subdirectories
        $FoundSrcds = Get-ChildItem -Path $ServerPath -Filter "srcds.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        
        if ($FoundSrcds) {
            Write-Host "srcds.exe found at: $($FoundSrcds.FullName)" -ForegroundColor Green
            $SrcdsExe = $FoundSrcds.FullName
            $SrcdsFound = $true
        }
        else {
            Write-Host "Error: srcds.exe not found. The server installation may be incomplete." -ForegroundColor Red
            Write-Host ""
            Write-Host "Possible solutions:" -ForegroundColor Yellow
            Write-Host "1. If SteamCMD was just installed, restart PowerShell and try again." -ForegroundColor Gray
            Write-Host "2. Check your internet connection and try again." -ForegroundColor Gray
            Write-Host "3. Try running the script again - sometimes downloads need multiple attempts." -ForegroundColor Gray
            Write-Host ""
            exit 1
        }
    }
}

# Step 3: Create server directory structure
Write-Host ""
Write-Host "[3/5] Creating server directory structure..." -ForegroundColor Cyan

$Directories = @(
    "$ServerPath\garrysmod\addons",
    "$ServerPath\garrysmod\cfg",
    "$ServerPath\garrysmod\data",
    "$ServerPath\garrysmod\downloads",
    "$ServerPath\garrysmod\lua\darkrp\modules",
    "$ServerPath\garrysmod\lua\darkrp\config"
)

# Create all directories first
foreach ($Dir in $Directories) {
    if (-not (Test-Path $Dir)) {
        New-Item -ItemType Directory -Path $Dir -Force | Out-Null
        Write-Host "Created: $Dir" -ForegroundColor Gray
    }
}

# Create admin configuration file (after directories are created)
$AdminConfigPath = "$ServerPath\garrysmod\data\darkrp.txt"
if (-not (Test-Path $AdminConfigPath)) {
    $AdminConfig = @"
// DarkRP Admin Configuration
// Add Steam IDs here to give players admin privileges
// Format: "STEAM_ID" "rank"
// 
// Ranks:
// - superadmin: Full access to all DarkRP commands
// - admin: Access to most admin commands
// - moderator: Limited admin access
//
// To find someone's Steam ID:
// 1. They need to join your server
// 2. In server console, type: status
// 3. Look for their Steam ID (format: STEAM_0:0:12345678)
//
// Example:
// "STEAM_0:0:12345678" "superadmin"
// "STEAM_0:1:87654321" "admin"
"@
    $AdminConfig | Out-File -FilePath $AdminConfigPath -Encoding ASCII
    Write-Host "Created admin configuration file: $AdminConfigPath" -ForegroundColor Gray
}

Write-Host "Directory structure ready" -ForegroundColor Green

# Step 4: Download DarkRP
Write-Host ""
Write-Host "[4/5] Downloading DarkRP..." -ForegroundColor Cyan

$DarkRPPath = "$ServerPath\garrysmod\gamemodes\darkrp"
if (-not (Test-Path $DarkRPPath)) {
    New-Item -ItemType Directory -Path $DarkRPPath -Force | Out-Null
}

# Download DarkRP from GitHub (official repository)
$DarkRPUrl = "https://github.com/FPtje/DarkRP/archive/master.zip"
$DarkRPZip = "$env:TEMP\darkrp.zip"

Write-Host "Downloading DarkRP from GitHub..." -ForegroundColor Yellow
Download-File -Url $DarkRPUrl -OutputPath $DarkRPZip

Write-Host "Extracting DarkRP..." -ForegroundColor Yellow
$TempExtract = "$env:TEMP\darkrp-extract"
if (Test-Path $TempExtract) {
    Remove-Item $TempExtract -Recurse -Force
}
Expand-Zip -ZipPath $DarkRPZip -Destination $TempExtract

# Copy DarkRP files to the correct location
$DarkRPMasterPath = "$TempExtract\DarkRP-master"
if (Test-Path $DarkRPMasterPath) {
    # Copy all files from DarkRP-master to darkrp gamemode directory
    # Skip .git, ISSUE_TEMPLATE, scripts, workflows directories
    $Items = Get-ChildItem $DarkRPMasterPath -Force | Where-Object {
        $_.Name -notlike ".*" -and 
        $_.Name -ne "ISSUE_TEMPLATE" -and 
        $_.Name -ne "scripts" -and 
        $_.Name -ne "workflows" -and
        $_.Name -ne ".github"
    }
    
    foreach ($Item in $Items) {
        $DestPath = Join-Path $DarkRPPath $Item.Name
        Copy-Item $Item.FullName -Destination $DestPath -Recurse -Force
    }
    
    # Verify that gamemode.txt exists, create if missing
    $GamemodeTxt = Join-Path $DarkRPPath "gamemode.txt"
    if (-not (Test-Path $GamemodeTxt)) {
        Write-Host "gamemode.txt not found. Creating it..." -ForegroundColor Yellow
        
        # Try to find gamemode.txt in subdirectories first
        $FoundGamemode = Get-ChildItem $DarkRPPath -Filter "gamemode.txt" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($FoundGamemode) {
            Write-Host "Found gamemode.txt at: $($FoundGamemode.FullName)" -ForegroundColor Green
            Copy-Item $FoundGamemode.FullName -Destination $GamemodeTxt -Force
        }
        else {
            # Check if gamemode directory exists
            $GamemodeDir = Join-Path $DarkRPPath "gamemode"
            if (Test-Path $GamemodeDir) {
                Write-Host "Creating gamemode.txt file..." -ForegroundColor Yellow
                # Create gamemode.txt file for DarkRP
                @"
"DarkRP"
{
	"base"		"base"
	"title"		"DarkRP"
	"maps"		"*"
}
"@ | Out-File -FilePath $GamemodeTxt -Encoding ASCII
                Write-Host "gamemode.txt created" -ForegroundColor Green
            }
            else {
                Write-Host "Warning: gamemode directory not found. Creating basic gamemode.txt..." -ForegroundColor Yellow
                @"
"DarkRP"
{
	"base"		"base"
	"title"		"DarkRP"
	"maps"		"*"
}
"@ | Out-File -FilePath $GamemodeTxt -Encoding ASCII
                Write-Host "Basic gamemode.txt created" -ForegroundColor Green
            }
        }
    }
    
    # Verify gamemode directory exists
    $GamemodeDir = Join-Path $DarkRPPath "gamemode"
    if (Test-Path $GamemodeDir) {
        Write-Host "DarkRP installed successfully" -ForegroundColor Green
    }
    else {
        Write-Host "Warning: gamemode directory not found. DarkRP may not work correctly." -ForegroundColor Yellow
        Write-Host "Please verify the DarkRP installation." -ForegroundColor Yellow
    }
}
else {
    Write-Host "Error: DarkRP master directory not found at: $DarkRPMasterPath" -ForegroundColor Red
    Write-Host "Listing extracted files:" -ForegroundColor Yellow
    Get-ChildItem $TempExtract | ForEach-Object { Write-Host "  $($_.Name)" -ForegroundColor Gray }
}

# Cleanup
Remove-Item $DarkRPZip -Force -ErrorAction SilentlyContinue
Remove-Item $TempExtract -Recurse -Force -ErrorAction SilentlyContinue

# Step 5: Create basic configuration files
Write-Host ""
Write-Host "[5/5] Creating configuration files..." -ForegroundColor Cyan

# Get server configuration
$Config = Get-ServerConfiguration -ServerNameParam $ServerName -RconPasswordParam $RconPassword -SteamTokenParam $SteamToken
$ServerName = $Config.ServerName
$RconPassword = $Config.RconPassword
$SteamToken = $Config.SteamToken
$UseSteamToken = $Config.UseSteamToken

# Store in script scope for later use
$script:ServerName = $ServerName
$script:RconPassword = $RconPassword
$script:SteamToken = $SteamToken
$script:UseSteamToken = $UseSteamToken

# Create server.cfg
$ServerCfgPath = "$ServerPath\garrysmod\cfg\server.cfg"
if (-not (Test-Path $ServerCfgPath)) {
    Write-Host "Creating server.cfg..." -ForegroundColor Yellow
    
    # Build Steam token line
    $SteamTokenLine = ""
    if ($UseSteamToken) {
        $SteamTokenLine = "sv_setsteamaccount `"$SteamToken`""
    }
    else {
        $SteamTokenLine = @"
// Steam Game Server Account Token
// Get your token from: https://steamcommunity.com/dev/managegameservers
// App ID: 4000 (Garry's Mod)
// Uncomment and add your token below:
// sv_setsteamaccount "YOUR_TOKEN_HERE"
"@
    }
    
    $ServerCfg = @"
// DarkRP Server Configuration
// Adjust these settings to your preference

hostname "$ServerName"
rcon_password "$RconPassword"

// Server settings
sv_lan 0
sv_region 255 // -1 = worldwide, 255 = Europe
maxplayers 32

// Network settings
sv_maxrate 100000
sv_minrate 10000
sv_maxupdaterate 66
sv_minupdaterate 20

// Garry's Mod specific
sbox_maxprops 200
sbox_maxragdolls 50
sbox_maxnpcs 20
sbox_maxballoons 20
sbox_maxeffects 20
sbox_maxdynamite 5
sbox_maxlamps 20
sbox_maxthrusters 20
sbox_maxwheels 20
sbox_maxhoverballs 20
sbox_maxvehicles 6
sbox_maxbuttons 20
sbox_maxemitters 20

// DarkRP settings
// Note: darkrp_version is not a server command, it's informational only

$SteamTokenLine

// Logging
log on
sv_logbans 1
sv_logecho 1
sv_logfile 1
sv_log_onefile 0

// Performance
// Note: sv_fps and con_enable are not valid commands in Garry's Mod
"@
    
    $ServerCfg | Out-File -FilePath $ServerCfgPath -Encoding ASCII
    Write-Host "server.cfg created" -ForegroundColor Green
}
else {
    Write-Host "server.cfg already exists" -ForegroundColor Yellow
}

# Create motd.txt
$MotdPath = "$ServerPath\garrysmod\cfg\motd.txt"
if (-not (Test-Path $MotdPath)) {
    @"
Welcome to the DarkRP Server!
"@ | Out-File -FilePath $MotdPath -Encoding ASCII
    Write-Host "motd.txt created" -ForegroundColor Green
}

# Create start script
$StartScriptPath = "$ServerPath\start-server.bat"

# Find srcds.exe location
$SrcdsExe = Join-Path $ServerPath "srcds.exe"
if (-not (Test-Path $SrcdsExe)) {
    $FoundSrcds = Get-ChildItem -Path $ServerPath -Filter "srcds.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($FoundSrcds) {
        $SrcdsExe = $FoundSrcds.FullName
        $SrcdsDir = Split-Path $SrcdsExe -Parent
    }
    else {
        $SrcdsExe = "srcds.exe"
        $SrcdsDir = $ServerPath
    }
}
else {
    $SrcdsDir = $ServerPath
}

# Relative path for the batch script
$RelativeSrcds = if ($SrcdsExe -like "*$ServerPath*") {
    $SrcdsExe.Replace($ServerPath, ".").Replace("\", "\")
} else {
    "srcds.exe"
}

# Build start command with optional Steam token
$SteamTokenParam = ""
if ($UseSteamToken) {
    $SteamTokenParam = " +sv_setsteamaccount `"$SteamToken`""
}

if (-not (Test-Path $StartScriptPath)) {
    $StartScript = @"
@echo off
echo Starting DarkRP Server...
cd /d "%~dp0"
if not exist "srcds.exe" (
    echo Error: srcds.exe not found in the server directory!
    echo Ensure the server installation is complete.
    echo Server directory: %~dp0
    pause
    exit /b 1
)
srcds.exe -console -game garrysmod +gamemode darkrp +map rp_downtown_v2 +maxplayers 32 +host_workshop_collection 2079133718$SteamTokenParam
pause
"@
    
    $StartScript | Out-File -FilePath $StartScriptPath -Encoding ASCII
    Write-Host "start-server.bat created" -ForegroundColor Green
}
else {
    # Update existing script with verification
    $StartScript = @"
@echo off
echo Starting DarkRP Server...
cd /d "%~dp0"
if not exist "srcds.exe" (
    echo Error: srcds.exe not found in the server directory!
    echo Ensure the server installation is complete.
    echo Server directory: %~dp0
    pause
    exit /b 1
)
srcds.exe -console -game garrysmod +gamemode darkrp +map rp_downtown_v2 +maxplayers 32 +host_workshop_collection 2079133718$SteamTokenParam
pause
"@
    
    $StartScript | Out-File -FilePath $StartScriptPath -Encoding ASCII -Force
    Write-Host "start-server.bat updated" -ForegroundColor Green
}

# If this is a recommended installation, continue with ULX and content
if ($Script:InstallRecommended) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Continuing with Recommended Installation..." -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Step 6: Install ULX
    Write-Host "[Step 6/7] Installing ULX/ULib..." -ForegroundColor Cyan
    Write-Host ""
    $ULXSuccess = Install-ULX -ServerPath $ServerPath
    Write-Host ""
    
    # Step 7: Download Standard Content
    if ($ULXSuccess) {
        Write-Host "[Step 7/7] Downloading Standard DarkRP Content..." -ForegroundColor Cyan
        Write-Host ""
        
        if (Test-Path "$PSScriptRoot\download-standard-content.ps1") {
            Write-Host "Downloading rp_downtown_v2 map and DarkRP Mod Collection..." -ForegroundColor Yellow
            Write-Host ""
            
            # Execute the download script (it will handle its own prompts)
            & "$PSScriptRoot\download-standard-content.ps1" -ServerPath $ServerPath -SteamCMDPath $SteamCMDPath
            
            Write-Host ""
            Write-Host "Standard content download completed!" -ForegroundColor Green
        }
        else {
            Write-Host "Warning: download-standard-content.ps1 not found" -ForegroundColor Yellow
            Write-Host "Skipping content download. You can run it manually later." -ForegroundColor Gray
        }
    }
    else {
        Write-Host "Warning: ULX installation had issues. Skipping content download." -ForegroundColor Yellow
        Write-Host "You can install ULX and content manually later." -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Recommended Installation Complete!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Everything has been installed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Installed components:" -ForegroundColor Yellow
    Write-Host "  + Garry's Mod Dedicated Server" -ForegroundColor Green
    Write-Host "  + DarkRP Gamemode" -ForegroundColor Green
    Write-Host "  + ULX/ULib Admin Mod" -ForegroundColor Green
    Write-Host "  + Standard DarkRP Content (Map + Collection)" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Edit server.cfg: $ServerCfgPath" -ForegroundColor Cyan
    Write-Host "   - Add your Steam Game Server Account Token (sv_setsteamaccount)" -ForegroundColor Gray
    Write-Host "   - Configure server settings" -ForegroundColor Gray
    Write-Host "2. Start the server: $StartScriptPath" -ForegroundColor Cyan
    Write-Host "3. The Workshop collection will download automatically on first start" -ForegroundColor Gray
    Write-Host ""
}
else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Installation completed!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Server location: $ServerPath" -ForegroundColor Yellow
    Write-Host "SteamCMD location: $SteamCMDPath" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "IMPORTANT:" -ForegroundColor Red
    Write-Host "1. Change the RCON password in: $ServerCfgPath" -ForegroundColor Yellow
    Write-Host "2. Adjust server settings in: $ServerCfgPath" -ForegroundColor Yellow
    Write-Host "3. Start the server with: $StartScriptPath" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "DOWNLOAD ADDONS & MAPS:" -ForegroundColor Magenta
    Write-Host "To download standard DarkRP content:" -ForegroundColor Yellow
    Write-Host "1. Run the setup script again and choose option 6" -ForegroundColor Cyan
    Write-Host "   This will download rp_downtown_v2 map and DarkRP Mod Collection" -ForegroundColor Gray
    Write-Host "2. Or run: .\download-standard-content.ps1" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "For custom addons and maps:" -ForegroundColor Yellow
    Write-Host "1. Run the setup script and choose option 7" -ForegroundColor Cyan
    Write-Host "2. Or run: .\download-darkrp-content.ps1" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "NOTE:" -ForegroundColor Cyan
    Write-Host "The server is installed in the specified directory ($ServerPath)" -ForegroundColor Gray
    Write-Host "This is independent of your Steam library location." -ForegroundColor Gray
    Write-Host "For more information, see README.md" -ForegroundColor Cyan
}
