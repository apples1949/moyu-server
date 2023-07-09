#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <colors>
#include <l4d2_skill_detect>

#define DEBUG 0

bool 
	g_bIsTankAlive,
	IsRoundEnd,
	DoorClosed;

char 
	botchat[256];

public Plugin myinfo = 
{
	name = "L4D2 Bot Troll & Tank Sound",
	author = "Blazers Team, modified by blueblur",
	description = "Bot is now taunt?",
	version = "1.1",
	url = ""
};

public void OnMapStart()
{
	PrecacheSound("ui/pickup_secret01.wav");
}

public void OnPluginStart()
{
	HookEvent("survivor_rescued", SurvivorRescued);
	HookEvent("player_incapacitated", PlayerIncap);
	HookEvent("door_close", DoorClose);
	HookEvent("lunge_pounce", HunterCapped);
	HookEvent("player_entered_checkpoint", OnReachSafe);
	HookEvent("door_open", DoorOpen);
	HookEvent("tank_spawn", OnTankSpawn, EventHookMode_PostNoCopy);
	HookEvent("round_start", OnRoundStart, EventHookMode_PostNoCopy);
}

public void OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	IsRoundEnd = false;
	g_bIsTankAlive = false;
	DoorClosed = false;
}

public void OnTankSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if (!g_bIsTankAlive)
	{
		g_bIsTankAlive = true;
		EmitSoundToAll("ui/pickup_secret01.wav");
	}
}

public void OnReachSafe(Event event, const char[] name, bool dontBroadcast)
{
	IsRoundEnd = true;
}

public Action PlayerIncap(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsValidPlayer(client) && GetClientTeam(client) == 2 && !IsFakeClient(client))
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && IsValidPlayer(i))
			{
				if (IsFakeClient(i) && GetClientTeam(i) == 2)
				{
					switch (GetRandomInt(1, 7))
					{
						case 1:
						{
							Format(botchat, sizeof(botchat), "%t", "InCapSlang1", client);		//go delete yo game %N
						}
						case 2:
						{
							Format(botchat, sizeof(botchat), "%t", "InCapSlang2");		//muahahaha look at this noob
						}
						case 3:
						{
							Format(botchat, sizeof(botchat), "%t", "InCapSlang3");		//fucking noob
						}
						case 4:
						{
							Format(botchat, sizeof(botchat), "%t", "InCapSlang4");		//lol retarded
						}
						case 5:
						{
							Format(botchat, sizeof(botchat), "%t", "InCapSlang5", client);		//go play campaign %N
						}
						case 6:
						{
							Format(botchat, sizeof(botchat), "%t", "InCapSlang6", client);		//%N damn fucking noob
						}
						case 7:
						{
							Format(botchat, sizeof(botchat), "%t", "InCapSlang7", client);		//vote kick %N?
						}
					}
					CPrintToChatAll("{blue}%N{default} : %s", i, botchat);
				}
			}
		}
	}
}

public void DoorOpen(Event event, const char[] name, bool dontBroadcast)
{
	bool safedoor = GetEventBool(event, "checkpoint");
	if (safedoor)
	{
		if (!DoorClosed) DoorClosed = false;
	}
}

public Action DoorClose(Event event, const char[] name, bool dontBroadcast)
{
	bool safedoor = GetEventBool(event, "checkpoint");
	if (safedoor && IsRoundEnd && !DoorClosed)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || !IsClientConnected(i) || !IsValidPlayer(i)) return;
			if (IsFakeClient(i) && GetClientTeam(i) == 2)
			{
				switch (GetRandomInt(1, 6))
				{
					case 1:
					{
						Format(botchat, sizeof(botchat), "%t", "InDoorSlang1");		//lol ez win
					}
					case 2:
					{
						Format(botchat, sizeof(botchat), "%t", "InDoorSlang2");		//muahahaha damn noob infected
					}
					case 3:
					{
						Format(botchat, sizeof(botchat), "%t", "InDoorSlang3");		//so ez try harder next time
					}
					case 4:
					{
						Format(botchat, sizeof(botchat), "%t", "InDoorSlang4");		//ez pz
					}
					case 5:
					{
						Format(botchat, sizeof(botchat), "%t", "InDoorSlang5");		//ez game ez life
					}
					case 6:
					{
						Format(botchat, sizeof(botchat), "%t", "InDoorSlang6");		//those noob cant kill me
					}
				}
				CPrintToChatAll("{blue}%N{default} : %s", i, botchat);
			}
		}
		DoorClosed = true;
	}
}

