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

void HUD_DrawWeaponSelect(void);

/* Use first frame for drawing (needs precache) */
#define NUMSIZE_X 24/256
#define NUMSIZE_Y 24/256
#define HUD_ALPHA 0.5

float spr_hudnum[10] = {
	0 / 256,
	23 / 256,
	47 / 256,
	70 / 256,
	95 / 256,
	119 / 256,
	144 / 256,
	169 / 256,
	192 / 256,
	216 / 256
};

/* precaches */
void
HUD_Init(void)
{
	precache_model("sprites/640_logo.spr");

	g_hud1_spr = spriteframe("sprites/640hud1.spr", 0, 0.0f);
	g_hud2_spr = spriteframe("sprites/640hud2.spr", 0, 0.0f);
	g_hud3_spr = spriteframe("sprites/640hud3.spr", 0, 0.0f);
	g_hud4_spr = spriteframe("sprites/640hud4.spr", 0, 0.0f);
	g_hud5_spr = spriteframe("sprites/640hud5.spr", 0, 0.0f);
	g_hud6_spr = spriteframe("sprites/640hud6.spr", 0, 0.0f);
	g_hud7_spr = spriteframe("sprites/640hud7.spr", 0, 0.0f);
	g_hud10_spr = spriteframe("sprites/640hud10.spr", 0, 0.0f);
	g_hud11_spr = spriteframe("sprites/640hud11.spr", 0, 0.0f);
	g_hud12_spr = spriteframe("sprites/640hud12.spr", 0, 0.0f);
	g_hud13_spr = spriteframe("sprites/640hud13.spr", 0, 0.0f);
	g_hud14_spr = spriteframe("sprites/640hud14.spr", 0, 0.0f);
	g_hud15_spr = spriteframe("sprites/640hud15.spr", 0, 0.0f);
	g_hud16_spr = spriteframe("sprites/640hud16.spr", 0, 0.0f);

	precache_model("sprites/bottom.spr");
	precache_model("sprites/bottom_left.spr");
	precache_model("sprites/bottom_right.spr");
	precache_model("sprites/left.spr");
	precache_model("sprites/radar640.spr");
	precache_model("sprites/right.spr");
	precache_model("sprites/sniper_scope.spr");
	precache_model("sprites/top.spr");
	precache_model("sprites/top_left.spr");
	precache_model("sprites/top_right.spr");
}

/* seperator for mainly ammo */
void
HUD_DrawSeperator(vector pos)
{
	drawsubpic(pos,
		[2,24],
		g_hud7_spr,
		[240/256, 0],
		[2/256, 24/256],
		g_hud_color,
		HUD_ALPHA,
		DRAWFLAG_ADDITIVE
	);
}

/* handle single/multiple digits */
void
HUD_DrawNumber(int iNumber, vector vecPos, float fAlpha, vector vColor)
{
	drawsubpic(vecPos,
		[20,25],
		g_hud7_spr,
		[spr_hudnum[iNumber], 0],
		[20/256, 25/256],
		vColor,
		fAlpha,
		DRAWFLAG_ADDITIVE
	);
}

void
HUD_DrawNums(float fNumber, vector vecPos, float fAlpha, vector vColor)
{
	int i = fNumber;
	if (i > 0) {
		while (i > 0) {
			HUD_DrawNumber((float)i % 10, vecPos, fAlpha, vColor);
			i = i / 10;
			vecPos[0] -= 20;
		}
	} else {
		HUD_DrawNumber(0, vecPos, fAlpha, vColor);
	}
}

