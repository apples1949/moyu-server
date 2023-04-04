#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

new Handle:l4d_ready_cfg_name;

public Plugin:myinfo =
{
	name = "readyup_cvar_only",
	author = "blueblur",
	description = "This plugin dose nothing,only provideing a cvar to be used by server_namer.smx",
	version = "1.0",
	url = ""
}


public OnPluginStart()
{
    l4d_ready_cfg_name = CreateConVar("l4d_ready_cfg_name", "AstMod v2.6.3", "Configname to display on the ready-up panel", FCVAR_PLUGIN|FCVAR_PRINTABLEONLY);
}