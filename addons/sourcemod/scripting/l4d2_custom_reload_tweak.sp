#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <l4d2_weapon_stocks>

new Handle:hCvarReloadSpeedUzi;
new Handle:hCvarReloadSpeedSilencedSmg;
new Handle:hCvarReloadSpeedRifleAK;
new Handle:hCvarReloadSpeedRifleM16;
new Handle:hCvarReloadSpeedRifleSCAR;
new Handle:hCvarReloadSpeedRifleSG;
new Handle:hCvarReloadSpeedRifleM60;
//new Handle:hCvarReloadSpeedDesertEagle;
new Handle:hCvarReloadSpeedSniperScout;
new Handle:hCvarReloadSpeedSniperAWP;
new Handle:hCvarReloadSpeedSniperHR;
new Handle:hCvarReloadSpeedSniperMT;
new Handle:hCvarReloadSpeedMP5;

public Plugin:myinfo =
{
	name = "L4D2 Custom Reload Speed Tweaker",
	description = "Allows cvar'd control over the reload durations for custom guns.",
	author = "Visor,A1R",
	version = "1.1.2",
	url = "https://github.com/Attano/L4D2-Competitive-Framework"
};

public OnPluginStart()
{
	hCvarReloadSpeedUzi = CreateConVar("l4d2_reload_speed_uzi", "2.23", "Reload duration of Uzi(normal SMG)", FCVAR_CHEAT|FCVAR_NOTIFY, true, 0.0, true, 10.0);
	hCvarReloadSpeedSilencedSmg = CreateConVar("l4d2_reload_speed_silenced_smg", "2.23", "Reload duration of Silenced SMG", FCVAR_CHEAT|FCVAR_NOTIFY, true, 0.0, true, 10.0);
	hCvarReloadSpeedRifleAK = CreateConVar("l4d2_reload_speed_rifle_ak", "2.52", "Reload duration of AK", FCVAR_CHEAT|FCVAR_NOTIFY, true, 0.0, true, 10.0);
	hCvarReloadSpeedRifleSG = CreateConVar("l4d2_reload_speed_rifle_sg", "2.35", "Reload duration of SG552", FCVAR_CHEAT|FCVAR_NOTIFY, true, 0.0, true, 10.0);
	//hCvarReloadSpeedDesertEagle = CreateConVar("l4d2_reload_speed_deagle", "0", "Reload duration of DesertEagle", FCVAR_CHEAT|FCVAR_NOTIFY, true, 0.0, true, 10.0);
	hCvarReloadSpeedSniperScout = CreateConVar("l4d2_reload_speed_scout", "3.02", "Reload duration of Souct", FCVAR_CHEAT|FCVAR_NOTIFY, true, 0.0, true, 10.0);
	hCvarReloadSpeedSniperAWP = CreateConVar("l4d2_reload_speed_awp", "3.76", "Reload duration of AWP", FCVAR_CHEAT|FCVAR_NOTIFY, true, 0.0, true, 10.0);
	hCvarReloadSpeedRifleM60 = CreateConVar("l4d2_reload_speed_m60", "2.52", "Reload duration of M60", FCVAR_CHEAT|FCVAR_NOTIFY, true, 0.0, true, 10.0);
	hCvarReloadSpeedSniperHR = CreateConVar("l4d2_reload_speed_hr", "3.25", "Reload duration of HR", FCVAR_CHEAT|FCVAR_NOTIFY, true, 0.0, true, 10.0);
	hCvarReloadSpeedSniperMT = CreateConVar("l4d2_reload_speed_mt", "3.50", "Reload duration of Military Sniper", FCVAR_CHEAT|FCVAR_NOTIFY, true, 0.0, true, 10.0);
	hCvarReloadSpeedRifleSCAR = CreateConVar("l4d2_reload_speed_scar", "3.35", "Reload duration of SCAR", FCVAR_CHEAT|FCVAR_NOTIFY, true, 0.0, true, 10.0);
	hCvarReloadSpeedRifleM16 = CreateConVar("l4d2_reload_speed_m16", "2.35", "Reload duration of M16", FCVAR_CHEAT|FCVAR_NOTIFY, true, 0.0, true, 10.0);
	hCvarReloadSpeedMP5 = CreateConVar("l4d2_reload_speed_mp5", "3.01", "Reload duration of MP5", FCVAR_CHEAT|FCVAR_NOTIFY, true, 0.0, true, 10.0);
	HookEvent("weapon_reload", OnWeaponReload, EventHookMode_Post);
}

