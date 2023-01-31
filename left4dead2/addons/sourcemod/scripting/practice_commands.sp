#pragma semicolon 1
#pragma newdecls required;

#include <sourcemod>

#undef REQUIRE_PLUGIN
#include <readyup>
#define REQUIRE_PLUGIN

#define TEAM_SPECTATORS         1
#define TEAM_SURVIVORS          2
#define TEAM_INFECTED           3

// ========================
//  Plugin Variables
// ========================
bool g_bGT_TankIsInPlay;
Handle hILife;
int ILife;

public Plugin myinfo =
{
	name = "Practice Commands",
	author = "lechuga",
	description = "commands for practice support",
	version = "1.2",
	url = "https://github.com/lechuga16/practiceogl_rework"
}

public void OnPluginStart()
{
	// ConVar
	hILife = CreateConVar("initial_life", "10000", "Maximum life at startup", 0, true, 1.0);
	ILife = GetConVarInt(hILife);
	HookConVarChange(hILife, CVarChanged);
	
	// Commands
	RegConsoleCmd("sm_rtank", Spawntank_Cmd, "respawn a tank");
	RegConsoleCmd("sm_rwitch", Spawnwitch_Cmd, "respawn a witch");
	
}

public void OnRoundIsLive()
{
	for (int client = 1; client <= MaxClients; client++){
		if (IsClientInGame(client) && GetClientTeam(client) == TEAM_SURVIVORS && IsPlayerAlive(client)){
			SetEntityHealth(client, ILife);
		}
	}
}

public bool IsTankInPlay()
{
	return g_bGT_TankIsInPlay;
}

public Action Spawntank_Cmd(int client, int args)
{
	if (GetClientTeam(client) == TEAM_SURVIVORS || GetClientTeam(client) == TEAM_INFECTED)
	{
		if (client > 0 && !IsTankInPlay())
		{
			int flags = GetCommandFlags("z_spawn");
			SetCommandFlags("z_spawn", flags ^ 16384);
			FakeClientCommand(client, "z_spawn tank");
			SetCommandFlags("z_spawn", flags);
		}
	}
	return Plugin_Continue;
}

public Action Spawnwitch_Cmd(int client, int args)
{
	if (GetClientTeam(client) == TEAM_SURVIVORS || GetClientTeam(client) == TEAM_INFECTED)
	{
		if (client > 0)
		{
			int flags = GetCommandFlags("z_spawn");
			SetCommandFlags("z_spawn", flags ^ 16384);
			FakeClientCommand(client, "z_spawn witch");
			SetCommandFlags("z_spawn", flags);
		}
	}
	return Plugin_Continue;
}

public int CVarChanged(Handle cvar, char[] oldValue, char[] newValue)
{
	ILife = GetConVarInt(hILife);
}