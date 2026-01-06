# DarkRP Server Setup - Complete Guide

## One Script to Rule Them All! 🎮

Je hebt nu **één hoofdscript** dat alles beheert: `setup-darkrp-server.ps1`

Dit script doet **alles** wat je nodig hebt om een werkende DarkRP server op te zetten van 0 tot 100%.

## Wat het Script Doet

### Menu Opties:

1. **Install/Update Server** - Installeert/update de volledige server
   - Downloadt SteamCMD
   - Downloadt Garry's Mod server
   - Downloadt DarkRP gamemode
   - Maakt configuratie bestanden aan
   - Maakt start script aan

2. **Remove Server** - Verwijdert de server volledig
   - Verwijdert server directory
   - Optioneel: verwijdert SteamCMD

3. **Check Server Status** - Controleert server status
   - Checkt of server geïnstalleerd is
   - Checkt of DarkRP geïnstalleerd is
   - Checkt configuratie bestanden
   - Toont overzicht van status

4. **Install ULX/ULib** - Installeert admin mod
   - Downloadt ULX van GitHub
   - Downloadt ULib van GitHub
   - Maakt admin gebruikers bestand aan
   - **Nieuw geïntegreerd!**

5. **Download Standard DarkRP Content** - Download standaard content
   - Downloadt rp_downtown_v4c_v2 map
   - Geeft instructies voor Workshop Collection

6. **Download DarkRP Addons & Maps (Custom)** - Download custom content
   - Menu voor custom maps
   - Menu voor custom addons
   - Menu voor Workshop Collections

7. **Exit** - Sluit het script

## Complete Setup Flow

### Stap 1: Basis Installatie
```
.\setup-darkrp-server.ps1
```
Kies optie **1** - Dit installeert:
- SteamCMD
- Garry's Mod Dedicated Server
- DarkRP gamemode
- Basis configuratie bestanden

### Stap 2: ULX Installatie (Optioneel maar Aanbevolen)
Kies optie **4** - Dit installeert:
- ULX admin mod
- ULib (vereist voor ULX)
- Admin gebruikers bestand

### Stap 3: Content Downloaden
Kies optie **5** of **6** - Download:
- Maps
- Addons
- Workshop Collections

### Stap 4: Server Starten
```
cd gmod-server
.\start-server.bat
```

## Bestanden Structuur

```
darkrp/
├── setup-darkrp-server.ps1          ← HOOFDSCRIPT (gebruik dit!)
├── download-standard-content.ps1     ← Wordt aangeroepen vanuit hoofdscript
├── download-darkrp-content.ps1      ← Wordt aangeroepen vanuit hoofdscript
├── install-ulx.ps1                  ← Nu geïntegreerd in hoofdscript (optie 4)
├── gmod-server/                     ← Server directory (na installatie)
│   ├── start-server.bat             ← Start de server
│   └── garrysmod/
│       ├── cfg/
│       │   └── server.cfg           ← Server configuratie
│       ├── data/
│       │   ├── darkrp.txt          ← DarkRP admin config
│       │   └── ulib/
│       │       └── users.txt       ← ULX admin config
│       └── gamemodes/
│           └── darkrp/             ← DarkRP gamemode
└── README.md                        ← Documentatie
```

## Belangrijke Bestanden

### Voor Server Configuratie:
- `gmod-server\garrysmod\cfg\server.cfg` - Server instellingen
- `gmod-server\start-server.bat` - Start script

### Voor Admin Setup:
- `gmod-server\garrysmod\data\ulib\users.txt` - ULX admins
- `gmod-server\garrysmod\data\darkrp.txt` - DarkRP admins
- `gmod-server\garrysmod\lua\darkrp_customthings\admins.lua` - DarkRP Lua admins

## Quick Start

1. **Open PowerShell** in de darkrp directory
2. **Run:** `.\setup-darkrp-server.ps1`
3. **Kies optie 1** - Installeer server
4. **Kies optie 4** - Installeer ULX (aanbevolen)
5. **Kies optie 5** - Download standaard content
6. **Start server:** `cd gmod-server` → `.\start-server.bat`

## Alle Functionaliteit in Één Script

Het hoofdscript (`setup-darkrp-server.ps1`) bevat nu:
- ✅ Server installatie
- ✅ Server verwijdering
- ✅ Status check
- ✅ ULX installatie (geïntegreerd!)
- ✅ Content download (via sub-scripts)

**Je hebt nu één script dat alles doet!** 🎉

## Hulp Bestanden

- `README.md` - Basis documentatie
- `ADMIN_SETUP.md` - Hoe admins toevoegen
- `FIX_ADMIN.md` - Admin problemen oplossen
- `DARKRP_COMMANDS.md` - DarkRP commando's
- `QUICK_ADMIN_FIX.md` - Snelle admin fix
- `CHECK_ADMIN_STATUS.md` - Admin status checken

## Tips

- **Eerste keer?** Volg de Quick Start stappen
- **Server update?** Kies optie 1 (update automatisch)
- **Problemen?** Kies optie 3 om status te checken
- **Admin niet werkend?** Zie FIX_ADMIN.md
- **Commando's?** Zie DARKRP_COMMANDS.md

## Ondersteuning

Alle documentatie staat in de `.md` bestanden. Het hoofdscript heeft alles wat je nodig hebt!

