# DarkRP Server Setup Script

Automated PowerShell script to set up a complete Garry's Mod DarkRP server from scratch. This script handles everything from downloading SteamCMD and the server files to configuring DarkRP, installing ULX admin mod, and downloading maps and addons.

## Features

- 🚀 **One-Click Installation** - Complete server setup with a single script
- 🎮 **Recommended Install Option** - Installs everything automatically (Server + ULX + Content)
- ⚙️ **Interactive Menu** - Easy-to-use menu system for all operations
- 🔧 **Fully Automated** - Can run completely non-interactively with parameters
- 📦 **Auto-Detection** - Automatically detects existing SteamCMD installations
- 🗺️ **Map & Addon Download** - Downloads maps and Workshop collections automatically
- 👮 **Admin Setup** - Configures ULX/ULib admin mod with pre-configured admin users
- 🔐 **Server Configuration** - Interactive setup for server name, RCON password, and Steam token

## Requirements

- **Windows 10** or higher
- **PowerShell 5.1** or higher
- **Minimum 10 GB** free disk space
- **Internet connection** for downloads

## Quick Start

### Interactive Installation

1. Open PowerShell as Administrator
2. Navigate to the project directory
3. Run the setup script:

```powershell
.\setup-darkrp-server.ps1
```

4. Choose option **1** (Recommended Install) for complete setup
5. Follow the prompts to configure your server

### Automated Installation (Non-Interactive)

Run the script with all parameters to skip all prompts:

```powershell
.\setup-darkrp-server.ps1 -SkipMenu -ServerName "My DarkRP Server" -RconPassword "mypassword123" -SteamToken "YOUR_STEAM_TOKEN"
```

## Installation Options

The script provides a menu with the following options:

1. **Recommended Install** - Complete setup (Server + ULX + Content)
2. **Install/Update Server Only** - Just the server files
3. **Remove Server** - Uninstall the server
4. **Check Server Status** - Verify installation
5. **Install ULX/ULib** - Admin mod installation
6. **Download Standard DarkRP Content** - Map and collection download
7. **Download Custom Addons & Maps** - Custom content downloader
8. **Exit**

## What Gets Installed

### Recommended Install Includes:

- ✅ **SteamCMD** - Game server downloader
- ✅ **Garry's Mod Dedicated Server** - Server files
- ✅ **DarkRP Gamemode** - Roleplay gamemode
- ✅ **ULX/ULib** - Admin mod system
- ✅ **Standard Content**:
  - Map: `rp_downtown_v4c_v2` (Downloaded from GitHub)
  - Collection: DarkRP Mod Collection (ID: 2079133718)

## Configuration

### Server Settings

During installation, you'll be prompted for:

- **Server Name** - Display name in server browser
- **RCON Password** - Remote administration password
- **Steam Game Server Account Token** - For server browser listing

