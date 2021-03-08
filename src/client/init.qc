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

/*
=================
ClientGame_Init

Comparable to worldspawn in SSQC in that it's mostly used for precaches
=================
*/
void
ClientGame_Init(float apilevel, string enginename, float engineversion)
{
	registercommand("chooseteam");
	registercommand("buy");

	/* radio */
	registercommand("radio1");
	registercommand("radio2");
	registercommand("radio3");

	registercommand("motd");
	registercommand("drop");
	registercommand("nightvision");

	/* pistols */
	registercommand("glock");
	registercommand("usp");
	registercommand("p228");
	registercommand("deagle");
	registercommand("fn57");
	registercommand("elites");

	/* shotties */
	registercommand("m3");
	registercommand("xm1014");

	/* smg */
	registercommand("tmp");
	registercommand("mac10");
	registercommand("mp5");
	registercommand("ump45");

	/* rifles */
	registercommand("p90");
	registercommand("ak47");
	registercommand("m4a1");
	registercommand("sg552");
	registercommand("aug");
	registercommand("scout");
	registercommand("sg550");
	registercommand("awp");
	registercommand("g3sg1");

	/* lonely */
	registercommand("m249");

	/* ammo */
	registercommand("primammo");
	registercommand("buyammo1");
	registercommand("secammo");
	registercommand("buyammo2");

	/* equipment */
	registercommand("vest");
	registercommand("vesthelm");
	registercommand("flash");
	registercommand("hegren");
	registercommand("vsgren");
	registercommand("defuser");
	registercommand("nvg");

	/* radio */
	registercommand("coverme");
	registercommand("takepoint");
	registercommand("holdpos");
	registercommand("regroup");
	registercommand("followme");
	registercommand("takingfire");
	registercommand("go");
	registercommand("fallback");
	registercommand("sticktog");
	registercommand("getinpos");
	registercommand("stormfront");
	registercommand("report");
	registercommand("roger");
	registercommand("enemyspot");
	registercommand("needbackup");
	registercommand("sectorclear");
	registercommand("inposition");
	registercommand("reportingin");
	registercommand("getout");
	registercommand("negative");
	registercommand("enemydown");

	Obituary_Init();
}

void
ClientGame_InitDone(void)
{
	Textmenu_Call("TEAM_SELECT");
}

void
ClientGame_RendererRestart(string rstr)
{
	g_cs_cross = spriteframe("sprites/crosshairs.spr", 0, 0.0f);
	g_cs_scope0 = spriteframe("sprites/sniper_scope.spr", 0, 0.0f);
	g_cs_scope1 = spriteframe("sprites/top_left.spr", 0, 0.0f);
	g_cs_scope2 = spriteframe("sprites/top.spr", 0, 0.0f);
	g_cs_scope3 = spriteframe("sprites/top_right.spr", 0, 0.0f);
	g_cs_scope4 = spriteframe("sprites/left.spr", 0, 0.0f);
	g_cs_scope5 = spriteframe("sprites/right.spr", 0, 0.0f);
	g_cs_scope6 = spriteframe("sprites/bottom_left.spr", 0, 0.0f);
	g_cs_scope7 = spriteframe("sprites/bottom.spr", 0, 0.0f);
	g_cs_scope8 = spriteframe("sprites/bottom_right.spr", 0, 0.0f);

	Obituary_Precache();

	FX_Blood_Init();
	FX_BreakModel_Init();
	FX_Explosion_Init();
	FX_GibHuman_Init();
	FX_Spark_Init();
	FX_Impact_Init();
	FX_Smokenade_Init();
}
