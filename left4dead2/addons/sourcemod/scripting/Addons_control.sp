#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <left4dhooks>

File g_hFiles;

public Plugin myinfo =
{
	name = "Addons control",
	author = "Sky, J.Q",
	version = "0.0.1",
	description = "Manages who can use Addons",
	url = "https://github.com/ConfoglTeam/ProMod"
}

public void OnPluginStart()
{

}

public Action L4D2_OnClientDisableAddons(const char[] SteamID)
{
	char sPath[PLATFORM_MAX_PATH];
	
	GetGameFolderName(sPath, sizeof(sPath));
	
	BuildPath(Path_SM, sPath, sizeof(sPath), "configs/Addonsmodes.txt");
	
	g_hFiles = OpenFile(sPath, "r");
	
	LogMessage("[Addons] Loading Addons control");
	
	char sBuffer[64];
	
	while(ReadFileLine(g_hFiles, sBuffer, sizeof(sBuffer)))
	{
		TrimString(sBuffer);
		
		LogMessage("[Addons] loop");
		
		if(strcmp(sBuffer, SteamID) == 0 )
		{
			LogMessage("[Addons] you can use Addons");
			delete g_hFiles;
			return Plugin_Handled;
		}
	}
	LogMessage("[Addons] you can not use Addons");
	delete g_hFiles;
	return Plugin_Continue;
}

//LogMessage("[Addons] can't find FirstSubKey.");
//public void MI_KV_Close()
//{
//	if(g_hFiles == null) return;
//	CloseHandle(g_hFiles);
//	g_hFiles = null;
//}

//MI_KV_Load()
//{
//	char sPath[64];
//	if (KvGotoFirstSubKey(g_hFiles))
//	{
//		do
//		{
//			LogMessage("g_hFiles %s", g_hFiles) ;
//			if (KvJumpToKey(g_hFiles, SteamID))
//			{
//				PrintToChatAll("SteamID %s ", SteamID);
//				LogMessage("g_hFiles %s ", g_hFiles);
//				//MI_KV_Close();
//				if(g_hFiles != null) 
//				{
//					CloseHandle(g_hFiles);
//					g_hFiles = null;
//				}
//				return Plugin_Handled;
//			}
//		} while (KvGotoNextKey(g_hFiles));
//	}
//}
//先获得kv文件的句柄，循环，循环里用KvJumpToKey判断所需的key是否存在，存在则进行下一步处理