Get your Steam token from: https://steamcommunity.com/dev/managegameservers
- App ID: **4000** (Garry's Mod)

### Post-Installation Configuration

Edit `gmod-server\garrysmod\cfg\server.cfg` to customize:

- `hostname` - Server name
- `rcon_password` - RCON password
- `maxplayers` - Maximum players
- `sv_region` - Server region (255 = Europe)

## Script Parameters

### Full Parameter List

```powershell
.\setup-darkrp-server.ps1
    [-InstallPath <path>]           # Server installation path (default: .\gmod-server)
    [-SteamCMDPath <path>]          # SteamCMD path (default: .\steamcmd)
    [-AppId <id>]                   # App ID (default: 4020)
    [-SkipMenu]                     # Skip menu, start installation directly
    [-Remove]                       # Remove server
    [-CheckStatus]                  # Check server status
    [-ServerName <name>]            # Server name (hostname)
    [-RconPassword <password>]     # RCON password
    [-SteamToken <token>]           # Steam Game Server Account Token
```

### Examples

**Fully Automated:**
```powershell
.\setup-darkrp-server.ps1 -SkipMenu -ServerName "My Server" -RconPassword "pass123" -SteamToken "YOUR_TOKEN"
```

**Custom Installation Path:**
```powershell
.\setup-darkrp-server.ps1 -InstallPath "C:\Servers\DarkRP" -SteamCMDPath "C:\Tools\SteamCMD"
```

**With Pre-filled Configuration:**
```powershell
.\setup-darkrp-server.ps1 -ServerName "My Server" -RconPassword "pass123" -SteamToken "YOUR_TOKEN"
```
Then choose option 1 - configuration is already filled in.

## Starting the Server

After installation, start your server:

```batch
cd gmod-server
.\start-server.bat
```

Or manually:

```batch
srcds.exe -console -game garrysmod +gamemode darkrp +map rp_downtown_v4c_v2 +maxplayers 32 +host_workshop_collection 2079133718
```

## Admin Setup

### Adding Admins

1. **Via ULX (Recommended):**
   - Edit: `gmod-server\garrysmod\data\ulib\users.txt`
   - Format: `"STEAM_0:0:12345678" { "group" "superadmin" }`

2. **Via DarkRP:**
   - Edit: `gmod-server\garrysmod\data\darkrp.txt`
   - Format: `"STEAM_0:0:12345678" "superadmin"`

3. **Via Server Console:**
   ```
   ulx adduser STEAM_0:0:12345678 superadmin
   ```

See `docs/ADMIN_SETUP.md` for detailed instructions.

## File Structure

```
darkrp/
├── setup-darkrp-server.ps1          # Main setup script
├── download-standard-content.ps1     # Standard content downloader
├── download-darkrp-content.ps1       # Custom content downloader
├── install-ulx.ps1                  # ULX installer (integrated in main script)
├── rcon-connect.bat                 # RCON connection helper
├── docs/                             # Documentation
│   ├── ADMIN_SETUP.md               # Admin setup guide
│   ├── FIX_ADMIN.md                 # Admin troubleshooting
│   ├── DARKRP_COMMANDS.md           # Command reference
│   ├── AUTOMATED_INSTALL.md         # Non-interactive guide
│   └── SETUP_OVERVIEW.md            # Complete overview
├── .gitignore                        # Git ignore rules
└── README.md                         # This file
```

## Port Forwarding

For a public server, open these ports:

- **UDP 27015** - Server query port
- **UDP 27005** - Client port
- **TCP 27015** - RCON port (optional)

## Troubleshooting

### Server Won't Start

1. Check if all files downloaded correctly
2. Verify firewall settings
3. Ensure map name has no spaces
4. Check server console for error messages

### DarkRP Not Loading

1. Verify DarkRP is installed in `garrysmod\gamemodes\darkrp`
2. Check console for error messages
3. Ensure `+gamemode darkrp` is in start command

### SteamCMD Issues

If you see "Missing configuration" for app 2430930:
- This is normal - the dependency downloads automatically when needed
- If SteamCMD was just installed, restart PowerShell and try again

### Admin Not Working

- Verify Steam ID format: `STEAM_0:0:12345678`
- Check admin files are in correct location
- Restart server after adding admins
- See `docs/FIX_ADMIN.md` for detailed troubleshooting

## Documentation

Additional documentation files in `docs/`:

- `ADMIN_SETUP.md` - How to add admins
- `FIX_ADMIN.md` - Admin troubleshooting
- `DARKRP_COMMANDS.md` - DarkRP command reference
- `AUTOMATED_INSTALL.md` - Non-interactive installation guide
- `SETUP_OVERVIEW.md` - Complete setup overview

## Features in Detail

### Recommended Install

Option 1 performs a complete installation:
1. Downloads and installs SteamCMD
2. Downloads Garry's Mod Dedicated Server
3. Installs DarkRP gamemode
4. Installs ULX/ULib admin mod
5. Downloads standard map and collection
6. Configures server settings

### Server Configuration

The script prompts for:
- Server name (hostname)
- RCON password
- Steam Game Server Account Token (optional)

All settings are automatically applied to `server.cfg` and `start-server.bat`.

### ULX Integration

ULX/ULib is automatically installed and configured with:
- Pre-configured admin users
- Proper file structure
- Ready-to-use admin system

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This script is free to use and modify for personal use.

## Credits

- **DarkRP** - https://github.com/FPtje/DarkRP
- **ULX/ULib** - https://github.com/TeamUlysses
- **Garry's Mod** - https://gmod.facepunch.com/
- **SteamCMD** - https://developer.valvesoftware.com/wiki/SteamCMD

## Support

For issues and questions:
- Check the troubleshooting section
- Review the documentation files
- Check server console for error messages

## Disclaimer

This script is provided as-is. Make sure to:
- Change default passwords
- Configure firewall properly
- Use strong RCON passwords
- Keep server files updated
