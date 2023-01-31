#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <l4d2util_constants>
#undef REQUIRE_PLUGIN
#include <readyup>

#define DEBUG					0
#define USE_GIVEPLAYERITEM		0 // Works correctly only in the latest version of sourcemod 1.11 (GivePlayerItem sourcemod native)
#define ENTITY_NAME_MAX_SIZE	64

ConVar
	g_hCvarItemType = null;

bool
	g_bReadyUpAvailable = false;

public Plugin myinfo =
{
	name = "Starting Items",
	author = "J.Q",
	description = "Gives items to survivors at the start of each round",
	version = "0.1",
	url = "https://github.com/SirPlease/L4D2-Competitive-Rework"
};

public void OnPluginStart()
{
	g_hCvarItemType = CreateConVar("starting_upgradepack_flags", \
		"0", \
		"Item flags to give on leaving the saferoom (0: Disable, 1: enable)", \
		_, false, 0.0, true, 127.0 \
	);

	HookEvent("player_left_start_area", PlayerLeftStartArea, EventHookMode_PostNoCopy);

#if DEBUG
	RegAdminCmd("sm_give_starting_items", Cmd_GiveStartingItems, ADMFLAG_KICK);
#endif
}

public void OnAllPluginsLoaded()
{
	g_bReadyUpAvailable = LibraryExists("readyup");
}

public void OnLibraryRemoved(const char[] sPluginName)
{
	if (strcmp(sPluginName, "readyup") == 0) {
		g_bReadyUpAvailable = false;
	}
}

public void OnLibraryAdded(const char[] sPluginName)
{
	if (strcmp(sPluginName, "readyup") == 0) {
		g_bReadyUpAvailable = true;
	}
}

public void OnRoundIsLive()
{
	DetermineItems();
}

public void PlayerLeftStartArea(Event hEvent, const char[] sEventName, bool bDontBroadcast)
{
	if (!g_bReadyUpAvailable) {
		DetermineItems();
	}
}

void DetermineItems()
{
	int iItemFlags = g_hCvarItemType.IntValue;

	if (iItemFlags < 1) {
		return;
	}

	StringMap hItemsStringMap = new StringMap();

	hItemsStringMap.SetValue("weapon_upgradepack_incendiary", L4D2WeaponSlot_HeavyHealthItem);

	GiveStartingItems(hItemsStringMap);

	delete hItemsStringMap;
	hItemsStringMap = null;
}

void GiveStartingItems(StringMap &hItemsStringMap)
{
	if (hItemsStringMap.Size < 1) {
		return;
	}

	char sEntName[ENTITY_NAME_MAX_SIZE];
	StringMapSnapshot hItemsSnapshot = hItemsStringMap.Snapshot();
	int iSlotIndex, iSize = hItemsSnapshot.Length;

	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && GetClientTeam(i) == L4D2Team_Survivor && IsPlayerAlive(i)) {
			for (int j = 0; j < iSize; j++) {
				hItemsSnapshot.GetKey(j, sEntName, sizeof(sEntName));
				hItemsStringMap.GetValue(sEntName, iSlotIndex);

				if (GetPlayerWeaponSlot(i, iSlotIndex) == -1) {
					GivePlayerWeaponByName(i, sEntName);
				}
			}
		}
	}

	delete hItemsSnapshot;
	hItemsSnapshot = null;
}

void GivePlayerWeaponByName(int iClient, const char[] sWeaponName)
{
#if (SOURCEMOD_V_MINOR == 11) || USE_GIVEPLAYERITEM
	GivePlayerItem(iClient, sWeaponName); // Fixed only in the latest version of sourcemod 1.11
#else
	int iEntity = CreateEntityByName(sWeaponName);
	if (iEntity == -1) {
		return;
	}

	/*float fClientOrigin[3];
	GetClientAbsOrigin(client, fClientOrigin);
	TeleportEntity(iEntity, fClientOrigin, NULL_VECTOR, NULL_VECTOR);*/
	DispatchSpawn(iEntity);
	EquipPlayerWeapon(iClient, iEntity);
#endif
}

#if DEBUG
public Action Cmd_GiveStartingItems(int iClient, int iArgs)
{
	DetermineItems();
	PrintToChat(iClient, "DetermineItems()");

	return Plugin_Handled;
}
#endif