/* timer */
void
HUD_DrawTimer(int spectator)
{
	int iMinutes, iSeconds, iTens, iUnits;
	vector time_pos;
	
	if (spectator) {
		time_pos = g_hudmins + [(g_hudres[0] / 2) - 62, 16];
	} else {
		time_pos = g_hudmins + [(g_hudres[0] / 2) - 62, g_hudres[1] - 42];
	}

	if (getstatf(STAT_GAMETIME) == -1) {
		return;
	}

	iMinutes = getstatf(STAT_GAMETIME) / 60;
	iSeconds = getstatf(STAT_GAMETIME) - 60 * iMinutes;
	iTens = iSeconds / 10;
	iUnits = iSeconds - 10 * iTens;

	/* Flashing red numbers */
	if ((iMinutes == 0) &&  (iTens <= 1)) {
		float fAlpha;
		
		/* 0:00 is fully red */
		if ((iTens == 0) && (iUnits == 0)) {
			fAlpha = 1;
		} else {
			fAlpha = fabs(sin(time * 20));
		}
		
		HUD_DrawNumber(iMinutes, time_pos + [48,0], fAlpha, [1,0,0]);
		HUD_DrawNumber(iTens, time_pos + [75,0], fAlpha, [1,0,0]);
		HUD_DrawNumber(iUnits, time_pos + [99,0],fAlpha, [1,0,0]);
		HUD_DrawNumber(iMinutes, time_pos + [48,0], 1 - fAlpha, g_hud_color);
		HUD_DrawNumber(iTens, time_pos + [75,0], 1 - fAlpha, g_hud_color);
		HUD_DrawNumber(iUnits, time_pos + [99,0],1 - fAlpha, g_hud_color);
		
		/* : symbol */
		drawsubpic(time_pos + [70,6], [3,3], g_hud7_spr, [0.9375, 0], [0.01171875, 0.01171875], [1,0,0], fAlpha, DRAWFLAG_ADDITIVE);
		drawsubpic(time_pos + [70,16], [3,3], g_hud7_spr, [0.9375, 0], [0.01171875, 0.01171875], [1,0,0], fAlpha, DRAWFLAG_ADDITIVE);
		drawsubpic(time_pos + [70,6], [3,3], g_hud7_spr, [0.9375, 0], [0.01171875, 0.01171875], g_hud_color, 1 - fAlpha, DRAWFLAG_ADDITIVE);
		drawsubpic(time_pos + [70,16], [3,3], g_hud7_spr, [0.9375, 0], [0.01171875, 0.01171875], g_hud_color, 1 - fAlpha, DRAWFLAG_ADDITIVE);
		
		/* clock */
		drawsubpic(time_pos, [24,25], g_hud7_spr, [NUMSIZE_X * 6, NUMSIZE_Y * 3], [NUMSIZE_X, NUMSIZE_Y], [1,0,0], fAlpha, DRAWFLAG_ADDITIVE);
		drawsubpic(time_pos, [24,25], g_hud7_spr, [NUMSIZE_X * 6, NUMSIZE_Y * 3], [NUMSIZE_X, NUMSIZE_Y], g_hud_color, 1 - fAlpha, DRAWFLAG_ADDITIVE);
	} else {
		if (iUnits != pSeat->m_iTimeUnitsOld) {
			pSeat->m_flTimeAlpha = 1.0;
		}
	
		if (pSeat->m_flTimeAlpha >= HUD_ALPHA) {
			pSeat->m_flTimeAlpha -= clframetime * 0.5;
		} else {
			pSeat->m_flTimeAlpha = HUD_ALPHA;
		}
		HUD_DrawNumber(iMinutes, time_pos + [48,0], pSeat->m_flTimeAlpha, g_hud_color);
		HUD_DrawNumber(iTens, time_pos + [75,0], pSeat->m_flTimeAlpha, g_hud_color);
		HUD_DrawNumber(iUnits, time_pos + [95,0], pSeat->m_flTimeAlpha, g_hud_color);
		
		drawsubpic(time_pos + [70,6], [3,3], g_hud7_spr, [0.9375, 0], [0.01171875, 0.01171875], g_hud_color, pSeat->m_flTimeAlpha, DRAWFLAG_ADDITIVE);
		drawsubpic(time_pos + [70,16], [3,3], g_hud7_spr, [0.9375, 0], [0.01171875, 0.01171875], g_hud_color, pSeat->m_flTimeAlpha, DRAWFLAG_ADDITIVE);
		
		drawsubpic(time_pos, [24,25], g_hud7_spr, [NUMSIZE_X * 6, NUMSIZE_Y * 3], [NUMSIZE_X, NUMSIZE_Y], g_hud_color, pSeat->m_flTimeAlpha, DRAWFLAG_ADDITIVE);
		pSeat->m_iTimeUnitsOld = iUnits;
	}
}

