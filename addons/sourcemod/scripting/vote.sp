#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>
#include <builtinvotes>

#define FILE_PATH		"configs/cfgs.txt"

Handle g_hVote = INVALID_HANDLE;
Handle g_hVoteKick = INVALID_HANDLE;
Handle g_hVoteban = INVALID_HANDLE;
Handle g_hCfgsKV = INVALID_HANDLE;
char g_sCfg[32];
char kickplayerinfo[MAX_NAME_LENGTH];
char kickplayername[MAX_NAME_LENGTH];
char banplayerinfo[MAX_NAME_LENGTH];
char banplayername[MAX_NAME_LENGTH];


public Plugin myinfo = 
{
	name = "投票读取cfg文件",
	author = "HazukiYuro",
	description = "!vote投票",
	version = "1.1",
	url = ""
}

public void OnPluginStart()
{
	char sBuffer[128];
	GetGameFolderName(sBuffer, sizeof(sBuffer));
	if (!StrEqual(sBuffer, "left4dead2", false))
	{
		SetFailState("该插件只支持 求生之路2!");
	}
	g_hCfgsKV = CreateKeyValues("Cfgs");
	BuildPath(Path_SM, sBuffer, sizeof(sBuffer), FILE_PATH);
	if (!FileToKeyValues(g_hCfgsKV, sBuffer))
	{
		SetFailState("无法加载cfgs.txt文件!");
	}


	RegConsoleCmd("sm_v", CommondVote);
	RegConsoleCmd("sm_vote", CommondVote);
	RegConsoleCmd("sm_votes", CommondVote);
	RegConsoleCmd("sm_votemenu", CommondVote);

	RegConsoleCmd("sm_votekick", Command_Voteskick);
	RegConsoleCmd("sm_voteban", Command_Votesban);
	RegConsoleCmd("sm_serverhp", Command_ServerHp, _, ADMFLAG_KICK);
	
	RegAdminCmd("sm_cv", Command_VoteCancel, ADMFLAG_GENERIC);
	RegAdminCmd("sm_cancelvote", Command_VoteCancel, ADMFLAG_GENERIC);
}

stock void CheatCommand(int Client, char[] command, char[] arguments)
{
	int admindata = GetUserFlagBits(Client);
	SetUserFlagBits(Client, ADMFLAG_ROOT);
	int flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	FakeClientCommand(Client, "%s %s", command, arguments);
	SetCommandFlags(command, flags);
	SetUserFlagBits(Client, admindata);
}

public Action Command_VoteCancel(int client, int args)
{
	if (IsBuiltinVoteInProgress())
	{
		CancelBuiltinVote();
		PrintToChatAll("\x03管理员取消了当前投票!");
		return Plugin_Handled;
	}
	ReplyToCommand(client, "没有投票在进行!");
	return Plugin_Handled;
}

public Action Command_ServerHp(int client, int args)
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientConnected(i) && IsClientInGame(i))
		{
			CheatCommand(i, "give", "health");
		}
	}
	PrintToChatAll("\x03投票回血通过");
	ReplyToCommand(client, "done");
	return Plugin_Handled;
}

public Action CommondVote(int client, int args)
{
	if (!client) return Plugin_Handled;
	if (args > 0)
	{
		char sCfg[64], sBuffer[256];
		GetCmdArg(1, sCfg, sizeof(sCfg));
		BuildPath(Path_SM, sBuffer, sizeof(sBuffer), "../../cfg/%s", sCfg);
		if (DirExists(sBuffer))
		{
			FindConfigName(sCfg, sBuffer, sizeof(sBuffer));
			if (StartVote(client, sBuffer))
			{
				strcopy(g_sCfg, sizeof(g_sCfg), sCfg);
				FakeClientCommand(client, "Vote Yes");
			}
			return Plugin_Handled;
		}
	}
	
	ShowVoteMenu(client);
	
	return Plugin_Handled;
}


bool FindConfigName(const char[] cfg, char[] message, int maxlength)
{
	KvRewind(g_hCfgsKV);
	if (KvGotoFirstSubKey(g_hCfgsKV))
	{
		do
		{
			if (KvJumpToKey(g_hCfgsKV, cfg))
			{
				KvGetString(g_hCfgsKV, "message", message, maxlength);
				return true;
			}
		} while (KvGotoNextKey(g_hCfgsKV));
	}
	return false;
}

void ShowVoteMenu(int client)
{
	Menu hMenu = CreateMenu(VoteMenuHandler);
	SetMenuTitle(hMenu, "选择:");
	char sBuffer[64];
	KvRewind(g_hCfgsKV);
	if (KvGotoFirstSubKey(g_hCfgsKV))
	{
		do
		{
			KvGetSectionName(g_hCfgsKV, sBuffer, sizeof(sBuffer));
			AddMenuItem(hMenu, sBuffer, sBuffer);
		} while (KvGotoNextKey(g_hCfgsKV));
	}
	DisplayMenu(hMenu, client, 20);
}

