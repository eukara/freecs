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

/* values courtesy of https://wiki.alliedmods.net/Cs_weapons_information */
int g_cstrikeWeaponPrice[] =
{
	0,	/* WEAPON_NONE */
	1700,	/* WEAPON_M3 */
	3000,	/* WEAPON_XM1014 */
	1500,	/* WEAPON_MP5 */
	2350,	/* WEAPON_P90 */
	1700,	/* WEAPON_UMP45 */
	1400,	/* WEAPON_MAC10 */
	1250,	/* WEAPON_TMP */
	2500,	/* WEAPON_AK47 */
	3500,	/* WEAPON_SG552 */
	3100,	/* WEAPON_M4A1 */
	3500,	/* WEAPON_AUG */
	2750,	/* WEAPON_SCOUT */
	4750,	/* WEAPON_AWP */
	5000,	/* WEAPON_G3SG1 */
	4200,	/* WEAPON_SG550 */
	5750,	/* WEAPON_PARA */
	500,	/* WEAPON_USP45 */
	400,	/* WEAPON_GLOCK18 */
	650,	/* WEAPON_DEAGLE */
	600,	/* WEAPON_P228 */
	800,	/* WEAPON_ELITES */
	750,	/* WEAPON_FIVESEVEN */
	0,	/* WEAPON_KNIFE */
	300,	/* WEAPON_HEGRENADE */
	200,	/* WEAPON_FLASHBANG */
	300,	/* WEAPON_SMOKEGRENADE */
	0	/* WEAPON_C4BOMB */
};

void
CSEv_BuyWeapon_f(float fWeapon)
{
	CSGameRules rules = (CSGameRules)g_grMode;

	int iWeapon;
	player pl = (player)self;
	iWeapon = (int)fWeapon;

	if (rules.BuyingPossible(pl) == FALSE) {
		return;
	}

	if (pl.team == TEAM_T) {
		if (iWeapon == WEAPON_M4A1) { return; }
		if (iWeapon == WEAPON_AUG) { return; }
		if (iWeapon == WEAPON_SG550) { return; }
		if (iWeapon == WEAPON_FIVESEVEN) { return; }
		if (iWeapon == WEAPON_TMP) { return; }
	} else if (pl.team == TEAM_CT) {
		if (iWeapon == WEAPON_AK47) { return; }
		if (iWeapon == WEAPON_SG552) { return; }
		if (iWeapon == WEAPON_G3SG1) { return; }
		if (iWeapon == WEAPON_ELITES) { return; }
		if (iWeapon == WEAPON_MAC10) { return; }
	}

	if (Weapons_IsPresent(pl, iWeapon))
		return;

	if ((pl.money - g_cstrikeWeaponPrice[iWeapon]) >= 0) {
		/* let's check if we've got a limit */
		int maxit;
		maxit = rules.MaxItemPerSlot(g_weapons[iWeapon].slot);
		if (maxit > 0) {
			int wantslot = g_weapons[iWeapon].slot;
			int c = 0;
			for (int i = 0; i < g_weapons.length; i++) {
				if (pl.g_items & g_weapons[i].id && g_weapons[i].slot == wantslot) {
					c++;

					/* we're over the slot limit. */
					if (c >= maxit) {
						pl.activeweapon = i;
						Weapon_DropCurrentWeapon(pl);
					}
				}
			}
		}

		Weapons_AddItem(pl, iWeapon, -1);
		Money_AddMoney(pl, -g_cstrikeWeaponPrice[iWeapon]);
		Sound_Play(pl, CHAN_ITEM, "buy.weapon");
	} else {
		//centerprint(pl, "You have insufficient funds!");
	}
} 

int g_cstrikeUtilPrice[] =
{
	650,	/* Kevlar Vest */
	1000,	/* Kevlar Vest & Helmet */
	200,	/* Flashbang */
	300,	/* HE Grenade */
	300,	/* Smoke Grenade */
	200,	/* Defuse Kit */
	1250	/* NightVision Goggles */
};

void
CSEv_BuyEquipment_f(float fUtil)
{
	CSGameRules rules = (CSGameRules)g_grMode;

	int iUtil;
	player pl = (player)self;
	iUtil = (int)fUtil;

	if (rules.BuyingPossible(pl) == FALSE) {
		return;
	}

	if (pl.team == TEAM_T) {
		if (iUtil == 5) { return; }
	}

	if ((pl.money - g_cstrikeUtilPrice[iUtil]) >= 0) {
		switch (iUtil) {
		case 0:
			if (pl.armor >= 100)
				return;

			pl.armor = 100;
			Sound_Play(pl, CHAN_ITEM, "buy.kevlar");
			break;
		case 1:
			if (pl.g_items & ITEM_HELMET && pl.armor >= 0)
				return;

			pl.armor = 100;
			pl.g_items |= ITEM_HELMET;
			Sound_Play(pl, CHAN_ITEM, "buy.kevlar");
			break;
		case 2:
			if (Weapons_IsPresent(pl, WEAPON_FLASHBANG)) {
				if (pl.ammo_fbgrenade >= AMMO_MAX_FLASHBANG)
					return;
				else
					pl.ammo_fbgrenade++;
			} else
				Weapons_AddItem(pl, WEAPON_FLASHBANG, -1);

			Sound_Play(pl, CHAN_ITEM, "buy.weapon");
			break;
		case 3:
			if (Weapons_IsPresent(pl, WEAPON_HEGRENADE)) {
				if (pl.ammo_hegrenade >= AMMO_MAX_HENADE)
					return;
				else
					pl.ammo_hegrenade++;
			} else
				Weapons_AddItem(pl, WEAPON_HEGRENADE, -1);

			Sound_Play(pl, CHAN_ITEM, "buy.weapon");
			break;
		case 4:
			if (Weapons_IsPresent(pl, WEAPON_SMOKEGRENADE)) {
				if (pl.ammo_smokegrenade >= AMMO_MAX_SMOKE)
					return;
				else
					pl.ammo_smokegrenade++;
			} else
				Weapons_AddItem(pl, WEAPON_SMOKEGRENADE, -1);

			Sound_Play(pl, CHAN_ITEM, "buy.weapon");
			break;
		case 5:
			if (pl.g_items & ITEM_DEFUSAL)
				return;

			pl.g_items |= ITEM_DEFUSAL;
			Sound_Play(pl, CHAN_ITEM, "buy.weapon");
			break;
		case 6:
			if (pl.g_items & ITEM_NIGHTVISION)
				return;

			pl.g_items |= ITEM_NIGHTVISION;
			Sound_Play(pl, CHAN_ITEM, "buy.weapon");
			break;
		}
		Money_AddMoney(pl, -g_cstrikeUtilPrice[iUtil]);
	} else {
		//centerprint(pl, "You have insufficient funds!");
	}
} 