void
HUD_DrawMoney(void)
{
	vector money_pos;
	float endalpha;

	money_pos = g_hudmins + [g_hudres[0] - 160, g_hudres[1] - 72];

	/* if the money differs from last frame, paint it appropriately */
	if (getstati(STAT_MONEY) > pSeat->m_iMoneyOld) {
		/* effect already in progress from something else, go add on top of it! */
		if (pSeat->m_flMoneyAlpha > 0) {
			pSeat->m_iMoneyDelta += (pSeat->m_iMoneyOld - getstati(STAT_MONEY));
		} else {
			pSeat->m_iMoneyDelta = pSeat->m_iMoneyOld - getstati(STAT_MONEY);
		}
		/* make it green for a short time */
		pSeat->m_vecMoneyColor = [0,1,0];
		pSeat->m_flMoneyAlpha = 1.0;
	} else if (getstati(STAT_MONEY) < pSeat->m_iMoneyOld) {
		/* same one as above */
		if (pSeat->m_flMoneyAlpha > 0) {
			pSeat->m_iMoneyDelta += (pSeat->m_iMoneyOld - getstati(STAT_MONEY));
		} else {
			pSeat->m_iMoneyDelta = pSeat->m_iMoneyOld - getstati(STAT_MONEY);
		}
		/* make it red */
		pSeat->m_vecMoneyColor = [1,0,0];
		pSeat->m_flMoneyAlpha = 1.0;
		pSeat->m_iMoneyDelta = pSeat->m_iMoneyOld - getstati(STAT_MONEY);
	}

	/* maximum alpha is variable. */
	endalpha = pSeat->m_flMoneyAlpha * HUD_ALPHA;

	/* dollar sign */
	drawsubpic(
		money_pos,
		[18,26],
		g_hud7_spr,
		[192/256, 24/256],
		[18/256, 26/256],
		g_hud_color,
		HUD_ALPHA - endalpha,
		DRAWFLAG_ADDITIVE
	);

	/* if the alpha/color effect is active, draw the money twice in their
	 * varying alphas/colors  */
	if (pSeat->m_flMoneyAlpha > 0) {
		/* red/green dollar sign */
		drawsubpic(
			money_pos,
			[18,26],
			g_hud7_spr,
			[192/256, 24/256],
			[18/256, 26/256],
			pSeat->m_vecMoneyColor,
			endalpha,
			DRAWFLAG_ADDITIVE
		);

		/* draw the +/- symbols depending on whether
		 * or not we made or lost money */
		if (pSeat->m_iMoneyDelta < 0) {
			drawsubpic(money_pos + [0,-32], [18,23], g_hud7_spr, [0.8671875, 0.09765625], [0.0703125, 0.08984375], pSeat->m_vecMoneyColor, endalpha, DRAWFLAG_ADDITIVE);
		} else {
			drawsubpic(money_pos + [0,-32], [13,23], g_hud7_spr, [0.8203125, 0.09765625], [0.05078125, 0.08984375], pSeat->m_vecMoneyColor, endalpha, DRAWFLAG_ADDITIVE);
		}

		/* shift the numbers for reverse drawing */
		money_pos[0] += (24 * 5);

		/* draw the red/green overlay numbers on top of ours */
		HUD_DrawNums(getstati(STAT_MONEY), money_pos, endalpha, pSeat->m_vecMoneyColor);

		/* draw above how much money we've lost/gotten from all this */
		HUD_DrawNums(fabs(pSeat->m_iMoneyDelta), money_pos + [0,-32], endalpha, pSeat->m_vecMoneyColor);
	} else {
		money_pos[0] += (24 * 5);
	}

	/* regular number */
	HUD_DrawNums(
		getstati(STAT_MONEY),
		money_pos,
		HUD_ALPHA - endalpha,
		g_hud_color
	);

	pSeat->m_iMoneyOld = getstati(STAT_MONEY);
	pSeat->m_flMoneyAlpha = max(0, pSeat->m_flMoneyAlpha - (clframetime * 0.5));
}

