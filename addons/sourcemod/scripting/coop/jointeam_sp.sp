#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <left4dhooks>
#include <colors>

#define TEAM_SPECTATORS 1
#define TEAM_SURVIVORS 2
#define TEAM_INFECTED 3
#define NULL_VELOCITY view_as<float>({0.0, 0.0, 0.0})
#define ZC_Tank 8
bool gameStarted;

int clientTimeout[MAXPLAYERS + 1] = {0, ...}; // 加载超时时间
bool isClientLoading[MAXPLAYERS + 1] = {false, ...};

// Handle sdkEndRound;

public Plugin myinfo =
{
	name 			= "Jointeam_sp",
	author 			= "海洋空氣,blueblur edited.",
	description 	= "加入生还者",
	version 		= "1.7",
	url 			= "https://steamcommunity.com/id/larkspur2017/"
}

public void OnPluginStart()
{
	RegConsoleCmd("sm_join", JoinTeam_Cmd, "Moves you to the survivor team");
	RegConsoleCmd("sm_joingame", JoinTeam_Cmd, "Moves you to the survivor team");
	RegConsoleCmd("sm_jg", JoinTeam_Cmd, "Moves you to the survivor team");

	HookEvent("round_start", Event_RoundStart);

	LoadTranslations("smac.phrases");


	// Handle g_hGameConf = LoadGameConfigFile("left4dhooks.l4d2");
	// if(g_hGameConf == INVALID_HANDLE)
	// {
	// 	SetFailState("Couldn't find the offsets and signatures file. Please, check that it is installed correctly.");
	// }
	// StartPrepSDKCall(SDKCall_Server);
	// PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CDirectorVersusMode::EndVersusModeRound");
	// PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	// PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	// sdkEndRound = EndPrepSDKCall();
	// if(sdkEndRound == INVALID_HANDLE)
	// {
	// 	SetFailState("Unable to find the \"CDirectorVersusMode::EndVersusModeRound\" signature, check the file version!");
	// }
}

public void OnMapStart()
{
	for (int i = 1; i <= MaxClients; ++i)
	{
		isClientLoading[i] = true;
		clientTimeout[i] = 0;
	}
	PrecacheSound("npc/virgil/c3end52.wav");
	PrecacheSound("npc/virgil/beep_error01.wav");
	PrecacheSound("player/survivor/voice/coach/worldc2m2b06.wav");

}

public void OnClientPutInServer(int client)
{
	if ( !isClientValid(client) || gameStarted) return;
}

public void L4D_OnFirstSurvivorLeftSafeArea_Post(int client)
{
	gameStarted = true;
}

////////////////////////////////////////////////////
//                    JoinTeam                    //
////////////////////////////////////////////////////

public Action JoinTeam_Cmd(int client, int args)
{
	if (gameStarted) {
		if (getTotalSurvivors() > getHumanSurvivors()) { // 生还者位置 > 玩家生还者数量，允许加入接管 AI
			MoveToSurTimer(INVALID_HANDLE, client);
			return Plugin_Continue;
		}
		return Plugin_Handled;
	}
	CreateTimer(0.7, MoveToSurTimer, client);
	return Plugin_Continue;
}

public Action Menu_SwitchCharacters(int client)
{
	// 创建面板
	Menu menu = CreateMenu(CharactersMenuHandler);
	SetMenuTitle(menu, "切换人物");
	SetMenuExitButton(menu, true);

	// 添加空闲AI到面板
	int j = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			char id[32];
			char BotName[32];
			char sMenuEntry[8];
			GetClientName(i, BotName, sizeof(BotName));
			GetClientAuthId(i, AuthId_Steam3, id, sizeof(id));
			if (StrEqual(id, "BOT")  && GetClientTeam(i) == TEAM_SURVIVORS)
			{
				GetClientName(i, BotName, sizeof(BotName));
				IntToString(j, sMenuEntry, sizeof(sMenuEntry));
				AddMenuItem(menu, sMenuEntry, BotName);
				j++;
			}
		}
	}
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	return Plugin_Continue;
}

public int CharactersMenuHandler(Menu menu, MenuAction action, int client, int param)
{
	if (!gameStarted && action == MenuAction_Select) {
		char BotName[32];
		GetMenuItem(menu, param, BotName, sizeof(BotName), _,BotName, sizeof(BotName));
		ChangeClientTeam(client, 1);
		ClientCommand(client, "jointeam 2 %s", BotName);
	}
	return 1;
}

public Action Event_RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	gameStarted = false;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (isClientValid(i) && GetClientTeam(i) == TEAM_SPECTATORS)
		{

		}
	}
	return Plugin_Continue;
}

public Action L4D_OnEnterGhostStatePre(int client)
{
	if ( isClientValid(client) ) {
		// CreateTimer(0.1, MoveToSpecTimer, client);
		ChangeClientTeam(client, TEAM_SPECTATORS);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action MoveToSurTimer(Handle timer, int client)
{
	if (!isClientValid(client)) return Plugin_Handled;
	if (GetClientTeam(client) == TEAM_SURVIVORS)
	{
		Menu_SwitchCharacters(client);
		return Plugin_Handled;
	}
	FakeClientCommand(client, "jointeam 2");
	return Plugin_Continue;
}

int getTotalSurvivors() // total survivors, including bots
{
	int count = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientConnected(i))
		{
			if(IsClientInGame(i) && (GetClientTeam(i) == TEAM_SURVIVORS))
				count++;
		}
	}
	return count;
}

int getHumanSurvivors() // survivor players
{
	int count = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if(isSurvivor(i))
			count++;
	}
	return count;
}

bool isClientValid(int client)
{
	if (client <= 0 || client > MaxClients) return false;
	if (!IsClientConnected(client)) return false;
	if (!IsClientInGame(client)) return false;
	if (IsFakeClient(client)) return false;
	return true;
}

bool isSurvivor(int client)
{
	return isClientValid(client) && GetClientTeam(client) == TEAM_SURVIVORS;
}