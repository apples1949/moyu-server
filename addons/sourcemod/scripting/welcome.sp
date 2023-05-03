#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>   
#include <colors>
#include <l4d2_playtime_interface>

public Plugin myinfo =    
{   
        name = "Show Your PlayTime",   
        author = "A1R, modified by blueblur",   
        description = "Show the players real play time.",   
        version = "1.0",   
        url = ""  
};

public void OnPluginStart()
{   
        RegConsoleCmd("sm_display", Player_Time);
        LoadTranslations("welcome.phrases");
} 

public void OnClientConnected(int client)   
{       
        char authId[65];
        GetClientAuthId(client, AuthId_Steam2, authId, sizeof(authId));
        int playtime = L4D2_GetTotalPlaytime(authId, true) / 60 / 60;
        if(!IsFakeClient(client))
        {   
                if (playtime > 0)
                {
                        CPrintToChatAll("%t", "ConnectingWithHours", client, playtime);            //{olive} %N {default} [{olive}%i小时{default}]正在连接中...
                       //PrintToConsoleAll("\x04 %N \x01 [\x04%i小时]正在连接中...",client,playtime);
                }
                else
                {
                        CPrintToChatAll("%t", "ConnectingWithoutHours", client);             //{olive} %N {default} 正在连接中...
                        //PrintToConsoleAll("\x04 %N \x01 正在连接中...",client);
                }
        }
}

public void OnClientPutInServer(int client)
{
        char authId[65];
        GetClientAuthId(client, AuthId_Steam2, authId, sizeof(authId));
        int playtime = L4D2_GetTotalPlaytime(authId, true) / 60 / 60;
        if(!IsFakeClient(client))
        {   
                if (playtime > 0)
                {
                        CPrintToChatAll("%t", "ConnectedWithHours", client, playtime);            //{olive} %N {default} [{olive}%i小时{default}]进入了服务器
                        //PrintToConsoleAll("%t", "ConnectedWithoutHours", client, playtime);          //\x04 %N \x01 [\x04%i小时]进入了服务器
                }
                else
                {
                        CPrintToChatAll("%t", "ConnectedWithoutHours",client);             //{olive} %N {default} 进入了服务器
                        //PrintToConsoleAll("\x04 %N \x01 进入了服务器",client);
                }
        }
}

public Action Player_Time(int client, int args)
{
        char id[30];
        for (int i = 1 ; i <= MaxClients ; i++)
        {
	        if (IsClientConnected(i) && IsClientInGame(i))
	        {
                        char authId[65];
                        GetClientAuthId(i, AuthId_Steam2, authId, sizeof(authId));
                        int playtime = L4D2_GetTotalPlaytime(authId, true) / 60 / 60;
                        //int playtime2 = L4D2_GetTotalPlaytime(authId, false) / 60 / 24; //DEBUG
                        //int playtime3 = L4D2_GetTotalPlaytime(authId, 1) / 60 / 24; //DEBUG
	        	GetClientAuthId(i,AuthId_Steam2,id,sizeof(id));
	        	if (!StrEqual(id, "BOT"))
                        {
	        		if(playtime > 0 )
                                {
                                        CPrintToChat(client, "%t", "RequestPlayerTime", i, playtime);            //{olive}%N{default} Has played {red}%i Hours{default}
                                        //CPrintToChatAll("{olive}%N{default} Has Hold {red}%i Hours{default}",i,playtime2);
                                        //CPrintToChatAll("{olive}%N{default} Has Done {red}%i Hours{default}",i,playtime3);
                                }	
	        		else
                                {
	        			CPrintToChat(client, "%t", "RequestPlayerTimeFailed", i);             //{olive}%N{default} Has played {red}Unkown{default} Time
                                }
                        }
	        }
        }
}