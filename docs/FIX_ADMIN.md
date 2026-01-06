# Fix Admin Issues - DarkRP Server

## Problem: ULX doesn't work and admin not working

DarkRP uses ULX/ULib for admin commands, but also has its own admin system. Here's how to fix it:

## Solution 1: Install ULX (Recommended - Do This First!)

**ULX is NOT installed yet.** Run the installation script:

1. **Run the ULX installer:**
   ```powershell
   .\install-ulx.ps1
   ```
   
   This will:
   - Download and install ULX from GitHub
   - Download and install ULib (required for ULX)
   - Create the admin users file with your Steam IDs

2. **Restart your server** after installation

3. **Verify ULX is working:**
   - Join the server
   - Open console (press `~`)
   - Type: `ulx who`
   - You should see player list with admin status

## Solution 2: Use DarkRP Lua Admin System (Alternative)

I've created a file: `gmod-server\garrysmod\lua\darkrp_customthings\admins.lua`

This file uses DarkRP's built-in admin system. Make sure:
1. The file exists at: `garrysmod\lua\darkrp_customthings\admins.lua`
2. Your Steam ID is correct
3. Server is restarted

**Note:** This method may not work if ULX is also installed (ULX takes priority).

## Solution 3: Manual ULX Installation

If the script doesn't work:

1. **Download ULX and ULib:**
   - ULX: https://github.com/TeamUlysses/ulx
   - ULib: https://github.com/TeamUlysses/ulib
   
2. **Extract to:**
   - `gmod-server\garrysmod\addons\ulx`
   - `gmod-server\garrysmod\addons\ulib`

3. **Create admin file:**
   - File: `gmod-server\garrysmod\data\ulib\users.txt`
   - Already created with your Steam IDs

## Solution 4: Add Admin via Server Console

**IMPORTANT:** You must use the **SERVER CONSOLE** (not in-game console) if you're not admin yet!

1. **In SERVER console (the window running the server), type:**
   ```
   ulx adduser STEAM_0:0:418798673 superadmin
   ulx adduser STEAM_0:1:457684139 superadmin
   ```
   
   **Use Steam ID directly, NOT player name!**

2. **Or in-game console (only if you're already admin):**
   - Press `~` to open console
   - Type: `ulx adduser <player_name> superadmin`
   - Or: `ulx adduser STEAM_0:0:418798673 superadmin`

**Common Error:** "No target found or target has immunity!"
- This means you're not admin yet OR using wrong syntax
- Solution: Use server console with Steam ID, or restart server after editing users.txt

## Check Your Steam ID

1. Join the server
2. In server console, type: `status`
3. Find your exact Steam ID
4. Make sure it matches EXACTLY in the admin file

## Quick Fix Steps:

1. **Install ULX first:**
   ```powershell
   .\install-ulx.ps1
   ```

2. **Restart server**

3. **Verify admin:**
   - Join server
   - Press F4 - should see admin options
   - Or type `ulx who` in console

4. **If still not working:**
   - Check Steam ID in `garrysmod\data\ulib\users.txt`
   - Make sure it matches exactly from `status` command
   - Restart server again

## Verify Admin Status:

1. Join server
2. Press F4 - should see admin options
3. Or type `ulx who` in console (if ULX installed)
4. Or type `ulx adduser` in console - should work if you're admin

## Troubleshooting:

- **ULX not found?** Run `.\install-ulx.ps1` to install it
- **Admin still not working?** Check Steam ID format exactly matches (use `status` command)
- **File not loading?** Make sure server is restarted
- **ULX commands not working?** Make sure both ULX and ULib are installed
- **"Unknown command ulx"?** ULX is not installed - run the installer script

