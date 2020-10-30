#include <sourcemod>
#include <gokz/anticheat>
#include <discord>

ConVar g_cvWebHookUrl;
ConVar g_cvClientName;
ConVar g_cvAnnounceCheat;
ConVar g_cvAnnounceMacro;
ConVar g_cvCheatEmbedColor;
ConVar g_cvMacroEmbedColor;
ConVar g_HostnameCvar;

char g_cMapName[128];

#define BAN_MSG "{\"username\": \"{BOTNAME}\",\"content\": \"A ban has been issued for {INFRACTION} on {HOSTNAME}\",\"attachments\": [{\"color\": \"{COLOR}\",\"title\": \"Global API Player Check\",\"title_link\": \"http://kztimerglobal.com/api/v2.0/bans?steamid64={STEAMID}\",\"fields\": [{\"title\": \"Player\",\"value\": \"[{PLAYER}](https://steamcommunity.com/profiles/{STEAMID})\",\"short\": true},{\"title\": \"Map\",\"value\": \"{MAP}\",\"short\": true},{\"title\": \"Notes\",\"value\": \"{NOTES}\",\"short\": true},{\"title\": \"Stats\",\"value\": \"```{STATS}```\",\"short\": true}],\"footer_icon\": \"https://snksrv.com/kzlogos.png\",\"ts\": \"{TIMESTAMP}\"}]}"


public Plugin myinfo =
{
	name = "GOKZ - Discord Ban Announcer",
	author = "sneaK",
	description = "Announcements on Discord when a ban is performed.",
	version = "1.0",
	url = "https://snksrv.com"
};

public void OnPluginStart()
{
	g_cvWebHookUrl = CreateConVar("kz_gokzban_discord_webhook", "GOKZ Ban", "Key value of webhook in discord.cfg", FCVAR_PROTECTED);
	g_cvClientName = CreateConVar("kz_gokzban_discord_name", "GOKZ Bans", "Name of the bot");
	g_cvAnnounceCheat = CreateConVar("kz_gokzban_discord_cheat", "1", "Enable/Disable announcement of cheat bans to Discord");
	g_cvAnnounceMacro = CreateConVar("kz_gokzban_discord_macro", "1", "Enable/Disable announcement of macro bans to Discord");
	g_cvCheatEmbedColor = CreateConVar("kz_gokzban_discord_cheatcolor", "#FF0000", "Embed hex color for cheat bans");
	g_cvMacroEmbedColor = CreateConVar("kz_gokzban_discord_macrocolor", "#FF6400", "Embed hex color for macro bans");

	AutoExecConfig(true, "gokzban_discord");

	g_HostnameCvar = FindConVar("hostname");
}

public void OnMapStart()
{
	// Get mapname
	GetCurrentMap(g_cMapName, 128);

	// Workshop fix
	char mapPieces[6][128];
	int lastPiece = ExplodeString(g_cMapName, "/", mapPieces, sizeof(mapPieces), sizeof(mapPieces[]));
	Format(g_cMapName, sizeof(g_cMapName), "%s", mapPieces[lastPiece - 1]);
}

public void GOKZ_AC_OnPlayerSuspected(int client, ACReason reason, const char[] notes, const char[] stats)
{
	if ((reason == ACReason_BhopHack && !g_cvAnnounceCheat.BoolValue) || (reason == ACReason_BhopMacro && !g_cvAnnounceMacro.BoolValue))
	{
		return;
	}
	
	char player_name[(MAX_NAME_LENGTH + 1) * 2];	// Needs to be doubled since we have to escape it
	GetClientName(client, player_name, sizeof(player_name));
	Discord_EscapeString(player_name, sizeof(player_name));

	char client_name[32];
	g_cvClientName.GetString(client_name, sizeof(client_name));
	
	char embed_color[32];
	char infraction[128];
	if (reason == ACReason_BhopHack)
	{
		g_cvCheatEmbedColor.GetString(embed_color, sizeof(embed_color));
		Format(infraction, sizeof(infraction), "Bhop Cheating");
	}
	else if (reason == ACReason_BhopMacro)
	{
		g_cvMacroEmbedColor.GetString(embed_color, sizeof(embed_color));
		Format(infraction, sizeof(infraction), "Bhop Macroing");
	}
	
	char steamid[66];
	GetClientAuthId(client, AuthId_SteamID64, steamid, sizeof(steamid));

	char g_HostName[256];
	g_HostnameCvar.GetString(g_HostName, sizeof(g_HostName));

	int gettime = GetTime();
	char szTimestamp[64]; IntToString(gettime, szTimestamp, sizeof(szTimestamp));

	char msg[2048] = BAN_MSG;
	ReplaceString(msg, sizeof(msg), "{BOTNAME}", client_name);
	ReplaceString(msg, sizeof(msg), "{COLOR}", embed_color);
	ReplaceString(msg, sizeof(msg), "{PLAYER}", player_name);
	ReplaceString(msg, sizeof(msg), "{INFRACTION}", infraction);
	ReplaceString(msg, sizeof(msg), "{NOTES}", notes);
	ReplaceString(msg, sizeof(msg), "{STATS}", stats);
	ReplaceString(msg, sizeof(msg), "{MAP}", g_cMapName);
	ReplaceString(msg, sizeof(msg), "{HOSTNAME}", g_HostName);
	ReplaceString(msg, sizeof(msg), "{STEAMID}", steamid);
	ReplaceString(msg, sizeof(msg), "{TIMESTAMP}", szTimestamp);

	char webhook_url[128];
	g_cvWebHookUrl.GetString(webhook_url, sizeof(webhook_url));

	Discord_SendMessage(webhook_url, msg);
}
