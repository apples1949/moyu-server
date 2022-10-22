
#include <sourcemod>   
#include <colors>
#include <l4d2_playtime_interface>

public Plugin:myinfo =    
{   
        name = "Show Your PlayTime",   
        author = "A1R",   
        description = "Show the players real play time.",   
        version = "1.0",   
        url = ""  
}   
   
public OnPluginStart()   
{   
        RegConsoleCmd("sm_display", Player_Time);
} 
 
public OnClientConnected(client)   
{       
        char authId[65];
        GetClientAuthId(client, AuthId_Steam2, authId, sizeof(authId));
        int playtime = L4D2_GetTotalPlaytime(authId, true) / 60 / 60;
        if(!IsFakeClient(client))
        {   
                if (playtime > 0)
                {
                        CPrintToChatAll("{olive} %N {default} [{olive}%i小时{default}]正在连接中...",client,playtime);
                        PrintToConsoleAll("\x04 %N \x01 [\x04%i小时]正在连接中...",client,playtime);
                }
                else
                {
                        CPrintToChatAll("{olive} %N {default} 正在连接中...",client);
                        PrintToConsoleAll("\x04 %N \x01 正在连接中...",client);
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
                        CPrintToChatAll("{olive} %N {default} [{olive}%i小时{default}]进入了服务器",client,playtime);
                        PrintToConsoleAll("\x04 %N \x01 [\x04%i小时]进入了服务器",client,playtime);
                }
                else
                {
                        //CPrintToChatAll("{olive} %N {default} 进入了服务器",client);
                        //PrintToConsoleAll("\x04 %N \x01 进入了服务器",client);
                }
        }
}

public Action Player_Time(int client, int args)
{
        char id[30];
        for (new i = 1 ; i <= MaxClients ; i++)
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
	        		if(playtime > 0 )
                                {
                                        CPrintToChat(client, "{olive}%N{default} Has played {red}%i Hours{default}",i,playtime);
                                        //CPrintToChatAll("{olive}%N{default} Has Hold {red}%i Hours{default}",i,playtime2);
                                        //CPrintToChatAll("{olive}%N{default} Has Done {red}%i Hours{default}",i,playtime3);
                                }	
	        		else 
	        			CPrintToChat(client, "{olive}%N{default} Has played {red}Unkown{default} Time",i); 
	        }
        }
}