public OnWeaponReload(Handle:event, String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if (!IsSurvivor(client) || !IsPlayerAlive(client) || IsFakeClient(client))
		return;

	new Float:originalReloadDuration = 0.0;
	new Float:alteredReloadDuration = 0.0;
	new weapon = GetPlayerWeaponSlot(client, 0);
	new WeaponId:weaponId = IdentifyWeapon(weapon);
	if (weaponId == WEPID_SMG)
	{
		originalReloadDuration = 2.235352;
		alteredReloadDuration = GetConVarFloat(hCvarReloadSpeedUzi);
	}
	else if (weaponId == WEPID_SMG_SILENCED)
	{
		originalReloadDuration = 2.235291;
		alteredReloadDuration = GetConVarFloat(hCvarReloadSpeedSilencedSmg);
	}
	else if (weaponId == WEPID_RIFLE_AK47)
	{
		originalReloadDuration = 2.521746;
		alteredReloadDuration = GetConVarFloat(hCvarReloadSpeedRifleAK);
	}
	else if (weaponId == WEPID_RIFLE_DESERT)
	{
		originalReloadDuration = 3.351672;
		alteredReloadDuration = GetConVarFloat(hCvarReloadSpeedRifleSCAR);
	}
	else if (weaponId == WEPID_RIFLE)
	{
		originalReloadDuration = 2.351712;
		alteredReloadDuration = GetConVarFloat(hCvarReloadSpeedRifleM16);
	}
	else if (weaponId == WEPID_RIFLE_AK47)
	{
		originalReloadDuration = 2.521746;
		alteredReloadDuration = GetConVarFloat(hCvarReloadSpeedRifleAK);
	}
	else if (weaponId == WEPID_RIFLE_M60)
	{
		originalReloadDuration = 2.521746;
		alteredReloadDuration = GetConVarFloat(hCvarReloadSpeedRifleM60);
	}
	else if (weaponId == WEPID_RIFLE_SG552)
	{
		originalReloadDuration = 2.352174;
		alteredReloadDuration = GetConVarFloat(hCvarReloadSpeedRifleSG);
	}
	else if (weaponId == WEPID_SNIPER_SCOUT)
	{
		originalReloadDuration = 3.025147;
		alteredReloadDuration = GetConVarFloat(hCvarReloadSpeedSniperScout);
	}
	else if (weaponId == WEPID_SNIPER_AWP)
	{
		originalReloadDuration = 3.761548;
		alteredReloadDuration = GetConVarFloat(hCvarReloadSpeedSniperAWP);
	}
	else if (weaponId == WEPID_HUNTING_RIFLE)
	{
		originalReloadDuration = 3.251975;
		alteredReloadDuration = GetConVarFloat(hCvarReloadSpeedSniperHR);
	}
	else if (weaponId == WEPID_SNIPER_MILITARY)
	{
		originalReloadDuration = 3.501678;
		alteredReloadDuration = GetConVarFloat(hCvarReloadSpeedSniperMT);
	}
	else if (weaponId == WEPID_SMG_MP5)
	{
		originalReloadDuration = 3.013781;
		alteredReloadDuration = GetConVarFloat(hCvarReloadSpeedMP5);
	}
	else
	{
		return;
	}

	if (alteredReloadDuration <= 0.0)
	{
		return;
	}

	new Float:oldNextAttack = GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", 0);
	new Float:newNextAttack = oldNextAttack - originalReloadDuration + alteredReloadDuration;
	new Float:playbackRate = originalReloadDuration / alteredReloadDuration;
	SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", newNextAttack);
	SetEntPropFloat(client, Prop_Send, "m_flNextAttack", newNextAttack);
	SetEntPropFloat(weapon, Prop_Send, "m_flPlaybackRate", playbackRate);
}