public void VoteMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char sInfo[64], sBuffer[64];
		GetMenuItem(menu, param2, sInfo, sizeof(sInfo));
		KvRewind(g_hCfgsKV);
		if (KvJumpToKey(g_hCfgsKV, sInfo) && KvGotoFirstSubKey(g_hCfgsKV))
		{
			Handle hMenu = CreateMenu(ConfigsMenuHandler);
			Format(sBuffer, sizeof(sBuffer), "选择 %s :", sInfo);
			SetMenuTitle(hMenu, sBuffer);
			do
			{
				KvGetSectionName(g_hCfgsKV, sInfo, sizeof(sInfo));
				KvGetString(g_hCfgsKV, "message", sBuffer, sizeof(sBuffer));
				AddMenuItem(hMenu, sInfo, sBuffer);
			} while (KvGotoNextKey(g_hCfgsKV));
			DisplayMenu(hMenu, param1, 20);
		}
		else
		{
			PrintToChat(param1, "没有相关的文件存在.");
			ShowVoteMenu(param1);
		}
	}
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public void ConfigsMenuHandler(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char sInfo[64], sBuffer[64];
		GetMenuItem(menu, param2, sInfo, sizeof(sInfo), _, sBuffer, sizeof(sBuffer));
		strcopy(g_sCfg, sizeof(g_sCfg), sInfo);
		
		if(!StrEqual(g_sCfg, "sm_votekick"))
		{
			if (StartVote(param1, sBuffer))
			{
				FakeClientCommand(param1, "Vote Yes");
			}
			else
			{
				ShowVoteMenu(param1);
			}
		}
		else if(StrEqual(g_sCfg, "sm_voteban"))
		{
			FakeClientCommand(param1, "sm_voteban");
		}
		else
		{
			FakeClientCommand(param1, "sm_votekick");
		}
	}
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	if (action == MenuAction_Cancel)
	{
		ShowVoteMenu(param1);
	}
}

bool StartVote(int client, const char[] cfgname)
{
	if (!IsBuiltinVoteInProgress())
	{
		int iNumPlayers;
		char[] iPlayers = new char[MaxClients];
		
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || IsFakeClient(i))
			{
				continue;
			}
			iPlayers[iNumPlayers++] = i;
		}
		char sBuffer[64];
		g_hVote = CreateBuiltinVote(VoteActionHandler, BuiltinVoteType_Custom_YesNo, BuiltinVoteAction_Cancel | BuiltinVoteAction_VoteEnd | BuiltinVoteAction_End);
		Format(sBuffer, sizeof(sBuffer), "执行 '%s' ?", cfgname);
		SetBuiltinVoteArgument(g_hVote, sBuffer);
		SetBuiltinVoteInitiator(g_hVote, client);
		SetBuiltinVoteResultCallback(g_hVote, VoteResultHandler);
		DisplayBuiltinVoteToAll(g_hVote, 20);
		PrintToChatAll("\x04%N \x03发起了一个投票", client);
		return true;
	}
	PrintToChat(client, "已经有一个投票正在进行.");
	return false;
}

public void VoteActionHandler(Handle vote, BuiltinVoteAction action, int param1, int param2)
{
	switch (action)
	{
		case BuiltinVoteAction_End:
		{
			g_hVote = INVALID_HANDLE;
			CloseHandle(vote);
		}
		case BuiltinVoteAction_Cancel:
		{
			DisplayBuiltinVoteFail(vote, BuiltinVoteFailReason:param1);
		}
	}
}

public void VoteResultHandler(Handle vote, int num_votes, int num_clients, const int[][] client_info, int num_items, const int[][] item_info)  // 新修改
// public VoteResultHandler(Handle:vote, num_votes, num_clients, const client_info[][2], num_items, const item_info[][2])   // 原版
{
	for (int i = 0; i < num_items; i++)
	{
		if (item_info[i][BUILTINVOTEINFO_ITEM_INDEX] == BUILTINVOTES_VOTE_YES)
		{
			if (item_info[i][BUILTINVOTEINFO_ITEM_VOTES] >= (num_clients * 0.6))
			{
				if (vote == g_hVote)
				{
					DisplayBuiltinVotePass(vote, "cfg文件正在加载...");
					ServerCommand("%s", g_sCfg);
					return;
				}
				else if(vote == g_hVoteKick)
				{
					{
						ServerCommand("sm_kick %s 投票踢出", kickplayername);
						return;
	    			}
				}
				else if(vote == g_hVoteban)
				{
					{
						ServerCommand("sm_ban 15 %s 投票封禁15分钟", banplayername);
						return;
	    			}
				}
			}
		}
	}
	DisplayBuiltinVoteFail(vote, BuiltinVoteFail_Loses);
}

public Action Command_Voteskick(int client, int args)
{
	if(client != 0 && client <= MaxClients) 
	{
		CreateVotekickMenu(client);
		return Plugin_Handled;
	}
	return Plugin_Handled;
}

public Action Command_Votesban(int client, int args)
{
	if(client != 0 && client <= MaxClients) 
	{
		CreateVotebanMenu(client);
		return Plugin_Handled;
	}
	return Plugin_Handled;
}

