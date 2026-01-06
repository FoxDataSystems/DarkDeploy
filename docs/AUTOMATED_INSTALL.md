# Automated/Non-Interactive Installation

Het script kan volledig automatisch draaien zonder tussenkomst door parameters mee te geven.

## Parameters

Het script accepteert de volgende parameters voor automatische installatie:

- `-ServerName` - De naam van je server (hostname)
- `-RconPassword` - Het RCON wachtwoord voor server beheer
- `-SteamToken` - Je Steam Game Server Account Token (optioneel)

## Voorbeelden

### Volledig Automatische Installatie

```powershell
.\setup-darkrp-server.ps1 -SkipMenu -ServerName "My DarkRP Server" -RconPassword "mypassword123" -SteamToken "YOUR_STEAM_TOKEN_HERE"
```

Dit zal:
- Het menu overslaan
- Direct beginnen met installatie
- Alle configuratie automatisch invullen
- Geen vragen stellen

### Automatische Installatie Zonder Steam Token

```powershell
.\setup-darkrp-server.ps1 -SkipMenu -ServerName "My DarkRP Server" -RconPassword "mypassword123"
```

Steam token kan later worden toegevoegd in `server.cfg`.

### Recommended Install Met Parameters

```powershell
.\setup-darkrp-server.ps1 -ServerName "My DarkRP Server" -RconPassword "mypassword123" -SteamToken "YOUR_TOKEN"
```

Kies dan optie 1 (Recommended Install) - alle configuratie is al ingevuld.

### Aangepaste Installatie Locaties

```powershell
.\setup-darkrp-server.ps1 -SkipMenu `
    -InstallPath "C:\Servers\DarkRP" `
    -SteamCMDPath "C:\Tools\SteamCMD" `
    -ServerName "My Server" `
    -RconPassword "mypassword" `
    -SteamToken "YOUR_TOKEN"
```

## Volledige Parameter Lijst

```powershell
.\setup-darkrp-server.ps1
    [-InstallPath <path>]           # Server installatie locatie (default: .\gmod-server)
    [-SteamCMDPath <path>]          # SteamCMD locatie (default: .\steamcmd)
    [-AppId <id>]                    # App ID (default: 4020)
    [-SkipMenu]                      # Sla menu over, start direct installatie
    [-Remove]                         # Verwijder server
    [-CheckStatus]                   # Check server status
    [-ServerName <name>]             # Server naam (hostname)
    [-RconPassword <password>]       # RCON wachtwoord
    [-SteamToken <token>]            # Steam Game Server Account Token
```

## Gebruik in Scripts

Je kunt het script ook aanroepen vanuit andere scripts:

```powershell
# Installatie script
$ServerName = "My DarkRP Server"
$RconPassword = "SecurePassword123"
$SteamToken = "2B9954FDD2D09850BFC9ABE9048321D0"

.\setup-darkrp-server.ps1 `
    -SkipMenu `
    -ServerName $ServerName `
    -RconPassword $RconPassword `
    -SteamToken $SteamToken
```

## Batch File Voorbeeld

Maak een `install.bat` bestand:

```batch
@echo off
powershell.exe -ExecutionPolicy Bypass -File "setup-darkrp-server.ps1" ^
    -SkipMenu ^
    -ServerName "My DarkRP Server" ^
    -RconPassword "mypassword123" ^
    -SteamToken "YOUR_STEAM_TOKEN"
pause
```

## Tips

1. **Steam Token**: Als je de token niet hebt, kun je deze overslaan en later toevoegen
2. **Wachtwoorden**: Gebruik sterke wachtwoorden voor productie servers
3. **SkipMenu**: Gebruik `-SkipMenu` alleen als je alle parameters hebt
4. **Recommended Install**: Zonder `-SkipMenu` kun je nog steeds het menu gebruiken

## Veiligheid

⚠️ **Let op**: Wachtwoorden en tokens in command-line parameters zijn zichtbaar in process lists.

Voor productie servers:
- Gebruik environment variables
- Of voeg tokens handmatig toe aan configuratie bestanden
- Gebruik secure strings waar mogelijk

## Voorbeeld Met Environment Variables

```powershell
$env:GMOD_SERVER_NAME = "My Server"
$env:GMOD_RCON_PASSWORD = "mypassword"
$env:GMOD_STEAM_TOKEN = "YOUR_TOKEN"

.\setup-darkrp-server.ps1 -SkipMenu `
    -ServerName $env:GMOD_SERVER_NAME `
    -RconPassword $env:GMOD_RCON_PASSWORD `
    -SteamToken $env:GMOD_STEAM_TOKEN
```

