# GOKZ Discord Ban Announcer
Discord notifier for GOKZ bans. This posts a webhook to a channel of your choosing with a rich embed, and details of the ban. As it stands, the only bans GOKZ automatically issues are for Bhop Cheats & Macros, so those are the only types supported as of this version.

## Requirements
- [GOKZ](https://bitbucket.org/kztimerglobalteam/gokz/)
- [Zipcore's Discord API](https://forums.alliedmods.net/showthread.php?t=292663)

## ConVars
`kz_gokzban_discord_webhook` - Key value of webhook in discord.cfg  
`kz_gokzban_discord_name` - Name of the bot  
`kz_gokzban_discord_cheat` - Enable/Disable announce of cheat bans to Discord  
`kz_gokzban_discord_macro` - Enable/Disable announce of macro bans to Discord  
`kz_gokzban_discord_cheatcolor` - Embed hex color for cheat bans  
`kz_gokzban_discord_macrocolor` - Embed hex color for macro bans  
