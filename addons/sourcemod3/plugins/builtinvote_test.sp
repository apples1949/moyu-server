#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <builtinvotes>

Handle g_hVoteHandler = null;

public void OnPluginStart()
{
	RegAdminCmd("sm_builtinvotes_test", Cmd_BuiltinVotesTest, ADMFLAG_GENERIC);
}

public Action Cmd_BuiltinVotesTest(int iClient, int iArgs)
{
	StartBuiltinVote(iClient);

	return Plugin_Handled;
}

void StartBuiltinVote(const int iInitiator)
{
	if (IsNewBuiltinVoteAllowed()) {
		int iNumPlayers;
		int[] iPlayers = new int[MaxClients];
		for (int i = 1; i <= MaxClients; i++) {
			if (!IsClientInGame(i) || IsFakeClient(i)) {
				continue;
			}

			iPlayers[iNumPlayers++] = i;
		}

		g_hVoteHandler = CreateBuiltinVote(VoteActionHandler, BuiltinVoteType_Custom_YesNo, BuiltinVoteAction_Cancel | BuiltinVoteAction_VoteEnd | BuiltinVoteAction_End);
		
		char sBuffer[64];
		Format(sBuffer, sizeof(sBuffer), "Builtinvote test!");
		SetBuiltinVoteArgument(g_hVoteHandler, sBuffer);
		SetBuiltinVoteInitiator(g_hVoteHandler, iInitiator);
		SetBuiltinVoteResultCallback(g_hVoteHandler, VoteResultHandler);
		
		DisplayBuiltinVote(g_hVoteHandler, iPlayers, iNumPlayers, 20);
		//FakeClientCommand(iInitiator, "Vote Yes");
		return;
	}

	PrintToChat(iInitiator, "Builtinvote cannot be started now.");
}

public int VoteActionHandler(Handle hVote, BuiltinVoteAction iAction, int iParam1, int iParam2)
{
	switch (iAction) {
		case BuiltinVoteAction_End: {
			g_hVoteHandler = null;
			delete hVote;
		}
		case BuiltinVoteAction_Cancel: {
			DisplayBuiltinVoteFail(hVote, BuiltinVoteFail_Generic);
		}
	}
}

public void VoteResultHandler(Handle hVote, int iNumVotes, int iNumClients, const int[][] iClientInfo, int iNumItems, const int[][] iItemInfo)
{
	for (int i = 0; i < iNumItems; i++) {
		if (iItemInfo[i][BUILTINVOTEINFO_ITEM_INDEX] == BUILTINVOTES_VOTE_YES) {
			if (iItemInfo[i][BUILTINVOTEINFO_ITEM_VOTES] > (iNumClients / 2)) {
				DisplayBuiltinVotePass(hVote, "Builtinvote test end...");
				return;
			}
		}
	}

	DisplayBuiltinVoteFail(hVote, BuiltinVoteFail_Loses);
}