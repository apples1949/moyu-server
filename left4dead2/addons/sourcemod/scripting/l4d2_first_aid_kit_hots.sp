#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <left4dhooks>

#define PLUGIN_VERSION "2.3.1"

public Plugin myinfo = 
{
    name = "L4D2 FIRST AID KIT HOTs",
    author = "J.Q",
    description = "first aid kit heal over time",
    version = PLUGIN_VERSION,
    url = "https://github.com/SirPlease/L4D2-Competitive-Rework"
}

ArrayList
	g_aHOTPair;

ConVar
	hCvarFirstaidHot,
	hCvarFirstaidInterval,
	hCvarFirstaidIncrement,
	hCvarFirstaidTotal,
	first_aid_health_value;

public void OnPluginStart()
{
    g_aHOTPair = new ArrayList(2);

    char buffer[16];
	
    first_aid_health_value = FindConVar("first_aid_heal_percent");
    first_aid_health_value.GetString(buffer, sizeof(buffer));
	
    hCvarFirstaidHot = CreateConVar("l4d_firstaid_hot", "0", "firstaid heal over time", FCVAR_NONE);
    hCvarFirstaidInterval = CreateConVar("l4d_firstaid_hot_interval", "1.0", "Interval for firstaid hot", FCVAR_NONE);
    hCvarFirstaidIncrement = CreateConVar("l4d_firstaid_hot_increment", "10", "Increment amount for firstaid hot", FCVAR_NONE);
    hCvarFirstaidTotal = CreateConVar("l4d_firstaid_hot_total", "100", "Total amount for firstaid hot", FCVAR_NONE);
    if(GetConVarBool(hCvarFirstaidHot)){
        EnableFirstaidHot();
    }
    HookConVarChange(hCvarFirstaidHot, FirstaidHotChanged);
    hCvarFirstaidHot.AddChangeHook(FirstaidHotChanged);
}

public void OnPluginEnd()
{
	if (hCvarFirstaidHot.BoolValue) DisableFirstaidHot();
}

public void OnMapStart()
{
	g_aHOTPair.Clear();
}

public void Player_BotReplace_Event(Event event, const char[] name, bool dontBroadcast)
{
	HandleSurvivorTakeover(event.GetInt("player"), event.GetInt("bot"));
}

public void Bot_PlayerReplace_Event(Event event, const char[] name, bool dontBroadcast)
{
	HandleSurvivorTakeover(event.GetInt("bot"), event.GetInt("player"));
}

void HandleSurvivorTakeover(int replacee, int replacer)
{
	// There can be multiple HOTs happening at the same time
	// so cannot just use FindValue here.
	int size = g_aHOTPair.Length;
	for (int i = 0; i < size; ++i)
	{
		if (replacee == g_aHOTPair.Get(i, 0))
		{
			g_aHOTPair.Set(i, replacer, 0);

			DataPack dp = g_aHOTPair.Get(i, 1);
			dp.Reset();
			dp.WriteCell(replacer);
		}
	}
}

public void FirstaidUsed_Event(Event event, const char[] name, bool dontBroadcast)
{
	if (event.GetInt("subject") == event.GetInt("userid")) {
		HealEntityOverTime(
			event.GetInt("userid"),
			hCvarFirstaidInterval.FloatValue,
			hCvarFirstaidIncrement.IntValue,
			hCvarFirstaidTotal.IntValue
		);
	}
	if (event.GetInt("subject") != event.GetInt("userid")) {
		HealEntityOverTime(
			event.GetInt("subject"),
			hCvarFirstaidInterval.FloatValue,
			hCvarFirstaidIncrement.IntValue,
			hCvarFirstaidTotal.IntValue
		);
	}
}

void HealEntityOverTime(int userid, float interval, int increment, int total)
{
	int client = GetClientOfUserId(userid);
	if (!client || !IsClientInGame(client) || !IsPlayerAlive(client))
		return;

	int iMaxHP = GetEntProp(client, Prop_Send, "m_iMaxHealth", 2);

	if (increment >= total)
	{
		__HealTowardsMax(client, total, iMaxHP);
	}
	else
	{
		__HealTowardsMax(client, increment, iMaxHP);
		DataPack myDP;
		CreateDataTimer(interval, __HOT_ACTION, myDP,
			TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		myDP.WriteCell(userid);
		myDP.WriteCell(increment);
		myDP.WriteCell(total-increment);
		myDP.WriteCell(iMaxHP);
		
		g_aHOTPair.Set(g_aHOTPair.Push(userid), myDP, 1);
	}
}

public Action __HOT_ACTION(Handle timer, DataPack pack)
{
	pack.Reset();

	int userid = pack.ReadCell();
	int client = GetClientOfUserId(userid);

	if (client && IsPlayerAlive(client) && !L4D_IsPlayerIncapacitated(client) && !L4D_IsPlayerHangingFromLedge(client))
	{
		int increment = pack.ReadCell();
		DataPackPos pos = pack.Position;
		int remaining = pack.ReadCell();
		int maxhp = pack.ReadCell();

		//PrintToChatAll("HOT: %N %d %d %d", client, increment, remaining, maxhp);

		if (increment < remaining)
		{
			__HealTowardsMax(client, increment, maxhp);
			pack.Position = pos;
			pack.WriteCell(remaining-increment);

			return Plugin_Continue;
		}
		else
		{
			__HealTowardsMax(client, remaining, maxhp);
		}
	}

	g_aHOTPair.Erase(g_aHOTPair.FindValue(pack, 1));
	return Plugin_Stop;
}

void __HealTowardsMax(int client, int amount, int max)
{
	float hb = L4D_GetTempHealth(client) + amount;
	float overflow = hb + GetClientHealth(client) - max;
	if (overflow > 0)
	{
		hb -= overflow;
	}
	L4D_SetTempHealth(client, hb);
}

public void FirstaidHotChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	bool newval = StringToInt(newValue)!=0;
	if (newval && StringToInt(oldValue) ==0)
	{
        EnableFirstaidHot();
	}
	else if (!newval && StringToInt(oldValue) != 0)
	{
		DisableFirstaidHot();
	}
}

void EnableFirstaidHot()
{
	first_aid_health_value.Flags &= ~FCVAR_REPLICATED;
	first_aid_health_value.IntValue = 0;

	SwitchGeneralEventHooks(true);
	SwitchFirstaidHotEventHook(true);
}

void DisableFirstaidHot()
{
	first_aid_health_value.Flags &= FCVAR_REPLICATED;
	first_aid_health_value.RestoreDefault();

	SwitchGeneralEventHooks(hCvarFirstaidHot.BoolValue);
	SwitchFirstaidHotEventHook(true);
}

void SwitchFirstaidHotEventHook(bool hook)
{
	static bool hooked = false;

	if (hook && !hooked)
	{
		HookEvent("heal_success", FirstaidUsed_Event);
		hooked = true;
	}
	else if (!hook && hooked)
	{
		UnhookEvent("heal_success", FirstaidUsed_Event);
		hooked = false;
	}
}

void SwitchGeneralEventHooks(bool hook)
{
	static bool hooked = false;

	if (hook && !hooked)
	{
		HookEvent("player_bot_replace", Player_BotReplace_Event);
		HookEvent("bot_player_replace", Bot_PlayerReplace_Event);

		hooked = true;
	}

	else if (!hook && hooked)
	{
		UnhookEvent("player_bot_replace", Player_BotReplace_Event);
		UnhookEvent("bot_player_replace", Bot_PlayerReplace_Event);

		hooked = false;
	}
}
