# How to Make Someone Admin on Your DarkRP Server

There are several ways to make someone an admin on your DarkRP server. Here are the most common methods:

## Method 1: Using DarkRP's Built-in Admin System (Recommended)

### Step 1: Get the Player's Steam ID

1. Have the player join your server
2. Open your server console (the window where the server is running)
3. Type: `status`
4. Look for the player's Steam ID in the format: `STEAM_0:0:12345678`

**Alternative:** If the player is online, you can also use:
- In-game console: `status` (shows all connected players)
- Or check the server logs

### Step 2: Add to Admin File

1. Open the file: `gmod-server\garrysmod\data\darkrp.txt`
2. Add a line with the Steam ID and rank:
   ```
   "STEAM_0:0:12345678" "superadmin"
   ```
3. Save the file
4. Restart the server (recommended) or use DarkRP reload command

### Available Ranks:
- `superadmin` - Full access to all DarkRP commands
- `admin` - Access to most admin commands  
- `moderator` - Limited admin access

## Method 2: Using ULX/ULib (If Installed)

If you have ULX installed (popular admin mod), you can add admins through:

1. **In-game (if you're already admin):**
   - Open console (press `~`)
   - Type: `ulx adduser <player_name> superadmin`
   - Or: `ulx adduser <steamid> superadmin`

2. **Via Configuration File:**
   - Edit: `gmod-server\garrysmod\data\ulib\users.txt`
   - Format: `"STEAM_0:0:12345678" { "group" "superadmin" }`

## Method 3: Using Server Console Commands

If you have RCON access:

1. Connect via RCON or use the server console
2. Type: `ulx adduser <steamid> superadmin`
3. Or use DarkRP commands if available

## Method 4: Using F4 Menu (In-Game)

If you're already an admin:

1. Join the server
2. Press `F4` to open the DarkRP menu
3. Go to Admin section
4. Use the admin tools to promote players

## Quick Reference Commands

### In Server Console:
```
status                    // Show all connected players with Steam IDs
ulx who                   // Show players (if ULX installed)
ulx adduser <steamid> superadmin  // Add admin via ULX
darkrp reload            // Reload DarkRP (if available)
```

### Finding Steam ID Online:
- Visit: https://steamid.io/
- Enter the player's Steam profile URL
- Get their Steam ID in various formats

## Important Notes:

1. **Steam ID Format:** Always use the format `STEAM_0:0:12345678` (not Steam64 ID)
2. **File Location:** Admin files are in `garrysmod\data\` directory
3. **Restart Required:** Some changes require a server restart
4. **Security:** Never share your admin files publicly
5. **Backup:** Always backup admin files before making changes

## Troubleshooting:

- **Admin not working?** Check that the Steam ID is correct and the file is saved
- **Can't find Steam ID?** Use `status` command in server console when player is online
- **File not found?** Create the file if it doesn't exist
- **Changes not applying?** Restart the server or use `refresh` command

## Example Admin File:

```
// DarkRP Admin Configuration
"STEAM_0:0:12345678" "superadmin"
"STEAM_0:1:87654321" "admin"
"STEAM_0:0:11223344" "moderator"
```

