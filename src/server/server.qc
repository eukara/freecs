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

void
Game_InitRules(void)
{
	if (cvar("sv_playerslots") == 1 || cvar("coop") == 1) {
		g_grMode = spawn(CSSingleplayerRules);
	} else {
		g_grMode = spawn(CSMultiplayerRules);
	}
}

void Game_Worldspawn(void)
{
	precache_model("models/player/arctic/arctic.mdl");
	precache_model("models/player/gign/gign.mdl");
	precache_model("models/player/gsg9/gsg9.mdl");
	precache_model("models/player/guerilla/guerilla.mdl");
	precache_model("models/player/leet/leet.mdl");
	precache_model("models/player/sas/sas.mdl");
	precache_model("models/player/terror/terror.mdl");
	precache_model("models/player/urban/urban.mdl");
	precache_model("models/player/vip/vip.mdl");
	precache_sound("weapons/ric_metal-2.wav");
	precache_sound("player/pl_pain2.wav");
	precache_sound("player/pl_pain4.wav");
	Sound_Precache("buy.kevlar");
	Sound_Precache("buy.weapon");
	Sound_Precache("buy.ammo");

	/* some Counter-Strike maps do not have weapon pickups, so we want to
	 * precache these regardless in case of someone dropping a weapon,
	 * which happens quite often (buying weapons, etc.) */
	Sound_Precache("item.respawn");
	Sound_Precache("weapon.pickup");

	Weapons_Init();

	clientstat(STAT_MONEY, EV_INTEGER, player::money);
	clientstat(STAT_PROGRESS, EV_FLOAT, player::progress);

	pointerstat(STAT_GAMETIME, EV_FLOAT, &g_cs_gametime);
	pointerstat(STAT_GAMESTATE, EV_INTEGER, &g_cs_gamestate);
}
