/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#include "gamerules.h"
#include "money.h"
#include "radio.h"
#include "../../../valve/src/server/items.h"

var int g_cstrike_buying = 0;
var float g_cstrike_bombradius = 500;

var int g_cs_vipzones;
var int g_cs_escapezones;
var int g_cs_bombzones;

var int g_cs_bombplanted;
var int g_cs_roundswon_ct;
var int g_cs_roundswon_t;
var int g_cs_roundsplayed;
var int g_cs_alive_t;
var int g_cs_alive_ct;
var int g_cs_hostagesrescued;
var int g_cs_hostagestotal;
var int g_cs_roundslost_ct;
var int g_cs_roundslost_t;
var int g_cs_winstreak_ct;
var int g_cs_winstreak_t;
var int g_cs_bonus_ct;
var int g_cs_bonus_t;
var int g_cs_gamestate;
var float g_cs_gametime;

/* Counter-Strike's own cvars */
var int autocvar_mp_winlimit = 0;
var int autocvar_mp_halftime = 0;
var int autocvar_mp_startmoney = 800;
var float autocvar_mp_buytime = 90;
var float autocvar_mp_freezetime = 6;
var float autocvar_mp_c4timer = 45;
var float autocvar_mp_roundtime = 5;
var float autocvar_mp_timelimit = 60;
var string autocvar_motdfile = "motd.txt";
var int autocvar_mp_friendlyfire = FALSE;

/* new, FreeCS exclusive variables */
var int autocvar_fcs_voxannounce = FALSE;
var int autocvar_fcs_knifeonly = FALSE; /* Disallows buying and spawning with weps */
var int autocvar_fcs_swapteams = FALSE; /* Swaps spawnpoints */
var int autocvar_fcs_nopickups = FALSE; /* Disable weapon items */
var int autocvar_fcs_reward_kill = 300;
var int autocvar_fcs_penalty_pain = -150;
var int autocvar_fcs_penalty_kill = -1500;
var int autocvar_fcs_maxmoney = 16000;
var int autocvar_fcs_fillweapons = FALSE; /* This will automatically get ammo for the weapon you buy */
var int autocvar_fcs_fix_bombtimer = TRUE; /* If true, the bomb-timer will dictate the round-end */
var int autocvar_fcs_bombaltthrow = TRUE; /* Randomize the bomb-throw every time ever so slightly */

enum
{
	GAME_INACTIVE,
	GAME_COMMENCING,
	GAME_FREEZE,
	GAME_ACTIVE,
	GAME_END, 
	GAME_OVER
};
