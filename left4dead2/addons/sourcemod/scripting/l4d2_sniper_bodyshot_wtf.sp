#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdkhooks>
#include <left4dhooks>
#define L4D2UTIL_STOCKS_ONLY 1
#include <l4d2util>
#include <colors>

#define DEBUG 0

public const char g_sSniperWeapon[][ENTITY_MAX_NAME_LENGTH] =
{
	"weapon_sniper_scout",
	"weapon_sniper_awp"
};

bool g_bLateLoad = false;

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] sError, int iErrMax)
{
	g_bLateLoad = bLate;

	return APLRes_Success;
}

public Plugin myinfo =
{
	name = "L4D2 Sniper Hunter Bodyshot",
	author = "Visor, A1m`,J.Q",
	description = "Change sniper weapon's hitgroup damage multiplier against infecters",
	version = "2.2.1",
	url = "https://github.com/Attano/L4D2-Competitive-Framework"
}

public void OnPluginStart()
{
	if (g_bLateLoad) {
		for (int i = 1; i <= MaxClients; i++) {
			if (IsClientInGame(i)) {
				OnClientPutInServer(i);
			}
		}
	}
}

public void OnClientPutInServer(int iClient)
{
	SDKHook(iClient, SDKHook_TraceAttack, TraceAttack);
}

public Action TraceAttack(int iVictim, int &iAttacker, int &iInflictor, float &fDamage, \
								int &fDamageType, int &iAmmoType, int iHitBox, int iHitGroup)
{
	//!IsInfectedGhost(iVictim)
	if (!IsValidSurvivor(iAttacker) || !IsValidInfected(iVictim) || IsFakeClient(iAttacker)) {
		return Plugin_Continue;
	}

	int iWeapon = GetEntPropEnt(iAttacker, Prop_Send, "m_hActiveWeapon");
	if (iWeapon == -1) {
		return Plugin_Continue;
	}
	
	char sClassName[64];
	GetEdictClassname(iWeapon, sClassName, sizeof(sClassName));	
	if (!IsValidSniper(sClassName)) {
		return Plugin_Continue;
	}
	
#if DEBUG
	char szHitgroup[32];
	HitgroupToString(iHitGroup, szHitgroup, sizeof(szHitgroup));
	PrintToChatAll("Victim %N, attacker %N, hitgroup %s (%d), weapon: %s, ", iVictim, iAttacker, szHitgroup, iHitGroup, sClassName);
#endif

	if (GetEntProp(iVictim, Prop_Send, "m_zombieClass") == L4D2Infected_Tank) {
		float Distance = GetClientsDistance(iVictim, iAttacker);
				
		if (Distance == 500.00 || Distance < 500.00) {
			fDamage = 200.00;
			return Plugin_Changed;
		}
		if (Distance > 500.00) {
			float TankSpeed = GetEntPropFloat(iVictim, Prop_Data, "m_flGroundSpeed");
			if (TankSpeed == 0) {
				fDamage = 200.00;
				return Plugin_Changed;
			}
			if (TankSpeed > 0) {
				fDamage = 40.00;
				return Plugin_Changed;
			}
		}
	}

	if (GetEntProp(iVictim, Prop_Send, "m_zombieClass") == L4D2Infected_Smoker) {
		if (iHitGroup  == HITGROUP_HEAD) {
			CPrintToChatAll("{olive}%N{default}(Smoker)被{olive}%N{default}用狙击枪{red}爆头秒杀", iVictim, iAttacker);
			fDamage = 62.50;
			return Plugin_Changed;
		}
		
		if (iHitGroup  == HITGROUP_CHEST) {
			fDamage = 40.00;
			return Plugin_Changed;
		}
		
		if (iHitGroup  == HITGROUP_STOMACH) {
			fDamage = 40.00;		//*1.25
			return Plugin_Changed;
		}
		
		if (iHitGroup  == HITGROUP_LEFTARM || iHitGroup  == HITGROUP_RIGHTARM) {
			fDamage = 20.00;
			return Plugin_Changed;
		}
		
		if (iHitGroup  == HITGROUP_LEFTLEG || iHitGroup  == HITGROUP_RIGHTLEG) {
			fDamage = 20.00;
			return Plugin_Changed;
		}
	}
	
	if (GetEntProp(iVictim, Prop_Send, "m_zombieClass") == L4D2Infected_Boomer) {
		if (iHitGroup  == HITGROUP_HEAD) {
			CPrintToChatAll("{olive}%N{default}(Boomer)被{olive}%N{default}用狙击枪{red}爆头秒杀", iVictim, iAttacker);
			fDamage = 12.5;
			return Plugin_Changed;
		}
		else {
			fDamage = 50.00;
			return Plugin_Changed;
		}
	}
	
	if (GetEntProp(iVictim, Prop_Send, "m_zombieClass") == L4D2Infected_Hunter) {
		if (iHitGroup  == HITGROUP_HEAD) {
			CPrintToChatAll("{olive}%N{default}(Hunter)被{olive}%N{default}用狙击枪{red}爆头秒杀", iVictim, iAttacker);
			fDamage = 62.50;
			return Plugin_Changed;
		}
		
		if (iHitGroup  == HITGROUP_CHEST) {
			fDamage = 85.00;
			return Plugin_Changed;
		}
		
		if (iHitGroup  == HITGROUP_STOMACH) {
			fDamage = 68.00;		//*1.25
			return Plugin_Changed;
		}
		
		if (iHitGroup  == HITGROUP_LEFTARM || iHitGroup  == HITGROUP_RIGHTARM) {
			fDamage = 20.00;
			return Plugin_Changed;
		}
		
		if (iHitGroup  == HITGROUP_LEFTLEG || iHitGroup  == HITGROUP_RIGHTLEG) {
			fDamage = 20.00;
			return Plugin_Changed;
		}
	}
	
	if (GetEntProp(iVictim, Prop_Send, "m_zombieClass") == L4D2Infected_Spitter) {
		if (iHitGroup  == HITGROUP_HEAD) {
			CPrintToChatAll("{olive}%N{default}(Spitter)被{olive}%N{default}用狙击枪{red}爆头秒杀", iVictim, iAttacker);
			fDamage = 25.00;
			return Plugin_Changed;
		}
		fDamage = 64.00; 
		return Plugin_Changed;
	}
	
	if (GetEntProp(iVictim, Prop_Send, "m_zombieClass") == L4D2Infected_Jockey) {
		if (iHitGroup  == HITGROUP_HEAD) {
			CPrintToChatAll("{olive}%N{default}(Jockey)被{olive}%N{default}用狙击枪{red}爆头秒杀", iVictim, iAttacker);
			fDamage = 81.25;
			return Plugin_Changed;
		}
		else {
			fDamage = 72.00; 	
			return Plugin_Changed;
		}
	}
	
	if (GetEntProp(iVictim, Prop_Send, "m_zombieClass") == L4D2Infected_Charger) {
		if (iHitGroup  == HITGROUP_HEAD) {
			CPrintToChatAll("{olive}%N{default}(Charger)被{olive}%N{default}用狙击枪{red}爆头秒杀", iVictim, iAttacker);
			fDamage = 150.00; 			
			return Plugin_Changed;
		}
		else {
			float Distance = GetClientsDistance(iVictim, iAttacker);
				
			if (Distance == 500.00 || Distance < 500.00) {
				fDamage = 160.00;
				return Plugin_Changed;
			}
			else {
				fDamage = 20.00;
				return Plugin_Changed;
			}
		}
		//HITGROUP_STOMACH fDamage*1.25
	}
	
	return Plugin_Continue;
}

