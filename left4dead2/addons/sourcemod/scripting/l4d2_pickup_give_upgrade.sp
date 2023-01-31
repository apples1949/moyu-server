#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdkhooks>
//#include <sdktools>
#define L4D2UTIL_STOCKS_ONLY 1
#include <l4d2util> //#include <weapons>
#include <colors>

public Plugin myinfo = 
{
	name = "L4D2 Drop Secondary",
	author = "J.Q",
	version = "1.1",
	description = "Testing Purposes"
}

public void OnPluginStart() 
{
	RegConsoleCmd("sm_gmlaser", Cmd_UpGrade, "upgrade command");
	RegConsoleCmd("sm_rmlaser", Cmd_RemoveGrade, "upgrade command");
	
	HookEvent("player_use", Event_OnPlayerUse, EventHookMode_Post);
}

public Action Cmd_UpGrade(int client, int args)
{
	int weapon = GetPlayerWeaponSlot(client, 0);
	if (IsValidSurvivor(client)) {
		char classname[64];
		GetEdictClassname(weapon, classname, sizeof(classname));
		if(StrEqual(classname, "weapon_sniper_scout")) {
			int flags = GetCommandFlags("upgrade_add");
			SetCommandFlags("upgrade_add", flags & ~FCVAR_CHEAT);
			FakeClientCommand(client, "upgrade_add laser_sight");
			SetCommandFlags("upgrade_add", flags|FCVAR_CHEAT);
		}
	}
}

public Action Cmd_RemoveGrade(int client, int args)
{
	int weapon = GetPlayerWeaponSlot(client, 0);
	if (IsValidSurvivor(client)) {
		SetEntProp(weapon, Prop_Send, "m_upgradeBitVec", 0);
	}
}

public void Event_OnPlayerUse(Event event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	int targetid = event.GetInt("targetid");

	if (IsValidSurvivor(client) && IsValidEntity(targetid)) {
		char sClassname[32];
		GetEntityClassname(targetid, sClassname, sizeof(sClassname));

		if (StrContains(sClassname, "sniper") != -1)
		{
			// We do an actual check of what the client has here because we deal with limitations in certain configs.
			// The limitation would cause the secondary to be set on the client while the client didn't even equip it.
			int iWeaponIndex = GetPlayerWeaponSlot(client, 0);

			if (IsValidEntity(iWeaponIndex)) {
				char sWeaponName[32];
				GetEntityClassname(iWeaponIndex, sWeaponName, sizeof(sWeaponName));

				if (StrEqual(sWeaponName, "weapon_sniper_scout")) {
					int flags = GetCommandFlags("upgrade_add");
					SetCommandFlags("upgrade_add", flags & ~FCVAR_CHEAT);
					FakeClientCommand(client, "upgrade_add laser_sight");
					SetCommandFlags("upgrade_add", flags|FCVAR_CHEAT);
				}
			}
		}
	}
}