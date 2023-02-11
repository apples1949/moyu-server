#pragma semicolon 1
//強制1.7以後的新語法
#pragma newdecls required
#include <sourcemod>

public void OnPluginStart()
{
	l4d2_hostname();
	
	RegAdminCmd("sm_host", Addhostname, ADMFLAG_KICK, "重新加载服务器中文名l4d2_hostname.txt");
}

public void OnMapStart()
{
	l4d2_hostname();
}

public Action Addhostname(int client, int args)
{
	l4d2_hostname();
	PrintToChat(client, "\x04[提示]\x05重新加载服务器中文名配置文件\x03l4d2_hostname.txt\x05成功.");
	return Plugin_Handled;
}

void l4d2_hostname()
{
	char hostname[256];
	BuildPath(Path_SM, hostname, 256, "configs/hostname/l4d2_hostname.txt");
	Handle file = OpenFile(hostname, "rb");
	if (file)
	{
		char readData[256];
		while (!IsEndOfFile(file) && ReadFileLine(file, readData, 256))
		{
			SetConVarString(FindConVar("hostname"), readData);
		}
		CloseHandle(file);
	}
}