#include <sourcemod>
#include <sdkhooks>
#include <colors>
#include <left4dhooks>
#define L4D2UTIL_STOCKS_ONLY
#include <l4d2util>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.0"

public Plugin myinfo = 
{
	name = "L4D2 Scavenge Scores Announce",
	author = "Air",
	description = "Announce the scavenge round time and scores",
	version = PLUGIN_VERSION,
	url = "https://github.com/A1oneR/"
};

static float		RoundTimeStart						= 0.0;
static int			RoundScore					    	= 0;
static int			duration					    	= 0;
static bool         bLetzPrintIt                        = false;
static char         FirstRoundTime[32]                  = 0;
static int          FirstRoundScore                     = 0;

public void OnPluginStart()
{
	HookEvent("scavenge_round_start", Event_OnRoundStart, EventHookMode_PostNoCopy);
	HookEvent("round_end", Event_OnRoundEnd, EventHookMode_PostNoCopy);
    HookEvent("gascan_pour_completed", Event_GasPourCompleted, EventHookMode_PostNoCopy);

}

public void Event_OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
    RoundTimeStart = GetGameTime();
    RoundScore = 0;
    bLetzPrintIt = true;
}

public void Event_OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
    if (bLetzPrintIt)
    {
        PrintScavengeStats();
    }
}

public void Event_GasPourCompleted(Event event, const char[] name, bool dontBroadcast)
{
	RoundScore++;
}

public void PrintScavengeStats()
{
    duration = RoundToFloor(GetGameTime() - RoundTimeStart);
	CreateTimer(3.0, Timer_PrintToChat);
    bLetzPrintIt = false;
}

public Action Timer_PrintToChat(Handle timer)
{
    char buffer[32];
    if (duration > 60)
	{
		Format(buffer, sizeof(buffer), "%d分钟 %d秒", duration / 60, duration % 60);
	}
	else
	{
		Format(buffer, sizeof(buffer), "%d秒", duration > 0 ? duration : 0);
	}
    int RoundNumber = GetScavengeRoundNumber();

    if (InSecondHalfOfRound())
    {
        CPrintToChatAll("{green}> {default}第{lightgreen}%i{default}轮 {lightgreen}上半{default}部分 时长: {lightgreen}%s {green}{default} / 灌油数量:{lightgreen} %i", RoundNumber, FirstRoundTime, FirstRoundScore);
    }
	CPrintToChatAll("{green}> {default}第{lightgreen}%i{default}轮 {lightgreen}%s{default}部分 时长: {lightgreen}%s {green}{default} / 灌油数量:{lightgreen} %i", RoundNumber, InSecondHalfOfRound() ? "下半" : "上半", buffer, RoundScore);

    if (!InSecondHalfOfRound())
    {
        FirstRoundTime = buffer;
        FirstRoundScore = RoundScore;
    }
    
    /* Sorry Codes, we don't need you anymore
	if (RoundScore == 0)
    {
        CPrintToChatAll("{red}Air{default}：嘿，这可不是一个好兆头");
    }
    else if (RoundScore > 20)
    {
        CPrintToChatAll("{blue}Air{default}：厉害，这下可要带来麻烦了");
    }
    if (duration < 90)
    {
        CPrintToChatAll("{red}Air{default}：哦吼，这下可结束的真够快的");
    }
    else if (duration >= 600)
    {
        CPrintToChatAll("{red}Air{default}：妈耶，这轮耗时也太长了吧");
    }
    */

}

stock int GetScavengeRoundNumber()
{
	return GameRules_GetProp("m_nRoundNumber");
}