/* health */
void
HUD_DrawHealth(void)
{
	vector pos;
	player pl = (player)pSeat->m_ePlayer;

	if (pl.health != pSeat->m_iHealthOld) {
		pSeat->m_flHealthAlpha = 1.0;
	}

	if (pSeat->m_flHealthAlpha >= HUD_ALPHA) {
		pSeat->m_flHealthAlpha -= clframetime * 0.5;
	} else {
		pSeat->m_flHealthAlpha = HUD_ALPHA;
	}

	pos = g_hudmins + [88, g_hudres[1] - 42];
	if (pl.health > 25) {
		drawsubpic(
			pos + [-72,1],
			[24,24],
			g_hud7_spr,
			[spr_health[0], spr_health[1]],
			[spr_health[2], spr_health[3]],
			g_hud_color,
			pSeat->m_flHealthAlpha,
			DRAWFLAG_ADDITIVE
		);
		HUD_DrawNums(pl.health, pos, pSeat->m_flHealthAlpha, g_hud_color);
	} else {
		drawsubpic(
			pos + [-72,1],
			[24,24],
			g_hud7_spr,
			[spr_health[0], spr_health[1]],
			[spr_health[2], spr_health[3]],
			[1,0,0],
			pSeat->m_flHealthAlpha,
			DRAWFLAG_ADDITIVE
		);
		HUD_DrawNums(pl.health, pos, pSeat->m_flHealthAlpha, [1,0,0]);
	}

	pSeat->m_iHealthOld = pl.health;
}

/* armor/suit charge */
void
HUD_DrawArmor(void)
{
	vector pos;
	player pl = (player)pSeat->m_ePlayer;

	pos = g_hudmins + [198, g_hudres[1] - 42];
	
	if (pl.armor != pSeat->m_iArmorOld) {
		pSeat->m_flArmorAlpha = 1.0;
	}

	if (pSeat->m_flArmorAlpha >= HUD_ALPHA) {
		pSeat->m_flArmorAlpha -= clframetime * 0.5;
	} else {
		pSeat->m_flArmorAlpha = HUD_ALPHA;
	}

	if (pl.g_items & ITEM_HELMET) {
		drawsubpic(
			pos + [-80,1],
			[24,24],
			g_hud7_spr,
			[spr_suit4[0], spr_suit4[1]],
			[spr_suit4[2], spr_suit4[3]],
			g_hud_color,
			pSeat->m_flArmorAlpha,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos + [-80,1],
			[24,24],
			g_hud7_spr,
			[spr_suit2[0], spr_suit2[1]],
			[spr_suit2[2], spr_suit2[3]],
			g_hud_color,
			pSeat->m_flArmorAlpha,
			DRAWFLAG_ADDITIVE
		);
	}

	if (pl.armor > 0) {
		if (pl.g_items & ITEM_HELMET) {
			drawsubpic(
				pos + [-80,1],
				[24, 24 * (pl.armor / 100)],
				g_hud7_spr,
				[spr_suit3[0],
				spr_suit3[1]],
				[spr_suit3[2], spr_suit3[3] * (pl.armor / 100)],
				g_hud_color,
				pSeat->m_flArmorAlpha,
				DRAWFLAG_ADDITIVE
			);
		} else {
			drawsubpic(
				pos + [-80,1],
				[24, 24 * (pl.armor / 100)],
				g_hud7_spr,
				[spr_suit1[0],
				spr_suit1[1]],
				[spr_suit1[2], spr_suit1[3] * (pl.armor / 100)],
				g_hud_color,
				pSeat->m_flArmorAlpha,
				DRAWFLAG_ADDITIVE
			);
		}
	}

	HUD_DrawNums(pl.armor, pos, pSeat->m_flArmorAlpha, g_hud_color);
	pSeat->m_iArmorOld = pl.armor;
}

