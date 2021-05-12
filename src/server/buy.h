/*
 * Copyright (c) 2016-2021 Marco Hladik <marco@icculus.org>
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

void CSEv_BuyWeapon_f(float fWeapon);
void CSEv_BuyEquipment_f(float fWeapon);
void CSEv_AmmoBuyPrimary(void);
void CSEv_AmmoBuySecondary(void);
