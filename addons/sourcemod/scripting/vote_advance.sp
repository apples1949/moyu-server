#include <sourcemod>
#include <builtinvotes>

#define FILE_PATH		"configs/cfgs.txt"

new Handle:g_hVote = INVALID_HANDLE;
new Handle:g_hVoteKick = INVALID_HANDLE;
new Handle:g_hVoteMoveSpectator = INVALID_HANDLE;
new Handle:g_hVoteKickSpectator = INVALID_HANDLE;
new Handle:g_hCfgsKV = INVALID_HANDLE;
new String:g_sCfg[32];
new String:kickplayerinfo[MAX_NAME_LENGTH];
new String:kickplayername[MAX_NAME_LENGTH];
new bool:bPass;

public Plugin:myinfo = 
{
	name = "投票读取cfg文件",
	author = "HazukiYuro",
	description = "!vote投票",
	version = "1.1",
	url = ""
}

public OnPluginStart()
{
	decl String:sBuffer[128];
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
	RegConsoleCmd("sm_vms", Command_VotesMoveSpectator);
	RegConsoleCmd("sm_vks", Command_VoteskickSpectator);
	
	RegConsoleCmd("sm_serverhp", Command_ServerHp, _, ADMFLAG_KICK);

	RegAdminCmd("sm_cv", Command_VoteCancel, ADMFLAG_GENERIC);
	RegAdminCmd("sm_cancelvote", Command_VoteCancel, ADMFLAG_GENERIC);
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

stock CheatCommand(Client, const String:command[], const String:arguments[])
{
	new admindata = GetUserFlagBits(Client);
	SetUserFlagBits(Client, ADMFLAG_ROOT);
	new flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	FakeClientCommand(Client, "%s %s", command, arguments);
	SetCommandFlags(command, flags);
	SetUserFlagBits(Client, admindata);
}

public Action:Command_ServerHp(client, args)
{
	for(new i = 1; i <= MaxClients; i++)
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

public Action:CommondVote(client, args)
{
	if (!client) return Plugin_Handled;
	if (args > 0)
	{
		decl String:sCfg[64], String:sBuffer[256];
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

bool:FindConfigName(const String:cfg[], String:message[], maxlength)
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

ShowVoteMenu(client)
{
	new Handle:hMenu = CreateMenu(VoteMenuHandler);
	SetMenuTitle(hMenu, "选择:");
	new String:sBuffer[64];
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

public VoteMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		new String:sInfo[64], String:sBuffer[64];
		GetMenuItem(menu, param2, sInfo, sizeof(sInfo));
		KvRewind(g_hCfgsKV);
		if (KvJumpToKey(g_hCfgsKV, sInfo) && KvGotoFirstSubKey(g_hCfgsKV))
		{
			new Handle:hMenu = CreateMenu(ConfigsMenuHandler);
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

public ConfigsMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		new String:sInfo[64], String:sBuffer[64];
		GetMenuItem(menu, param2, sInfo, sizeof(sInfo), _, sBuffer, sizeof(sBuffer));
		strcopy(g_sCfg, sizeof(g_sCfg), sInfo);
		
		if(StrEqual(g_sCfg, "sm_votekick"))
		{
			FakeClientCommand(param1, "sm_votekick");
		}
		else if (StrEqual(g_sCfg, "sm_vms"))
		{
			FakeClientCommand(param1, "sm_vms");
		}
		else
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

bool:StartVote(client, const String:cfgname[])
{
	if (!IsBuiltinVoteInProgress())
	{
		new iNumPlayers;
		decl iPlayers[MaxClients];
		
		for (new i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || IsFakeClient(i))
			{
				continue;
			}
			iPlayers[iNumPlayers++] = i;
		}
		new String:sBuffer[64];
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

public VoteActionHandler(Handle:vote, BuiltinVoteAction:action, param1, param2)
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

public void VoteResultHandler(Handle vote, int num_votes, int num_clients, const int[][] client_info, int num_items, const int[][] item_info)
{
	for (new i = 0; i < num_items; i++)
	{
		if (item_info[i][BUILTINVOTEINFO_ITEM_INDEX] == BUILTINVOTES_VOTE_YES)
		{
			if (item_info[i][BUILTINVOTEINFO_ITEM_VOTES] >= (num_votes * 0.6))
			{
				bPass = true;
				DisplayBuiltinVotePass(vote, "投票已通过");
				if (vote == g_hVote)
				{
					DisplayBuiltinVotePass(vote, "cfg文件正在加载...");
					ServerCommand("%s", g_sCfg);
					//return;
				}
				else if(vote == g_hVoteKick)
				{
					ServerCommand("sm_kick %s 投票踢出", kickplayername);
					//return;
				}
				else if(vote == g_hVoteMoveSpectator)
				{
					ServerCommand("sm_swapto 1 %s", kickplayername);
					//return;
				}
				else if(vote == g_hVoteKickSpectator)
				{
					ServerCommand("sm_kick %s 旁观投票踢出", kickplayername);
					//return;
				}
			}
		}
	}
	if (bPass == true)
	{
		DisplayBuiltinVotePass(vote, "投票已通过");
	}
	else
	{
		DisplayBuiltinVoteFail(vote, BuiltinVoteFail_Loses);
	}
	bPass = false;
	return;
}

public Action:Command_Voteskick(client, args)
{
	if(client != 0 && client <= MaxClients) 
	{
		CreateVotekickMenu(client);
		return Plugin_Handled;
	}
	return Plugin_Handled;
}

public Action:Command_VotesMoveSpectator(client, args)
{
	if(client != 0 && client <= MaxClients) 
	{
		CreateVoteMoveSpectatorMenu(client);
		return Plugin_Handled;
	}
	return Plugin_Handled;
}

public Action:Command_VoteskickSpectator(int client, int args)
{
	if(client != 0 && client <= MaxClients) 
	{
		CreateVotekickSpectatorMenu(client);
		return Plugin_Handled;
	}
	return Plugin_Handled;
}

CreateVotekickSpectatorMenu(client)
{	
	new Handle:menu = CreateMenu(Menu_VoteskickSpectator);		
	new String:name[MAX_NAME_LENGTH];
	new String:info[MAX_NAME_LENGTH + 6];
	new String:playerid[32];
	SetMenuTitle(menu, "选择踢出旁观玩家");
	for(new i = 1;i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == 1)
		{
			Format(playerid,sizeof(playerid),"%i",GetClientUserId(i));
			if(GetClientName(i,name,sizeof(name)))
			{
				Format(info, sizeof(info), "%s",  name);
				AddMenuItem(menu, playerid, info);
			}
		}		
	}
	DisplayMenu(menu, client, 30);
}

public Menu_VoteskickSpectator(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		new String:info[32] , String:name[32];
		GetMenuItem(menu, param2, info, sizeof(info), _, name, sizeof(name));
		kickplayerinfo = info;
		kickplayername = name;
		PrintToChatAll("\x04%N 发起投票踢出 \x05 %s", param1, kickplayername);
		if(DisplayVoteKickSpectatorMenu(param1)) FakeClientCommand(param1, "Vote Yes");
		
	}
}

public bool:DisplayVoteKickSpectatorMenu(client)
{
	if (!IsBuiltinVoteInProgress())
	{
		new iNumPlayers;
		decl iPlayers[MaxClients];
		
		for (new i = 1; i <= MaxClients; i++)
		{
			if ((!IsClientInGame(i) || IsFakeClient(i)))
			{
				continue;
			}
			iPlayers[iNumPlayers++] = i;
		}
		new String:sBuffer[64];
		g_hVoteKickSpectator = CreateBuiltinVote(VoteActionHandler, BuiltinVoteType_Custom_YesNo, BuiltinVoteAction_Cancel | BuiltinVoteAction_VoteEnd | BuiltinVoteAction_End);
		Format(sBuffer, sizeof(sBuffer), "踢出旁观者'%s' ?", kickplayername);
		SetBuiltinVoteArgument(g_hVoteKickSpectator, sBuffer);
		SetBuiltinVoteInitiator(g_hVoteKickSpectator, client);
		SetBuiltinVoteResultCallback(g_hVoteKickSpectator, VoteResultHandler);
		DisplayBuiltinVoteToAll(g_hVoteKickSpectator, 20);
		PrintToChatAll("\x04%N \x03发起了一个投票", client);
		return true;
	}
	PrintToChat(client, "已经有一个投票正在进行.");
	return false;
}

CreateVotekickMenu(client)
{	
	new Handle:menu = CreateMenu(Menu_Voteskick);		
	new String:name[MAX_NAME_LENGTH];
	new String:info[MAX_NAME_LENGTH + 6];
	new String:playerid[32];
	SetMenuTitle(menu, "选择踢出玩家");
	for(new i = 1;i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == GetClientTeam(client))
		{
			Format(playerid,sizeof(playerid),"%i",GetClientUserId(i));
			if(GetClientName(i,name,sizeof(name)))
			{
				Format(info, sizeof(info), "%s",  name);
				AddMenuItem(menu, playerid, info);
			}
		}		
	}
	DisplayMenu(menu, client, 30);
}
public Menu_Voteskick(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		new String:info[32] , String:name[32];
		GetMenuItem(menu, param2, info, sizeof(info), _, name, sizeof(name));
		kickplayerinfo = info;
		kickplayername = name;
		PrintToChatAll("\x04%N 发起投票踢出 \x05 %s", param1, kickplayername);
		if(DisplayVoteKickMenu(param1)) FakeClientCommand(param1, "Vote Yes");
		
	}
}

public bool:DisplayVoteKickMenu(client)
{
	if (!IsBuiltinVoteInProgress())
	{
		new iNumPlayers;
		decl iPlayers[MaxClients];
		
		for (new i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || IsFakeClient(i))
			{
				continue;
			}
			if (GetClientTeam(i) != GetClientTeam(client))
			{
				continue;
			}
			iPlayers[iNumPlayers++] = i;
		}
		new String:sBuffer[64];
		g_hVoteKick = CreateBuiltinVote(VoteActionHandler, BuiltinVoteType_Custom_YesNo, BuiltinVoteAction_Cancel | BuiltinVoteAction_VoteEnd | BuiltinVoteAction_End);
		Format(sBuffer, sizeof(sBuffer), "踢出 '%s' ?", kickplayername);
		SetBuiltinVoteArgument(g_hVoteKick, sBuffer);
		SetBuiltinVoteInitiator(g_hVoteKick, client);
		SetBuiltinVoteResultCallback(g_hVoteKick, VoteResultHandler);
		DisplayBuiltinVote(g_hVoteKick, iPlayers, iNumPlayers, 20);
		PrintToChatAll("\x04%N \x03发起了一个投票", client);
		return true;
	}
	PrintToChat(client, "已经有一个投票正在进行.");
	return false;
}

CreateVoteMoveSpectatorMenu(client)
{	
	new Handle:menu = CreateMenu(Menu_VotesMoveSpectator);		
	new String:name[MAX_NAME_LENGTH];
	new String:info[MAX_NAME_LENGTH + 6];
	new String:playerid[32];
	SetMenuTitle(menu, "选择强制移至旁观玩家");
	for(new i = 1;i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == GetClientTeam(client))
		{
			Format(playerid,sizeof(playerid),"%i",GetClientUserId(i));
			if(GetClientName(i,name,sizeof(name)))
			{
				Format(info, sizeof(info), "%s",  name);
				AddMenuItem(menu, playerid, info);
			}
		}		
	}
	DisplayMenu(menu, client, 30);
}
public Menu_VotesMoveSpectator(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		new String:info[32] , String:name[32];
		GetMenuItem(menu, param2, info, sizeof(info), _, name, sizeof(name));
		kickplayerinfo = info;
		kickplayername = name;
		PrintToChatAll("\x04%N 发起投票强制移至旁观 \x05 %s", param1, kickplayername);
		if(DisplayVoteMoveSpectatorMenu(param1)) FakeClientCommand(param1, "Vote Yes");
		
	}
}

