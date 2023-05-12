#if defined _match_vote_included
 #endinput
#endif
#define _match_vote_included

native Action CallMatchMenu(int value);

public SharedPlugin __pl_l4d_boss_vote = 
{
	name = "match_vote",
	file = "match_vote.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};