/* magazine/clip ammo */
void
HUD_DrawAmmo1(void)
{
	player pl = (player)pSeat->m_ePlayer;
	vector pos;

	if (pl.a_ammo1 != pSeat->m_iAmmo1Old) {
		pSeat->m_flAmmo1Alpha = 1.0;
		pSeat->m_iAmmo1Old = pl.a_ammo1;
	}

	if (pSeat->m_flAmmo1Alpha >= HUD_ALPHA) {
		pSeat->m_flAmmo1Alpha -= clframetime * 0.5;
	} else {
		pSeat->m_flAmmo1Alpha = HUD_ALPHA;
	}

	pos = g_hudmins + [g_hudres[0] - 152, g_hudres[1] - 42];
	HUD_DrawNums(pl.a_ammo1, pos, pSeat->m_flAmmo1Alpha, g_hud_color);
	HUD_DrawSeperator(pos + [30,0]);
}

/* leftover type ammo */
void
HUD_DrawAmmo2(void)
{
	player pl = (player)pSeat->m_ePlayer;
	vector pos;

	if (pl.a_ammo2 != pSeat->m_iAmmo2Old) {
		pSeat->m_flAmmo2Alpha = 1.0;
		pSeat->m_iAmmo2Old = pl.a_ammo2;
	}

	if (pSeat->m_flAmmo2Alpha >= HUD_ALPHA) {
		pSeat->m_flAmmo2Alpha -= clframetime * 0.5;
	} else {
		pSeat->m_flAmmo2Alpha = HUD_ALPHA;
	}

	pos = g_hudmins + [g_hudres[0] - 72, g_hudres[1] - 42];
	HUD_DrawNums(pl.a_ammo2, pos, pSeat->m_flAmmo2Alpha, g_hud_color);
}

/* special ammo */
void
HUD_DrawAmmo3(void)
{
	player pl = (player)pSeat->m_ePlayer;
	vector pos;

	if (pl.a_ammo3 != pSeat->m_iAmmo3Old) {
		pSeat->m_flAmmo3Alpha = 1.0;
		pSeat->m_iAmmo3Old = pl.a_ammo3;
	}

	if (pSeat->m_flAmmo3Alpha >= HUD_ALPHA) {
		pSeat->m_flAmmo3Alpha -= clframetime * 0.5;
	} else {
		pSeat->m_flAmmo3Alpha = HUD_ALPHA;
	}

	pos = g_hudmins + [g_hudres[0] - 72, g_hudres[1] - 74];
	HUD_DrawNums(pl.a_ammo3, pos, pSeat->m_flAmmo3Alpha, g_hud_color);
}

/* ammo bar */
void
HUD_DrawAmmoBar(vector pos, float val, float max, float a)
{
	if (val <= 0)
		return;

	float perc;
	perc = val / max;
	drawfill(pos + [10,5], [20,4], g_hud_color, a, DRAWFLAG_NORMAL);
	drawfill(pos + [10,5], [20 * perc,4], [0,1,0], a, DRAWFLAG_NORMAL);
}

/* flashlight/torch indicator */
void
HUD_DrawFlashlight(void)
{
	vector pos;
	player pl = (player)pSeat->m_ePlayer;
	pos = g_hudmins + [g_hudres[0] - 48, 16];

	/* both on, draw both sprites at full intensity */
	if (pl.gflags & GF_FLASHLIGHT) {
		drawsubpic(
			pos,
			[32,32],
			g_hud7_spr,
			[spr_flash1[0], spr_flash1[1]],
			[spr_flash1[2], spr_flash1[3]],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);

		drawsubpic(
			pos,
			[48,32],
			g_hud7_spr,
			[spr_flash2[0], spr_flash2[1]],
			[spr_flash2[2], spr_flash2[3]],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[32,32],
			g_hud7_spr,
			[spr_flash1[0], spr_flash1[1]],
			[spr_flash1[2], spr_flash1[3]],
			g_hud_color,
			HUD_ALPHA,
			DRAWFLAG_ADDITIVE
		);
	}
}