public bool:DisplayVoteMoveSpectatorMenu(client)
{
	if (!IsBuiltinVoteInProgress())
	{
		new iNumPlayers;
		decl iPlayers[MaxClients];
		
		for (new i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || IsFakeClient(i))
			{
				continue;
			}
			if (GetClientTeam(i) != GetClientTeam(client))
			{
				continue;
			}
			iPlayers[iNumPlayers++] = i;
		}
		new String:sBuffer[64];
		g_hVoteMoveSpectator = CreateBuiltinVote(VoteActionHandler, BuiltinVoteType_Custom_YesNo, BuiltinVoteAction_Cancel | BuiltinVoteAction_VoteEnd | BuiltinVoteAction_End);
		Format(sBuffer, sizeof(sBuffer), "强制移至旁观 '%s' ?", kickplayername);
		SetBuiltinVoteArgument(g_hVoteMoveSpectator, sBuffer);
		SetBuiltinVoteInitiator(g_hVoteMoveSpectator, client);
		SetBuiltinVoteResultCallback(g_hVoteMoveSpectator, VoteResultHandler);
		DisplayBuiltinVote(g_hVoteMoveSpectator, iPlayers, iNumPlayers, 20);
		PrintToChatAll("\x04%N \x03发起了一个投票", client);
		return true;
	}
	PrintToChat(client, "已经有一个投票正在进行.");
	return false;
}