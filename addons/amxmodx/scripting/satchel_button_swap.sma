#include <amxmodx>
#include <fakemeta>
#include <engine>
#include <nvault>

#define PLUGIN_NAME         "Satchel Button Swap"
#define PLUGIN_VERSION      "1.0.0"
#define PLUGIN_AUTHOR       "szGabu"

#define SWAP_VAULT_NAME     "satchel_swap_setting"

#if AMXX_VERSION_NUM < 183
#define MAX_PLAYERS         32
#define get_pcvar_bool(%1) 	(get_pcvar_num(%1) == 1)
#endif

new g_cvarPluginEnabled;
new g_cvarOnByDefault;
new bool:g_bPluginEnabled;
new bool:g_bOnByDefault;
new bool:g_bUserSatchelSwapped[MAX_PLAYERS + 1] = { false, ... };

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

	#if AMXX_VERSION_NUM < 183
	g_cvarPluginEnabled = register_cvar("amx_satchel_swap_enabled", "1");
	g_cvarOnByDefault = register_cvar("amx_satchel_swap_on_by_default", "0");
	register_cvar("amx_satchel_swap_version", PLUGIN_VERSION, FCVAR_SERVER);
	#else
	g_cvarPluginEnabled = create_cvar("amx_satchel_swap_enabled", "1", FCVAR_NONE, "Determines if the plugin is enabled or not.", true, 0.0, true, 1.0);
	g_cvarOnByDefault = create_cvar("amx_satchel_swap_on_by_default", "0", FCVAR_NONE, "Determines if players should have their satchel controls swapped by default.", true, 0.0, true, 1.0);

	AutoExecConfig();
	#endif

	register_clcmd("say /satchel", "Command_SaySatchel");
	register_forward(FM_CmdStart, "Forward_CmdStart_Post", true);
	register_dictionary("satchel_button_swap.txt");
}

public plugin_cfg()
{
	#if AMXX_VERSION_NUM < 183
	g_bPluginEnabled = get_pcvar_bool(g_cvarPluginEnabled);
	g_bOnByDefault = get_pcvar_bool(g_cvarOnByDefault);
	#else
	bind_pcvar_num(g_cvarPluginEnabled, g_bPluginEnabled);
	bind_pcvar_num(g_cvarOnByDefault, g_bOnByDefault);
	#endif
}

#if AMXX_VERSION_NUM >= 183
public OnConfigsExecuted()
{
    create_cvar("amx_satchel_swap_version", PLUGIN_VERSION, FCVAR_SERVER);
}
#endif

public client_authorized(iClient)
{
	if (!is_user_bot(iClient) && g_bPluginEnabled)
	{
        if (HasSatchelSetting(iClient))
            g_bUserSatchelSwapped[iClient] = RetrieveSatchelSettingFromVault(iClient);
        else
            g_bUserSatchelSwapped[iClient] = g_bOnByDefault;
	}
}

#if AMXX_VERSION_NUM < 183
public client_disconnect(iClient)
#else
public client_disconnected(iClient)
#endif
{
    g_bUserSatchelSwapped[iClient] = false;
}

public Command_SaySatchel(iClient)
{
    if(g_bPluginEnabled)
	    SaveSatchelSettingToVault(iClient, !g_bUserSatchelSwapped[iClient]);
}

public Forward_CmdStart_Post(iClient, iUcHandle, iSeed)
{
    if (!g_bUserSatchelSwapped[iClient] || !is_user_alive(iClient))
        return FMRES_IGNORED;

    static iWeapon;
    
    iWeapon = get_user_weapon(iClient);
    
    if (iWeapon == HLW_SATCHEL)
    {
        new iButtons = get_uc(iUcHandle, UC_Buttons);

        if(iButtons & (IN_ATTACK & IN_ATTACK2))
            return FMRES_IGNORED;

        new iSwappedButtons = iButtons;

        if (iButtons & IN_ATTACK)
        {
            iSwappedButtons &= ~IN_ATTACK;
            iSwappedButtons |= IN_ATTACK2;
        }
        else if (iButtons & IN_ATTACK2)
        {
            iSwappedButtons &= ~IN_ATTACK2;
            iSwappedButtons |= IN_ATTACK;
        }

        set_uc(iUcHandle, UC_Buttons, iSwappedButtons);

        return FMRES_HANDLED;
    }

    return FMRES_IGNORED;
}


bool:HasSatchelSetting(iClient)
{
	new szAuthID[32];
	new hVault = nvault_open(SWAP_VAULT_NAME);
	if (hVault != -1)
	{
		get_user_authid(iClient, szAuthID, 31);
		new szUnused[2];
		new iUnused;
		new bool:bHasSetting = nvault_lookup(hVault, szAuthID, szUnused, 1, iUnused) == 1;
		nvault_close(hVault);
		return bHasSetting;
	}
	return false;
}

bool:RetrieveSatchelSettingFromVault(iClient)
{
	new szAuthID[32];
	new hVault = nvault_open(SWAP_VAULT_NAME);
	if (hVault != -1)
	{
		get_user_authid(iClient, szAuthID, 31);
		new iVault = nvault_get(hVault, szAuthID);
		nvault_close(hVault);
		return iVault == 1;
	}
	return false;
}

bool:SaveSatchelSettingToVault(iClient, bool:bSatchelSwapped)
{
	new szAuthID[32];
	new hVault = nvault_open(SWAP_VAULT_NAME);
	if (hVault != -1)
	{
		get_user_authid(iClient, szAuthID, 31);
		new szVal[2];
		num_to_str(bSatchelSwapped, szVal, 1);
		nvault_set(hVault, szAuthID, szVal);
		client_print(iClient, 3, "* %L: %L", iClient, "SATCHEL_CONTROLS_TITLE", iClient, bSatchelSwapped ? "SATCHEL_CONTROLS_ENABLED" : "SATCHEL_CONTROLS_DISABLED");
		g_bUserSatchelSwapped[iClient] = bSatchelSwapped;
		nvault_close(hVault);
		return true;
	}
	return false;
}