public void OnBoomerPop(int attacker, int victim, int shoveCount, float timeAlive)
{
	if (IsValidPlayer(attacker) && IsValidPlayer(victim) && !IsFakeClient(victim))
	{
		if (IsFakeClient(attacker))
		{
			switch (GetRandomInt(1, 4))
			{
				case 1:
				{
					Format(botchat, sizeof(botchat), "%t", "BoomerPopSlang1");		//useless boomer
				}
				case 2:
				{
					Format(botchat,sizeof(botchat), "%t", "BoomerPopSlang2", victim);		//lol noob boomer %N
				}
				case 3:
				{
					Format(botchat,sizeof(botchat), "%t", "BoomerPopSlang3", victim);		//try harder %N
				}
				case 4:
				{
					Format(botchat,sizeof(botchat), "%t", "BoomerPopSlang4");		//i popped noob boomer muhahaha
				}
			}
			CPrintToChatAll("{blue}%N{default} : %s", attacker, botchat);
		}
	}
}

/*
public void OnBoomerVomitLanded(int boomer, int amount)
{
	if (IsValidPlayer(boomer) && IsClientInGame(boomer))
	{
		if (IsFakeClient(boomer))
		{
			if (amount > 0)
				CPrintToChatAll("{red}Boomer{default} :  Big Target Hard 2 Hit");
		}
	}
}
*/

public void OnTankRockEaten(int attacker, int victim)
{
	if (IsValidPlayer(attacker) && IsValidPlayer(victim) && !IsFakeClient(victim))
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || !IsClientConnected(i) || !IsValidPlayer(i)) return;
			if (IsFakeClient(i) && GetClientTeam(i) == 2)
			{
				switch (GetRandomInt(1, 5))
				{
					case 1:
					{
						Format(botchat, sizeof(botchat), "%t", "EatRockSlang1");		//hide noob
					}
					case 2:
					{
						Format(botchat, sizeof(botchat), "%t", "EatRockSlang2");		//stop eating rocks
					}
					case 3:
					{
						Format(botchat, sizeof(botchat), "%t", "EatRockSlang3", victim);		//u fucking noob %N
					}
					case 4:
					{
						Format(botchat, sizeof(botchat), "%t", "EatRockSlang4");		//damn noob rockeater
					}
					case 5:
					{
						Format(botchat, sizeof(botchat), "%t", "EatRockSlang5");		//hey dont eat rocks ok?
					}
				}
				CPrintToChatAll("{blue}%N{default} : %s", i, botchat);
			}
		}
	}
}

public Action HunterCapped(Event event, const char[] name, bool dontBroadcast)
{
	int hunter = GetClientOfUserId(GetEventInt(event, "userid"));
	int victim = GetClientOfUserId(GetEventInt(event, "victim"));
	
	if (IsValidPlayer(hunter) && IsValidPlayer(victim) && !IsFakeClient(victim))
	{
		if (IsFakeClient(hunter))
		{
			switch (GetRandomInt(1, 6))
			{
				case 1:
				{
					Format(botchat, sizeof(botchat), "%t", "HunterCapped1");		//why u failed to skeet it?
				}
				case 2:
				{
					Format(botchat, sizeof(botchat), "%t", "HunterCapped2");
				}
				case 3:
				{
					Format(botchat, sizeof(botchat), "%t", "HunterCapped3");
				}
				case 4:
				{
					Format(botchat, sizeof(botchat), "%t", "HunterCapped4");
				}
				case 5:
				{
					Format(botchat, sizeof(botchat), "%t", "HunterCapped5");
				}
				case 6:
				{
					Format(botchat, sizeof(botchat), "%t", "HunterCapped6");
				}
			}
			CPrintToChatAll("{red}Hunter{default} : %s", botchat);
		}
	}	
}

public Action SurvivorRescued(Event event, const char[] name, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && IsValidPlayer(i))
		{
			if (IsFakeClient(i) && GetClientTeam(i) == 2)
			{
				switch (GetRandomInt(1, 6))
				{
					case 1:
					{
						Format(botchat, sizeof(botchat), "%t", "SurvivorRescuedSlang1");		//lol ez win
					}
					case 2:
					{
						Format(botchat, sizeof(botchat), "%t", "SurvivorRescuedSlang2");		//muahahaha damn noob infected
					}
					case 3:
					{
						Format(botchat, sizeof(botchat), "%t", "SurvivorRescuedSlang3");		//so ez try harder next time
					}
					case 4:
					{
						Format(botchat, sizeof(botchat), "%t", "SurvivorRescuedSlang4");		//ez pz
					}
					case 5:
					{
						Format(botchat, sizeof(botchat), "%t", "SurvivorRescuedSlang5");		//ez game ez life
					}
					case 6:
					{
						Format(botchat, sizeof(botchat), "%t", "SurvivorRescuedSlang6");		//those noob cant kill me
					}
				}
				CPrintToChatAll("{blue}%N{default} : %s", i, botchat);
			}
		}
	}
}
static bool IsValidPlayer(int client)
{
	if (0 < client <= MaxClients)
		return true;
	return false;
}