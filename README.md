# DarkRP Server Setup Script

One-click PowerShell script to set up a complete Garry's Mod DarkRP server.

## Requirements

- Windows 10+
- PowerShell 5.1+
- 10 GB free space
- Internet connection

## Quick Start

**Run as Administrator:**

```powershell
.\setup-darkrp-server.ps1
```

Choose option **1** (Recommended Install) and follow the prompts.

**Fully Automated:**

```powershell
.\setup-darkrp-server.ps1 -SkipMenu -ServerName "My Server" -RconPassword "pass123" -SteamToken "YOUR_TOKEN"
```

Get your Steam token here: https://steamcommunity.com/dev/managegameservers (App ID: 4000)

## Start Server

```batch
cd gmod-server
.\start-server.bat
```

## Add Admins

Edit `gmod-server\garrysmod\data\ulib\users.txt`:

```
"STEAM_0:0:12345678" { "group" "superadmin" }
```

## Port Forwarding

- **UDP 27015** - Server port
- **UDP 27005** - Client port

## That's It

Check `docs/` folder for more details if needed.
