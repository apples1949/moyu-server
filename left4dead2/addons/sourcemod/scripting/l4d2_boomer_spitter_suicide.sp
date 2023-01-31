#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdkhooks>
#include <left4dhooks>
#define L4D2UTIL_STOCKS_ONLY 1
#include <l4d2util>
//#include <sdktools>

Handle cvar_KsBoomer;
Handle cvar_KsSpitter;

public const char g_sValidBoomerSpitterClaw[][ENTITY_MAX_NAME_LENGTH] =
{
	"weapon_boomer_claw",
	"weapon_spitter_claw"
};

bool g_bLateLoad = false;

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] sError, int iErrMax)
{
	g_bLateLoad = bLate;

	return APLRes_Success;
}

public Plugin myinfo =
{
	name = "L4D2 Boomer Spitter Suicide",
	author = "J.Q",
	description = "boomer and spitter suicide",
	version = "1.1.2",
	url = ""
};

public void OnPluginStart()
{
	cvar_KsBoomer = CreateConVar("l4d2_killself_boomer", "1", "Manages boomer suicide", FCVAR_NOTIFY);
	cvar_KsSpitter = CreateConVar("l4d2_killself_spitter", "1", "Manages spitter suicide", FCVAR_NOTIFY);

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
	//iClient <= MaxClients
	if (!IsValidInfected(iAttacker) || !IsValidSurvivor(iVictim) || IsFakeClient(iAttacker)){
		return Plugin_Continue;
	}
		
	if (GetConVarBool(cvar_KsBoomer) && GetEntProp(iAttacker, Prop_Send, "m_zombieClass") == L4D2Infected_Boomer)
	{
		int iWeapon = GetEntPropEnt(iAttacker, Prop_Send, "m_hActiveWeapon");
		if (iWeapon == -1) {
			return Plugin_Continue;
		}
		
		char sClassName[64];
		GetEdictClassname(iWeapon, sClassName, sizeof(sClassName));	
	
		if (IsValidBoomerSpitterClaw(sClassName))
		{
			IgniteEntity(iAttacker, 1.00);
			SetEntityHealth(iAttacker, 0);
		}
	}
	
	if (GetConVarBool(cvar_KsSpitter) && GetEntProp(iAttacker, Prop_Send, "m_zombieClass") == L4D2Infected_Spitter)
	{
		int iWeapon = GetEntPropEnt(iAttacker, Prop_Send, "m_hActiveWeapon");
		if (iWeapon == -1) {
			return Plugin_Continue;
		}
		
		char sClassName[64];
		GetEdictClassname(iWeapon, sClassName, sizeof(sClassName));	
	
		if (IsValidBoomerSpitterClaw(sClassName))
		{
			IgniteEntity(iAttacker, 1.00);
			SetEntityHealth(iAttacker, 0);
		}
	}
	
	return Plugin_Continue;
}

bool IsValidBoomerSpitterClaw(const char[] sWeaponName)
{
	for (int i = 0; i < sizeof(g_sValidBoomerSpitterClaw); i++) {
		if (strcmp(sWeaponName, g_sValidBoomerSpitterClaw[i]) == 0) {
			return true;
		}
	}

	return false;
}
