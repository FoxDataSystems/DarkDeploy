# Quick Fix: "No target found or target has immunity!" Error

## The Problem

You're getting this error because:
1. **You're not admin yet** - The `users.txt` file needs a server restart to take effect
2. **Wrong command syntax** - You might be using a player name instead of Steam ID
3. **Using in-game console** - You need to use server console if you're not admin yet

## Solution: Make Yourself Admin First

### Method 1: Edit the File and Restart (Easiest)

1. **The file is already correct:** `gmod-server\garrysmod\data\ulib\users.txt`
   - Your Steam IDs are already in there
   
2. **Restart your server** - This is REQUIRED for the file to load

3. **After restart, join the server** - You should now be admin

### Method 2: Use Server Console (If Server is Running)

**In the SERVER CONSOLE (not in-game console):**

```
ulx adduser STEAM_0:0:418798673 superadmin
```

**Important:** 
- Use the **server console** (the window where the server is running)
- NOT the in-game console (press `~` in game)
- Use the Steam ID directly, not a player name

### Method 3: Check Your Steam ID First

1. **Join the server**
2. **In SERVER console, type:** `status`
3. **Find your exact Steam ID** - it should match one of these:
   - `STEAM_0:0:418798673`
   - `STEAM_0:1:457684139`
4. **If it's different, update the users.txt file** with your exact Steam ID

## Correct Command Syntax

### In Server Console:
```
ulx adduser STEAM_0:0:418798673 superadmin
```

### In-Game Console (only if you're already admin):
```
ulx adduser <player_name> superadmin
```
OR
```
ulx adduser STEAM_0:0:418798673 superadmin
```

## Why It's Not Working

- **"No target found"** = You're using a player name that doesn't exist or wrong syntax
- **"target has immunity"** = The player is already admin or has protection
- **Command not working** = You're not admin yet, so you can't use the command

## Step-by-Step Fix

1. **Stop the server**

2. **Verify the file:** `gmod-server\garrysmod\data\ulib\users.txt`
   - Should contain your Steam IDs
   - Format should be exactly as shown

3. **Start the server**

4. **Join the server**

5. **Test admin:**
   - Press `F4` - should see admin options
   - Or type `ulx who` in console

6. **If still not working:**
   - Check your Steam ID with `status` command in server console
   - Make sure it matches exactly in users.txt
   - Restart server again

## Alternative: Use Server Console Directly

If you can't restart the server right now:

1. **Open server console** (the window running the server)

2. **Type:**
   ```
   ulx adduser STEAM_0:0:418798673 superadmin
   ```
   (Replace with your actual Steam ID from `status` command)

3. **This should work immediately** without restart

## Verify It Worked

After making yourself admin:

1. **In-game, press `~`** (console)
2. **Type:** `ulx who`
3. **You should see your name with "superadmin"** next to it

Or:

1. **Press F4** in-game
2. **You should see admin options** in the menu

