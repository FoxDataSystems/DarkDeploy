# How to Check if You're Admin/Superadmin

There are several ways to verify if you have admin privileges on the DarkRP server:

## Method 1: In-Game Check

### Check F4 Menu
1. Join the server
2. Press `F4` to open the DarkRP menu
3. If you see admin options (like "Admin", "Manage Jobs", "Manage Laws", etc.), you're admin
4. If you see "Superadmin" or have access to all admin features, you're superadmin

### Check Scoreboard
1. Press `Tab` to open the scoreboard
2. Look for your name - admins usually have a different color or icon
3. Some scoreboards show admin rank next to your name

### Try Admin Commands
Open console (press `~`) and try:
```
ulx who
```
If you see your name with "superadmin" or "admin" next to it, you have admin rights.

## Method 2: Server Console Check

### Check Status Command
In the server console, type:
```
status
```
This shows all connected players. Look for your Steam ID and check if admin privileges are shown.

### Check ULX Users (if ULX is installed)
In server console:
```
ulx who
```
This shows all players with their admin ranks.

### Check via RCON
If you have RCON access:
```
rcon status
rcon ulx who
```

## Method 3: Test Admin Commands

### Try Basic Admin Commands
In-game console (`~`):
```
ulx help          // Shows available commands (if ULX installed)
ulx who           // Shows admin list
```

### Try DarkRP Admin Commands
```
darkrp reload     // Reload DarkRP (admin only)
```

### Try Spawning Admin Items
- Try to spawn admin-only entities
- Try to use admin tools
- Check if you can access admin panels

## Method 4: Check Admin Files

### Check darkrp.txt
Look in: `gmod-server\garrysmod\data\darkrp.txt`

Your Steam ID should be listed with "superadmin" rank:
```
"STEAM_0:1:457684139" "superadmin"
```

### Check ULX Users File (if ULX installed)
Look in: `gmod-server\garrysmod\data\ulib\users.txt`

Your Steam ID should be listed:
```
"STEAM_0:1:457684139" { "group" "superadmin" }
```

## Method 5: Visual Indicators

### In-Game Indicators
- **Admin Chat**: Your messages might appear in a different color
- **Name Tag**: Your name might have [ADMIN] or [SUPERADMIN] prefix
- **Scoreboard**: Different icon or color
- **F4 Menu**: Admin section visible

## Quick Test Commands

### In Server Console:
```
status                    // Shows all players
ulx who                   // Shows admin list (if ULX)
```

### In-Game Console (`~`):
```
ulx who                   // Check admin status
ulx help                  // See available commands
```

### Via RCON:
```
rcon status
rcon ulx who
```

## Troubleshooting

### Not Showing as Admin?

1. **Check Steam ID Format:**
   - Make sure it's exactly: `STEAM_0:1:457684139`
   - Check for typos in the admin file

2. **Server Restart Required:**
   - Admin files are loaded when server starts
   - Restart the server after adding admins

3. **Check File Location:**
   - DarkRP: `garrysmod\data\darkrp.txt`
   - ULX: `garrysmod\data\ulib\users.txt`

4. **Verify Steam ID:**
   - Join the server
   - Type `status` in server console
   - Check your exact Steam ID format

5. **Check for Multiple Admin Systems:**
   - DarkRP has its own admin system
   - ULX is a separate admin mod
   - Make sure you're using the right system

## Common Issues

### "I'm in the file but not admin"
- Server needs to be restarted
- Check Steam ID format matches exactly
- Make sure there are no extra spaces

### "ULX commands don't work"
- ULX might not be installed
- Check if ULX is in your addons folder
- DarkRP uses its own admin system, not just ULX

### "F4 menu shows no admin options"
- You might not have admin rights
- Check the admin file again
- Restart the server