void CreateVotekickMenu(int client)
{	
	Handle menu = CreateMenu(Menu_Voteskick);		
	char name[MAX_NAME_LENGTH];
	char info[MAX_NAME_LENGTH + 6];
	char playerid[32];
	SetMenuTitle(menu, "选择踢出玩家");
	for(int i = 1;i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i))
		{
			Format(playerid,sizeof(playerid),"%i",GetClientUserId(i));
			char steamid[128];
	
			// GetClientAuthString(target, steamid, sizeof(steamid)); /* 原版 */
			GetClientAuthId(i, AuthId_Steam2, steamid, sizeof(steamid)); /* 翻新 */
			if(GetClientName(i,name,sizeof(name)) && FindAdminByIdentity(AUTHMETHOD_STEAM, steamid) != INVALID_ADMIN_ID)
			{
				Format(info, sizeof(info), "%s",  name);
				AddMenuItem(menu, playerid, info);
			}
		}		
	}
	DisplayMenu(menu, client, 30);
}
void CreateVotebanMenu(int client)
{	
	Handle menu = CreateMenu(Menu_Votesban);		
	char name[MAX_NAME_LENGTH];
	char info[MAX_NAME_LENGTH + 6];
	char playerid[32];
	SetMenuTitle(menu, "选择封禁玩家");
	for(int i = 1;i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i))
		{
			Format(playerid,sizeof(playerid),"%i",GetClientUserId(i));
			char steamid[128];
	
			// GetClientAuthString(target, steamid, sizeof(steamid)); /* 原版 */
			GetClientAuthId(i, AuthId_Steam2, steamid, sizeof(steamid)); /* 翻新 */
			if(GetClientName(i,name,sizeof(name)) && FindAdminByIdentity(AUTHMETHOD_STEAM, steamid) != INVALID_ADMIN_ID)
			{
				Format(info, sizeof(info), "%s",  name);
				AddMenuItem(menu, playerid, info);
			}
		}		
	}
	DisplayMenu(menu, client, 30);
}
public void Menu_Voteskick(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[32] , name[32];
		GetMenuItem(menu, param2, info, sizeof(info), _, name, sizeof(name));
		kickplayerinfo = info;
		kickplayername = name;
		PrintToChatAll("\x04%N 发起投票踢出 \x05 %s", param1, kickplayername);
		if(DisplayVoteKickMenu(param1)) FakeClientCommand(param1, "Vote Yes");
		
	}
}
public void Menu_Votesban(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[32] , name[32];
		GetMenuItem(menu, param2, info, sizeof(info), _, name, sizeof(name));
		banplayerinfo = info;
		banplayername = name;
		PrintToChatAll("\x04%N 发起投票封禁 \x05 %s 15分钟", param1, banplayername);
		if(DisplayVoteKickMenu(param1)) FakeClientCommand(param1, "Vote Yes");
		
	}
}

public bool DisplayVoteKickMenu(int client)
{
	if (!IsBuiltinVoteInProgress())
	{
		int iNumPlayers;
		char[] iPlayers = new char[MaxClients];
		
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || IsFakeClient(i))
			{
				continue;
			}
			iPlayers[iNumPlayers++] = i;
		}
		char sBuffer[64];
		g_hVoteKick = CreateBuiltinVote(VoteActionHandler, BuiltinVoteType_Custom_YesNo, BuiltinVoteAction_Cancel | BuiltinVoteAction_VoteEnd | BuiltinVoteAction_End);
		Format(sBuffer, sizeof(sBuffer), "踢出 '%s' ?", kickplayername);
		SetBuiltinVoteArgument(g_hVoteKick, sBuffer);
		SetBuiltinVoteInitiator(g_hVoteKick, client);
		SetBuiltinVoteResultCallback(g_hVoteKick, VoteResultHandler);
		DisplayBuiltinVoteToAll(g_hVoteKick, 20);
		PrintToChatAll("\x04%N \x03发起了一个投票", client);
		return true;
	}
	PrintToChat(client, "已经有一个投票正在进行.");
	return false;
}
public bool DisplayVotebanMenu(int client)
{
	if (!IsBuiltinVoteInProgress())
	{
		int iNumPlayers;
		char[] iPlayers = new char[MaxClients];
		
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || IsFakeClient(i))
			{
				continue;
			}
			iPlayers[iNumPlayers++] = i;
		}
		char sBuffer[64];
		g_hVoteban = CreateBuiltinVote(VoteActionHandler, BuiltinVoteType_Custom_YesNo, BuiltinVoteAction_Cancel | BuiltinVoteAction_VoteEnd | BuiltinVoteAction_End);
		Format(sBuffer, sizeof(sBuffer), "封禁 '%s' 15分钟?", banplayername);
		SetBuiltinVoteArgument(g_hVoteban, sBuffer);
		SetBuiltinVoteInitiator(g_hVoteban, client);
		SetBuiltinVoteResultCallback(g_hVoteban, VoteResultHandler);
		DisplayBuiltinVoteToAll(g_hVoteban, 20);
		PrintToChatAll("\x04%N \x03发起了一个投票", client);
		return true;
	}
	PrintToChat(client, "已经有一个投票正在进行.");
	return false;
}