void
HUD_DrawZones(void)
{
	int zc = 0;
	vector pos = [0,0,0];
	player pl = (player)pSeat->m_ePlayer;

	if (pl.gflags & GF_BUYZONE) {
		zc++;
	}
	if (pl.gflags & GF_BOMBZONE) {
		zc++;
	}
	if (pl.gflags & GF_RESCUEZONE) {
		zc++;
	}
	if (pl.g_items & ITEM_DEFUSAL) {
		zc++;
	}

	pos = g_hudmins + [16, (g_hudres[1] / 2) - (zc * 16)];

	if (pl.gflags & GF_BUYZONE) {
		drawsubpic(
			pos,
			[32,32],
			g_hud7_spr,
			[96/256,148/256],
			[32/256,32/256],
			[0,1,0],
			1.0f,
			DRAWFLAG_ADDITIVE
		);
		pos[1] += 32;
	}
	if (pl.gflags & GF_BOMBZONE) {
		drawsubpic(
			pos,
			[32,32],
			g_hud7_spr,
			[0/256,148/256],
			[32/256,32/256],
			[0,1,0],
			1.0f,
			DRAWFLAG_ADDITIVE
		);
		pos[1] += 32;
	}
	if (pl.gflags & GF_RESCUEZONE) {
		drawsubpic(
			pos,
			[32,32],
			g_hud7_spr,
			[64/256,148/256],
			[32/256,32/256],
			[0,1,0],
			1.0f,
			DRAWFLAG_ADDITIVE
		);
		pos[1] += 32;
	}
	if (pl.g_items & ITEM_DEFUSAL) {
		drawsubpic(
			pos,
			[32,32],
			g_hud7_spr,
			[32/256,148/256],
			[32/256,32/256],
			[0,1,0],
			1.0f,
			DRAWFLAG_ADDITIVE
		);
		pos[1] += 32;
	}
}

/* defusal etc. progress bar */
void
HUD_DrawProgress(void)
{
	vector vSize = [540,16];
	vector vMainPos;
	float progress;

	progress = getstatf(STAT_PROGRESS) / 10.0f;

	if (progress > 0) {
		vMainPos = g_hudmins;
		vMainPos[0] += (g_hudres[0] / 2) - (vSize[0] / 2);
		vMainPos[1] += (g_hudres[1] / 2) - (vSize[1] / 2);

		vector vBar = vSize;
		vBar[0] = 538 * progress;
		vBar[1] = 14;
		drawfill(vMainPos + [1,1], vBar, g_hud_color, 1.0, DRAWFLAG_ADDITIVE);
		drawfill(vMainPos, [vSize[0], 1], g_hud_color, 1.0f); // Top
		drawfill([vMainPos[0], vMainPos[1] + vSize[1]], [vSize[0], 1], g_hud_color, 1.0f); // Bottom
		drawfill(vMainPos, [1, vSize[1]], g_hud_color, 1.0f); // Left
		drawfill([vMainPos[0] + vSize[0], vMainPos[1]], [1, vSize[1] + 1], g_hud_color, 1.0f); // Right
	}
}

/* weapon/ammo pickup notifications */
void
HUD_DrawNotify(void)
{
	vector pos;
	
	if (pSeat->m_flPickupAlpha <= 0.0f) {
		return;
	}

	pos = g_hudmins + [g_hudres[0] - 192, g_hudres[1] - 128];
	Weapons_HUDPic(pSeat->m_iPickupWeapon, 1, pos, pSeat->m_flPickupAlpha);
	pSeat->m_flPickupAlpha -= clframetime;
}

void
HUD_WeaponPickupNotify(int w)
{
	pSeat->m_iPickupWeapon = w;
	pSeat->m_flPickupAlpha = 1.0f;
}

/* main entry */
void
HUD_Draw(void)
{
	player pl = (player)pSeat->m_ePlayer;

	g_hud_color = autocvar_con_color * (1 / 255);

	/* little point in not drawing these, even if you don't have a suit */
	Weapons_DrawCrosshair();
	HUD_DrawWeaponSelect();
	Obituary_Draw();

	Textmenu_Draw();

	HUD_DrawMoney();
	HUD_DrawTimer(0);

	if (!(pl.g_items & ITEM_SUIT)) {
		return;
	}

	HUD_DrawNotify();
	HUD_DrawHealth();
	HUD_DrawArmor();
	HUD_DrawZones();
	HUD_DrawProgress();
	HUD_DrawFlashlight();
	Damage_Draw();
}

/* specatator main entry */
void
HUD_DrawSpectator(void)
{
	// FIXME
	Textmenu_Draw();
	Obituary_Draw();

	HUD_DrawTimer(1);
}
