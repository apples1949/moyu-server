#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#define PLUGIN_VERSION "1.0.1" 


public Plugin myinfo =
{
    name = "Bot Haymakers",
    author = "ConnerRia",
    description = "Makes AI Tanks pull off haymakers, doing a punch and rock attack simultaneously. ",
    version = PLUGIN_VERSION,
    url = "N/A"
}


public void OnPluginStart()
{
	CreateConVar("BotHaymakers_Version", PLUGIN_VERSION, "BotHaymakers Version", FCVAR_NOTIFY|FCVAR_REPLICATED|FCVAR_DONTRECORD);
}

public Action OnPlayerRunCmd(int client,int &buttons)
{
    if (IsClientInGame(client) && IsPlayerAlive(client) && (GetClientTeam(client) == 3) && IsFakeClient(client) && (GetEntProp(client, Prop_Send, "m_zombieClass") == 8))
    {
		if (buttons & IN_ATTACK)
        {
			switch(GetRandomInt(1, 1))
			{		
				case 1:
				{
					buttons |= IN_ATTACK2;
				}
			}
		}
    }
    
    return Plugin_Continue;
}