public Action:OnPlayerRunCmd(client, &buttons)
{
	if (!(buttons & IN_ATTACK2))
		return Plugin_Continue;

	if (!IsSurvivor(client) || !IsPlayerAlive(client) || IsFakeClient(client))
		return Plugin_Continue;

	new Float:originalReloadDuration = 0.0;
	new Float:alteredReloadDuration = 0.0;
	new weapon = GetPlayerWeaponSlot(client, 0);
	new WeaponId:weaponId = IdentifyWeapon(weapon);
	if (weaponId == WEPID_SMG)
	{
		originalReloadDuration = 2.235352;
		alteredReloadDuration = GetConVarFloat(hCvarReloadSpeedUzi);
	}
	else if (weaponId == WEPID_SMG_SILENCED)
	{
		originalReloadDuration = 2.235291;
		alteredReloadDuration = GetConVarFloat(hCvarReloadSpeedSilencedSmg);
	}
	else if (weaponId == WEPID_RIFLE_AK47)
	{
		originalReloadDuration = 2.521746;
		alteredReloadDuration = GetConVarFloat(hCvarReloadSpeedRifleAK);
	}
	else if (weaponId == WEPID_RIFLE_DESERT)
	{
		originalReloadDuration = 3.351672;
		alteredReloadDuration = GetConVarFloat(hCvarReloadSpeedRifleSCAR);
	}
	else if (weaponId == WEPID_RIFLE)
	{
		originalReloadDuration = 2.351712;
		alteredReloadDuration = GetConVarFloat(hCvarReloadSpeedRifleM16);
	}
	else if (weaponId == WEPID_RIFLE_M60)
	{
		originalReloadDuration = 2.521746;
		alteredReloadDuration = GetConVarFloat(hCvarReloadSpeedRifleM60);
	}
	else if (weaponId == WEPID_RIFLE_SG552)
	{
		originalReloadDuration = 2.352174;
		alteredReloadDuration = GetConVarFloat(hCvarReloadSpeedRifleSG);
	}
	else if (weaponId == WEPID_SNIPER_SCOUT)
	{
		originalReloadDuration = 3.025147;
		alteredReloadDuration = GetConVarFloat(hCvarReloadSpeedSniperScout);
	}
	else if (weaponId == WEPID_SNIPER_AWP)
	{
		originalReloadDuration = 3.761548;
		alteredReloadDuration = GetConVarFloat(hCvarReloadSpeedSniperAWP);
	}
	else if (weaponId == WEPID_HUNTING_RIFLE)
	{
		originalReloadDuration = 3.251975;
		alteredReloadDuration = GetConVarFloat(hCvarReloadSpeedSniperHR);
	}
	else if (weaponId == WEPID_SNIPER_MILITARY)
	{
		originalReloadDuration = 3.501678;
		alteredReloadDuration = GetConVarFloat(hCvarReloadSpeedSniperMT);
	}
	else if (weaponId == WEPID_SMG_MP5)
	{
		originalReloadDuration = 3.013781;
		alteredReloadDuration = GetConVarFloat(hCvarReloadSpeedMP5);
	}
	else
	{
		return Plugin_Continue;
	}
	new Float:playbackRate = originalReloadDuration / alteredReloadDuration;
	SetEntPropFloat(weapon, Prop_Send, "m_flPlaybackRate", playbackRate);
}

bool:IsSurvivor(client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2;
}