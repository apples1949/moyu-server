#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <colors>

#define PLUGIN_VERSION "2.0"

//Timer
Handle
	TimerH = INVALID_HANDLE,
	cvarGameMode = INVALID_HANDLE;

public Plugin myinfo =
{
	name = "L4D2 No Mercy Rooftop Scavenge Fix",
	author = "Ratchet, modified by blueblur",
	description = "Fixes No Mercy 5 scavenge.",
	version = PLUGIN_VERSION,
	url = "https://github.com/blueblur0730/moyu-server"
};

public void OnPluginStart()
{
	LoadTranslations("l4d2_scav_fix_nm5.phrases");
}

public void OnMapStart()
{
	char mapname[128];
	GetCurrentMap(mapname, sizeof(mapname));
	
	if( TimerH != INVALID_HANDLE )
		KillTimer(TimerH);
		
	TimerH = INVALID_HANDLE;
		
	if (strcmp(mapname, "c8m5_rooftop") != 0)
	{
		PrintToConsoleAll("Not c8m5");
		if (strcmp(mapname, "exempt_dontfall_update") != 0)
		{
			PrintToConsoleAll("Not DontFall");
			return;
		}
	}
		
	cvarGameMode = FindConVar("mp_gamemode");
	
	char sGameMode[32];
	GetConVarString(cvarGameMode, sGameMode, sizeof(sGameMode));
	if (strcmp(sGameMode, "scavenge") != 0)
		return;
		
	TimerH = CreateTimer(15.0, ScavTimerH, _, TIMER_REPEAT);
}

public Action ScavTimerH(Handle Timer, any Client)
{		
	FindMisplacedCans();
	return Plugin_Handled;
}

stock void FindMisplacedCans()
{
	int ent = -1;
	
	while ((ent = FindEntityByClassname(ent, "weapon_gascan")) != -1)
	{
		if (!IsValidEntity(ent)) 
			continue;

		float position[3];
		GetEntPropVector(ent, Prop_Send, "m_vecOrigin", position);
		
		if( position[2] <= 500.0 )
		if( position[0] > 0.0 && position[1] > 0.0 && position[2] )	//HACK HACK! Although it's impossible for can to go to 0 0 0 in NM5
			Ignite(ent);
	}

	for (int client = 1; client <= MAXPLAYERS; client++)
	{
		float Sposition[3];
		GetClientAbsOrigin(client, Sposition);
		if (Sposition[2] <= 500 && IsValidPlayer(client))
		{
			ForcePlayerSuicide(client); //You should not be alive in this place
			//PrintToChatAll("%s Just die in void.", client);
		}
	}
	
}

static bool IsValidPlayer(int client)
{
	if (0 < client <= MaxClients)
		return true;
	return false;
}

stock bool Ignite(int entity)
{
	AcceptEntityInput(entity, "ignite");
	CPrintToChatAll("%t", "Ignite");		//"Gascan out of bounds! Ignited!"
	return Plugin_Handled;
}

stock bool FindEntityByClassname2(int startEnt, char classname[64])
{
	while (startEnt > -1 && !IsValidEntity(startEnt)) startEnt--;
	return FindEntityByClassname(startEnt, classname);
}