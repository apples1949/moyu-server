#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION "1.0"

#define NULL_VELOCITY view_as<float>({0.0, 0.0, 0.0})

//Timer
new Handle:TimerH = INVALID_HANDLE;
new Handle:cvarGameMode = INVALID_HANDLE;

public Plugin:myinfo =
{
	name = "L4D2 No Mercy Rooftop Scavenge Fix Special",
	author = "Ratchet, A1R",
	description = "Fixes No Mercy 5 scavenge. Also help the survivor not to fall on the ground.",
	version = PLUGIN_VERSION,
	url = ""
}

public OnMapStart()
{
	decl String:mapname[128];
	GetCurrentMap(mapname, sizeof(mapname));
	
	if( TimerH != INVALID_HANDLE )
		KillTimer(TimerH);
		
	TimerH = INVALID_HANDLE;
		
	if (strcmp(mapname, "c8m5_rooftop") != 0)
		return;
		
	cvarGameMode = FindConVar("mp_gamemode");
	
	decl String:sGameMode[32];
	GetConVarString(cvarGameMode, sGameMode, sizeof(sGameMode));
	if (strcmp(sGameMode, "scavenge") != 0)
		return;
		
	TimerH = CreateTimer(1.5, ScavTimerH, _, TIMER_REPEAT);
}

public Action:ScavTimerH(Handle:Timer, any:Client)
{		
	FindMisplacedCans();
}

stock FindMisplacedCans()
{
	new ent = -1;
	
	while ((ent = FindEntityByClassname(ent, "weapon_gascan")) != -1)
	{
		if (!IsValidEntity(ent)) 
			continue;

		new Float:position[3];
		GetEntPropVector(ent, Prop_Send, "m_vecOrigin", position);
		
		if( position[2] <= 5500.0 )
		if( position[0] > 0.0 && position[1] > 0.0 && position[2] )	//HACK HACK! Although it's impossible for can to go to 0 0 0 in NM5
			Ignite( ent );
	}

	for (new client = 1; client <= MAXPLAYERS; client++)
	{
		new Float:Sposition[3];
		GetClientAbsOrigin(client, Sposition);
		if (Sposition[2] <= 5500 && IsValidPlayer(client))
		{
			int warp_flags;
			warp_flags = GetCommandFlags("warp_to_start_area");
			SetCommandFlags("warp_to_start_area", warp_flags & ~FCVAR_CHEAT);
			FakeClientCommand(client, "warp_to_start_area");
			SetCommandFlags("warp_to_start_area", warp_flags);
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, NULL_VELOCITY);
		}
	}
	
}

static bool IsValidPlayer(int client)
{
	if (0 < client <= MaxClients)
		return true;
	return false;
}

stock Ignite(entity)
{
	AcceptEntityInput(entity, "ignite");
	PrintToChatAll( "Gascan out of bounds! Ignited!" );
}

stock FindEntityByClassname2(startEnt, const String:classname[])
{
	while (startEnt > -1 && !IsValidEntity(startEnt)) startEnt--;
	return FindEntityByClassname(startEnt, classname);
}