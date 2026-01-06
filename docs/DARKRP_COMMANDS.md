# DarkRP Commands Guide

## Money Commands

### /addmoney Command

**Usage:**
```
/addmoney <player_name> <amount>
```

**Examples:**
```
/addmoney John 1000
/addmoney "Player Name" 5000
/addmoney STEAM_0:0:418798673 10000
```

**Requirements:**
- You must be **superadmin** or **admin** to use this command
- Can be used in chat (type `/addmoney`) or console
- Amount can be positive (give money) or negative (take money)

**In Chat:**
- Type: `/addmoney John 1000`
- Press Enter

**In Console:**
- Press `~` to open console
- Type: `rp addmoney John 1000`
- Or: `darkrp addmoney John 1000`

### Other Money Commands

**Give yourself money:**
```
/addmoney <your_name> <amount>
```

**Take money from player:**
```
/addmoney <player_name> -<amount>
```
Example: `/addmoney John -500` (takes 500 from John)

**Set player money:**
```
/setmoney <player_name> <amount>
```

**Check your money:**
- Press `F4` and look at your money
- Or check the HUD (top right usually)

## Admin Commands

### Player Management

**Kick player:**
```
/kick <player_name> <reason>
```

**Ban player:**
```
/ban <player_name> <time_in_minutes> <reason>
```

**Unban player:**
```
/unban <steam_id>
```

**Teleport to player:**
```
/goto <player_name>
```

**Bring player to you:**
```
/bring <player_name>
```

**Return player to spawn:**
```
/return <player_name>
```

### Job Management

**Set player job:**
```
/setjob <player_name> <job_name>
```

**Force player to change job:**
```
/forcejob <player_name> <job_name>
```

### Entity Management

**Remove all props:**
```
/removeprops
```

**Remove all vehicles:**
```
/removevehicles
```

**Remove all NPCs:**
```
/removenpcs
```

**Cleanup map:**
```
/cleanup
```

## DarkRP Specific Commands

### Laws

**Add law:**
```
/addlaw <law_text>
```

**Remove law:**
```
/removelaw <law_number>
```

### Wanted System

**Make player wanted:**
```
/wanted <player_name> <reason>
```

**Remove wanted status:**
```
/unwanted <player_name>
```

### Warrants

**Create warrant:**
```
/warrant <player_name> <reason>
```

**Remove warrant:**
```
/unwarrant <player_name>
```

## Using Commands

### Method 1: Chat (Recommended)

1. Press `Enter` or `Y` to open chat
2. Type `/` followed by the command
3. Example: `/addmoney John 1000`
4. Press `Enter`

### Method 2: Console

1. Press `~` (tilde key) to open console
2. Type the command (without `/`)
3. Example: `rp addmoney John 1000`
4. Press `Enter`

### Method 3: F4 Menu

1. Press `F4` to open DarkRP menu
2. Navigate to Admin section
3. Use the GUI to perform actions

## Command Permissions

- **Superadmin:** All commands
- **Admin:** Most commands (some restrictions)
- **Moderator:** Limited commands (kick, warn, etc.)
- **Regular Player:** No admin commands

## Troubleshooting

### "You don't have permission"
- Make sure you're admin/superadmin
- Check your Steam ID is in the admin file
- Restart server if you just added yourself

### "Player not found"
- Make sure you spell the name correctly
- Use quotes if name has spaces: `/addmoney "Player Name" 1000`
- Or use Steam ID: `/addmoney STEAM_0:0:12345678 1000`

### "Unknown command"
- Make sure DarkRP is loaded
- Check you're using the correct syntax
- Some commands might need ULX installed

## Quick Reference

**Most Used Commands:**
```
/addmoney <player> <amount>     - Give/take money
/setjob <player> <job>          - Change player job
/kick <player> <reason>         - Kick player
/ban <player> <time> <reason>    - Ban player
/goto <player>                  - Teleport to player
/bring <player>                 - Bring player to you
/cleanup                        - Clean up map
```

## Finding Player Names

**In-game:**
- Press `Tab` to see scoreboard
- Look at player list

**In server console:**
- Type: `status`
- Shows all players with Steam IDs

**In-game console:**
- Type: `ulx who` (if ULX installed)
- Shows all players with admin status

