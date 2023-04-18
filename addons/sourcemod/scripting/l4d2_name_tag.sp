#include <sourcemod>
#include <colors>

#define NAME_TAG_FILE_PATH "configs/l4d2_name_tag.txt"
#define PLUGIN_VERSION     "1.1.1"
#define TAG_MAX_LENGTH     256
#define PF_MAX_LENGTH      32

// ConVars
ConVar
    g_cVLntAdminPrefix,
    g_cVLntModeratorPrefix;

// Variables
char
    g_cNameTagPath[256],
    g_cLntAdminPrefix[PF_MAX_LENGTH],
    g_cLntModeratorPrefix[PF_MAX_LENGTH],
    g_cNameTag[MAXPLAYERS+1][TAG_MAX_LENGTH];

KeyValues 
    g_KvNameTagList;

public Plugin myinfo =  
{
    name = "L4D2 Name Tag",
    author = "PaaNChaN",
    description = "add nametag to the chat function of bequiet.smx",
    version = PLUGIN_VERSION,
    url = "https://github.com/PaaNChaN/L4D2_Plugins"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    CreateNative("LNT_GetNameTag", Native_LNT_GetNameTag);
    
    RegPluginLibrary("l4d2_name_tag");
    return APLRes_Success;
}

public int Native_LNT_GetNameTag(Handle plugin, int numParams)
{
    new client = GetNativeCell(1);

    if (IsClientInGame(client) && !IsFakeClient(client))
    {
        SetNativeString(2, g_cNameTag[client], GetNativeCell(3));
        return true;
    }

    return false;
}

public void OnPluginStart()
{
    BuildPath(Path_SM, g_cNameTagPath, sizeof(g_cNameTagPath), NAME_TAG_FILE_PATH);

    if (!FileExists(g_cNameTagPath))
    {
        SetFailState("Couldn't load l4d2_name_tag.txt!");
    }

    g_cVLntAdminPrefix     = CreateConVar("lnt_admin_prefix", "(A)", "type of admin prefix.");
    g_cVLntModeratorPrefix = CreateConVar("lnt_moderator_prefix", "(M)", "type of moderator prefix.");

    RegAdminCmd("sm_lnametag", LoadNameTag_Cmd, ADMFLAG_BAN, "reload the l4d2_name_tag.txt");
    RegAdminCmd("sm_lnt", LoadNameTag_Cmd, ADMFLAG_BAN, "reload the l4d2_name_tag.txt");

    g_cVLntAdminPrefix.AddChangeHook(OnConVarChanged);
    g_cVLntModeratorPrefix.AddChangeHook(OnConVarChanged);
}

public void OnConfigsExecuted()
{
    g_cVLntAdminPrefix.GetString(g_cLntAdminPrefix, sizeof(g_cLntAdminPrefix));
    g_cVLntModeratorPrefix.GetString(g_cLntModeratorPrefix, sizeof(g_cLntModeratorPrefix));
    LoadNameTag();
}

public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    g_cVLntAdminPrefix.GetString(g_cLntAdminPrefix, sizeof(g_cLntAdminPrefix));
    g_cVLntModeratorPrefix.GetString(g_cLntModeratorPrefix, sizeof(g_cLntModeratorPrefix));
    LoadNameTag();
}

public void OnClientPostAdminCheck(int client)
{
    getClientNameTag(client);
}

public Action LoadNameTag_Cmd(int client, int args)
{
    CPrintToChatAll("<{green}NameTag{default}> NameTag was reloaded.");
    LoadNameTag();

    return Plugin_Handled;
}

public void LoadNameTag()
{
    for (int client = 1; client <= MaxClients; client++)
    {
        if (IsClientInGame(client) && !IsFakeClient(client))
        {
            getClientNameTag(client);
        }
    }
}

public void getClientNameTag(int client)
{
    if (!LoadKeyValues())
    {
        return;
    }

    g_cNameTag[client] = "";

    char sAuth[64];
    GetClientAuthId(client, AuthId_Steam2, sAuth, sizeof(sAuth));

    g_KvNameTagList.Rewind();
    if (g_KvNameTagList.JumpToKey(sAuth, false))
    {
        char cTagName[TAG_MAX_LENGTH];
        g_KvNameTagList.GetString("tag", cTagName, sizeof(cTagName));
        Format(g_cNameTag[client], TAG_MAX_LENGTH, "%s ", cTagName);
    }

    if (IsClientAdmin(client, Admin_Root) && strlen(g_cLntAdminPrefix) > 0)
    {
        Format(g_cNameTag[client], TAG_MAX_LENGTH, "{green}%s{default} %s", g_cLntAdminPrefix, g_cNameTag[client]);
    }
    else if (IsClientAdmin(client, Admin_Generic) && strlen(g_cLntModeratorPrefix) > 0)
    {
        Format(g_cNameTag[client], TAG_MAX_LENGTH, "{olive}%s{default} %s", g_cLntModeratorPrefix, g_cNameTag[client]);
    }
}

stock bool LoadKeyValues()
{
    g_KvNameTagList = new KeyValues("NameTag");
    return g_KvNameTagList.ImportFromFile(g_cNameTagPath);
}

stock bool IsClientAdmin(int client, AdminFlag flag)
{
    AdminId aid = GetUserAdmin(client);

    if(GetAdminFlag(aid, flag))
    {
        return true;
    }

    return false;
}