// Gets the distance between two survivors
// Accounting for any difference in height
stock float GetClientsDistance(int iVictim, int iAttacker)
{
	float iAttackerPos[3];
	float iVictimPos[3];
	float mins[3];
	float maxs[3];
	float halfHeight;
	GetClientMins(iVictim, mins);
	GetClientMaxs(iVictim, maxs);
	
	halfHeight = maxs[2] - mins[2] + 10;
	
	GetClientAbsOrigin(iVictim,iVictimPos);
	GetClientAbsOrigin(iAttacker,iAttackerPos);
	
	float posHeightDiff = iAttackerPos[2] - iVictimPos[2];
	
	if (posHeightDiff > halfHeight) {
		iAttackerPos[2] -= halfHeight;
	}
	else if (posHeightDiff < (-1.0 * halfHeight)) {
		iVictimPos[2] -= halfHeight;
	}
	else {
		iAttackerPos[2] = iVictimPos[2];
	}
	
	return GetVectorDistance(iVictimPos ,iAttackerPos, false);
}

bool IsValidSniper(const char[] sWeaponName)
{
	for (int i = 0; i < sizeof(g_sSniperWeapon); i++) {
		if (strcmp(sWeaponName, g_sSniperWeapon[i]) == 0) {
			return true;
		}
	}

	return false;
}
