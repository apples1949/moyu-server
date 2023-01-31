#include <sourcemod>
#include <sdktools>
#include <colors>
#include <l4d2util_survivors>

//hunter position store
new Float:infectedPosition[32][3];
//support up to 32 slots on a server

public Plugin:myinfo = 
{
	name = "L4D2pounceCPRWTF",
	author = "J.Q",
	description = "Uncap and modify hunter pounce damage in L4D2 and L4D [now with pounce stats]",
	version = "0.1.2",
	url = ""
}


public void OnPluginStart()
{
	//If the plugin is loaded in a game other than L4D or L4D2 then stop here.
	decl String:gameMod[32];
	GetGameFolderName(gameMod, sizeof(gameMod));
	if(!StrEqual(gameMod, "left4dead2", false))
	{
		SetFailState("Plugin supports L4D & L4D2 only.");
	}
	
	HookEvent("lunge_pounce",Event_PlayerPounced);
	HookEvent("ability_use",Event_AbilityUse);
}

public Event_AbilityUse(Handle:event, const String:name[], bool:dontBroadcast)
{
	//ability_use returns ability = ability_lunge(hunter), ability_toungue(smoker), ability_vomit(boomer)
	//ability_charge(charger and ability_spit(spitter) (weirdly nothing for jockey though ;/)
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	//Save the location of the player who just pounced as hunter
	GetClientAbsOrigin(client,infectedPosition[client]);	
}

public Event_PlayerPounced(Handle:event, String:name[], bool:dontBroadcast)
{
	//If the plugin is loaded in a game other than L4D or L4D2 then stop here.
	decl String:gameMod[32];
	GetGameFolderName(gameMod, sizeof(gameMod));
	if(!StrEqual(gameMod, "left4dead2", false))
	{
		return false;
	}
	
	new Float:pouncePosition[3];
	new attackerId = GetEventInt(event, "userid");
	new victimId = GetEventInt(event, "victim");
	new attackerClient = GetClientOfUserId(attackerId);
	new victimClient = GetClientOfUserId(victimId);
	
	GetClientAbsOrigin(attackerClient, pouncePosition);
	
	//Calculate 2d distance between previous position and pounce position
	new distance = RoundToNearest(GetVectorDistance(infectedPosition[attackerClient], pouncePosition));
	
	//GetConVarInt(GetSurvivorIncapCount(victimClient))
	if (distance > 500 || distance == 500)
	{
		if(IsPlayerAlive(victimClient)){
			if(IsIncapacitated(victimClient)) {
				switch(GetSurvivorIncapCount(victimClient)){
					case 0: {
						KillPlayer(attackerClient);
						CPrintToChatAll("{olive}%N{default}牺牲自己对{olive}%N{default}造成距离超过{olive}500{default}的高强度心肺复苏术{default}. （2d矢量距离: {olive}%i{default}） ", attackerClient, victimClient, distance);
						CreateTimer(0.5, Frame_HealPlayer, victimClient); 
					}
					case 1: {
						KillPlayer(attackerClient);
						CPrintToChatAll("{olive}%N{default}牺牲自己对{olive}%N{default}造成距离超过{olive}500{default}的高强度心肺复苏术{default}. （2d矢量距离: {olive}%i{default}） ", attackerClient, victimClient, distance);
						CreateTimer(0.5, Frame_HealPlayer, victimClient); 
					}
				}
			}
			else{
				switch(GetSurvivorIncapCount(victimClient)){
					case 0: {
						CPrintToChatAll("{olive}%N{default}对{olive}%N{default}造成距离超过{olive}500{default}的高强度心肺复苏术{default}. （2d矢量距离: {olive}%i{default}） ", attackerClient, victimClient, distance);
						CreateTimer(0.5, Frame_HealPlayer, victimClient); 
					}
					case 1: {
						CPrintToChatAll("{olive}%N{default}对{olive}%N{default}造成距离超过{olive}500{default}的高强度心肺复苏术{default}. （2d矢量距离: {olive}%i{default}） ", attackerClient, victimClient, distance);
						CreateTimer(0.5, Frame_HealPlayer, victimClient); 
					}
					case 2: {
						CPrintToChatAll("黑白状态的{olive}%N{default}被高扑但太虚弱没有回复{default}.", victimClient);
					}
				}
			}
		}
		else{
			KillPlayer(attackerClient);
			CPrintToChatAll("黑白状态的{olive}%N{default}被高扑承受不住寄了{default}.", victimClient);
		}
	}
	if (distance < 650)
	{
		SetEntityHealth(attackerClient, 250);
	}
		
	return true;
}

public Action:Frame_HealPlayer(Handle timer, int client)
{
	int flags = GetCommandFlags("give");
	SetCommandFlags("give", flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "give health");
	SetCommandFlags("give", flags|FCVAR_CHEAT);
}

stock KillPlayer(int client)
{
	int flags = GetCommandFlags("kill");
	SetCommandFlags("kill", flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "kill ");
	SetCommandFlags("kill", flags|FCVAR_CHEAT);
}