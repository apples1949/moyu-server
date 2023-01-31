#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#define VERSION "1.0.1"

new Handle:g_hEnabled;
new Handle:g_hWeaponSniperScout;
new Handle:g_hWeaponSniperAWP;
new Handle:g_hWeaponSmg;
new Handle:g_hWeaponSmgSilenced;
new Handle:g_hWeaponSmgMp5;
new Handle:g_hWeaponPumpshotgun;
new Handle:g_hWeaponShotgunChrome;

new bool:g_bSpawnedMelee;

public Plugin:myinfo =
{
    name = "Weapon In The Saferoom",
    author = "N3wton, J.Q",
    description = "Spawns a selection of weapons in the saferoom, at the start of each round.",
    version = VERSION
};

public OnPluginStart()
{
    decl String:GameName[12];
    GetGameFolderName(GameName, sizeof(GameName));
    if( !StrEqual(GameName, "left4dead2") )
        SetFailState( "Melee In The Saferoom is only supported on left 4 dead 2." );
        
    CreateConVar( "l4d2_MITSR_Version",     VERSION, "The version of Melee In The Saferoom"); 
    g_hEnabled              = CreateConVar( "l4d2_WITSR_Enabled",       "1", "Should the plugin be enabled"); 
    g_hWeaponSniperScout    = CreateConVar( "l4d2_WITSR_SniperScout",   "1", "Number of Sniper Scout to spawn");
    g_hWeaponSniperAWP    = CreateConVar( "l4d2_WITSR_SniperAWP",   "1", "Number of Sniper AWP to spawn");
    g_hWeaponSmg    = CreateConVar( "l4d2_WITSR_Smg",   "1", "Number of Smg to spawn");
    g_hWeaponSmgSilenced    = CreateConVar( "l4d2_WITSR_SmgSilenced",   "2", "Number of Smg Silenced to spawn");
    g_hWeaponSmgMp5    = CreateConVar( "l4d2_WITSR_SmgMp5",   "1", "Number of Smg Mp5 to spawn");
    g_hWeaponPumpshotgun    = CreateConVar( "l4d2_WITSR_Pumpshotgun",   "2", "Number of Pumpshotgun to spawn");
    g_hWeaponShotgunChrome    = CreateConVar( "l4d2_WITSR_ShotgunChrome",   "1", "Number of ShotgunChrome to spawn");
    
    HookEvent( "round_start", Event_RoundStart );
    
}

public OnMapStart()
{
    PrecacheModel( "models/w_models/weapons/w_sniper_scout.mdl");
    PrecacheModel( "models/v_models/v_snip_scout.mdl");
    PrecacheModel( "models/w_models/weapons/w_sniper_awp.mdl");
    PrecacheModel( "models/v_models/v_snip_awp.mdl");
    PrecacheModel( "models/w_models/Weapons/w_smg_mp5.mdl");
    PrecacheModel( "models/v_models/v_smg_mp5.mdl");
    PrecacheModel( "models/w_models/weapons/w_smg.mdl");
    PrecacheModel( "models/v_models/v_smg.mdl");
    PrecacheModel( "models/w_models/weapons/w_smg_silenced.mdl");
    PrecacheModel( "models/v_models/v_smg_silenced.mdl");
    PrecacheModel( "models/w_models/weapons/w_pumpshotgun.mdl");
    PrecacheModel( "models/v_models/v_pumpshotgun.mdl");
    PrecacheModel( "models/w_models/weapons/w_shotgun_chrome.mdl");
    PrecacheModel( "models/v_models/v_shotgun_chrome.mdl");
}

public Action:Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
    if( !GetConVarBool( g_hEnabled ) ) return Plugin_Continue;
    
    g_bSpawnedMelee = false;
        
    CreateTimer( 1.0, Timer_SpawnMelee );
    
    return Plugin_Continue;
}

public Action:Timer_SpawnMelee( Handle:timer )
{
    new client = GetInGameClient();

    if( client != 0 && !g_bSpawnedMelee )
    {
        SpawnCustomList(client);
        g_bSpawnedMelee = true;
    }
    else
    {
        if( !g_bSpawnedMelee ) CreateTimer( 1.0, Timer_SpawnMelee );
    }
}

stock SpawnCustomList(int client)
{
    //Spawn SniperScout
    if( GetConVarInt( g_hWeaponSniperScout ) > 0 )
    {
        for( new i = 0; i < GetConVarInt( g_hWeaponSniperScout ); i++ )
        {
            StripAndExecuteClientCommands(client, "sniper_scout");
        }
    }
    
    //Spawn SniperAWP
    if( GetConVarInt( g_hWeaponSniperAWP ) > 0 )
    {
        for( new i = 0; i < GetConVarInt( g_hWeaponSniperAWP ); i++ )
        {
            StripAndExecuteClientCommands(client, "sniper_awp");
        }
    }
    
    //Spawn Smg
    if( GetConVarInt( g_hWeaponSmg ) > 0 )
    {
        for( new i = 0; i < GetConVarInt( g_hWeaponSmg ); i++ )
        {
            StripAndExecuteClientCommands(client, "smg");
        }
    }
    
    //Spawn SmgSilenced
    if( GetConVarInt( g_hWeaponSmgSilenced ) > 0 )
    {
        for( new i = 0; i < GetConVarInt( g_hWeaponSmgSilenced ); i++ )
        {
            StripAndExecuteClientCommands(client, "smg_silenced");
        }
    }
    
    //Spawn SmgMp5
    if( GetConVarInt( g_hWeaponSmgMp5 ) > 0 )
    {
        for( new i = 0; i < GetConVarInt( g_hWeaponSmgMp5 ); i++ )
        {
            StripAndExecuteClientCommands(client, "smg_mp5");
        }
    }
    
    //Spawn ShotgunChrome
    if( GetConVarInt( g_hWeaponShotgunChrome ) > 0 )
    {
        for( new i = 0; i < GetConVarInt( g_hWeaponShotgunChrome ); i++ )
        {
            StripAndExecuteClientCommands(client, "shotgun_chrome");
        }
    }
    
    //Spawn Pumpshotgun
    if( GetConVarInt( g_hWeaponPumpshotgun ) > 0 )
    {
        for( new i = 0; i < GetConVarInt( g_hWeaponPumpshotgun ); i++ )
        {
            StripAndExecuteClientCommands(client, "pumpshotgun");
        }
    }
}

void StripAndExecuteClientCommands(int client, const char[] arguments) 
{
	int flags = GetCommandFlags("give");
	SetCommandFlags("give", flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s", "give", arguments);
	SetCommandFlags("give", flags);
}

stock GetInGameClient()
{
    for( new x = 1; x <= GetClientCount( true ); x++ )
    {
        if( IsClientInGame( x ) && GetClientTeam( x ) == 2 )
        {
            return x;
        }
    }
    return 0;
}

stock bool:IsVersus()
{
    new String:GameMode[32];
    GetConVarString( FindConVar( "mp_gamemode" ), GameMode, 32 );
    if( StrContains( GameMode, "versus", false ) != -1 ) return true;
    return false;
}