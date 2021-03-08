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

/* Ammo information courtesy of https://wiki.alliedmods.net/CS_weapons_information */

enum
{
	CALIBER_NONE,
	CALIBER_50AE,
	CALIBER_762MM,
	CALIBER_556MM,
	CALIBER_556MMBOX,
	CALIBER_338MAG,
	CALIBER_9MM,
	CALIBER_BUCKSHOT,
	CALIBER_45ACP,
	CALIBER_357SIG,
	CALIBER_57MM
};

typedef struct
{
	int a_size;
	int a_max;
	int price;
} ammoinfo_t;

ammoinfo_t cs_ammoinfo[11] = {
	/* CALIBER_NONE */
	{
		.a_size = 0,
		.a_max = 0,
		.price = 0
	},
	/* CALIBER_50AE */
	{
		.a_size = 7,
		.a_max = 35,
		.price = 40
	},
	/* CALIBER_762MM */
	{
		.a_size = 30,
		.a_max = 90,
		.price = 80
	},
	/* CALIBER_556MM */
	{
		.a_size = 30,
		.a_max = 90,
		.price = 60
	},
	/* CALIBER_556MMBOX */
	{
		.a_size = 30,
		.a_max = 200,
		.price = 60
	},
	/* CALIBER_338MAG */
	{
		.a_size = 10,
		.a_max = 30,
		.price = 125
	},
	/* CALIBER_9MM */
	{
		.a_size = 30,
		.a_max = 150,
		.price = 20
	},
	/* CALIBER_BUCKSHOT */
	{
		.a_size = 8,
		.a_max = 32,
		.price = 65
	},
	/* CALIBER_45ACP */
	{
		.a_size = 12,
		.a_max = 100,
		.price = 25
	},
	/* CALIBER_357SIG */
	{
		.a_size = 13,
		.a_max = 52,
		.price = 50
	},
	/* CALIBER_57MM */
	{
		.a_size = 50,
		.a_max = 100,
		.price = 50
	}
};

int
Ammo_BuyCaliber(player pl, int cal, int free)
{
	int *ptr_ammo = __NULL__;
	int rv = 0;

	while (pl.money - cs_ammoinfo[cal].price > 0) {
		switch (cal) {
		case CALIBER_50AE:
			ptr_ammo = &pl.ammo_50ae;
			break;
		case CALIBER_762MM:
			ptr_ammo = &pl.ammo_762mm;
			break;
		case CALIBER_556MM:
			ptr_ammo = &pl.ammo_556mm;
			break;
		case CALIBER_556MMBOX:
			ptr_ammo = &pl.ammo_556mmbox;
			break;
		case CALIBER_338MAG:
			ptr_ammo = &pl.ammo_338mag;
			break;
		case CALIBER_9MM:
			ptr_ammo = &pl.ammo_9mm;
			break;
		case CALIBER_BUCKSHOT:
			ptr_ammo = &pl.ammo_buckshot;
			break;
		case CALIBER_45ACP:
			ptr_ammo = &pl.ammo_45acp;
			break;
		case CALIBER_357SIG:
			ptr_ammo = &pl.ammo_357sig;
			break;
		case CALIBER_57MM:
			ptr_ammo = &pl.ammo_57mm;
			break;
		default:
			error("Ammo_BuyCaliber: Impossible caliber definition.");
		}

		if (*ptr_ammo >= cs_ammoinfo[cal].a_max) {
			break;
		}

		*ptr_ammo += cs_ammoinfo[cal].a_size;

		/* clamp */
		if (*ptr_ammo >= cs_ammoinfo[cal].a_max) {
			*ptr_ammo = cs_ammoinfo[cal].a_max;
		}

		if (!free)
			Money_AddMoney(pl, -cs_ammoinfo[cal].price);

		rv = 1;
	}

	return rv;
}

/* We want to loop through all the possible weapons in case the server
 * enabled the ability to pick up more than one primary/secondary weapon */
void
CSEv_AmmoBuySecondary(void)
{
	int cal = 0;
	int ps = 0;
	player pl = (player)self;
	CSGameRules rules = (CSGameRules)g_grMode;

	if (rules.BuyingPossible(pl) == FALSE) {
		return;
	}

	for (int i = 1; i < g_weapons.length; i++) {
		if ((pl.g_items & g_weapons[i].id) && (g_weapons[i].slot == 1)) {
			switch (i) {
			case WEAPON_USP45:
				cal = CALIBER_45ACP;
				break;
			case WEAPON_GLOCK18:
				cal = CALIBER_9MM;
				break;
			case WEAPON_DEAGLE:
				cal = CALIBER_50AE;
				break;
			case WEAPON_P228:
				cal = CALIBER_357SIG;
				break;
			case WEAPON_ELITES:
				cal = CALIBER_9MM;
				break;
			case WEAPON_FIVESEVEN:
				cal = CALIBER_57MM;
				break;
			}

			if (Ammo_BuyCaliber(pl, cal, FALSE) == 1) {
				ps = 1;
			}
		}
	}

	if (ps) {
		Sound_Play(pl, CHAN_ITEM, "buy.ammo");
	}
	Weapons_RefreshAmmo(pl);
}

void
CSEv_AmmoBuyPrimary(void)
{
	int ps = 0;
	int cal = 0;
	player pl = (player)self;
	CSGameRules rules = (CSGameRules)g_grMode;

	if (rules.BuyingPossible(pl) == FALSE) {
		return;
	}

	for (int i = 1; i < g_weapons.length; i++) {
		if ((pl.g_items & g_weapons[i].id) && (g_weapons[i].slot == 0)) {
			switch (i) {
			case WEAPON_M3:
				cal = CALIBER_BUCKSHOT;
				break;
			case WEAPON_XM1014:
				cal = CALIBER_BUCKSHOT;
				break;
			case WEAPON_MP5:
				cal = CALIBER_9MM;
				break;
			case WEAPON_P90:
				cal = CALIBER_57MM;
				break;
			case WEAPON_UMP45:
				cal = CALIBER_45ACP;
				break;
			case WEAPON_MAC10:
				cal = CALIBER_45ACP;
				break;
			case WEAPON_TMP:
				cal = CALIBER_9MM;
				break;
			case WEAPON_AK47:
				cal = CALIBER_762MM;
				break;
			case WEAPON_SG552:
				cal = CALIBER_556MM;
				break;
			case WEAPON_M4A1:
				cal = CALIBER_556MM;
				break;
			case WEAPON_AUG:
				cal = CALIBER_762MM;
				break;
			case WEAPON_SCOUT:
				cal = CALIBER_762MM;
				break;
			case WEAPON_AWP:
				cal = CALIBER_338MAG;
				break;
			case WEAPON_G3SG1:
				cal = CALIBER_762MM;
				break;
			case WEAPON_SG550:
				cal = CALIBER_556MM;
				break;
			case WEAPON_PARA:
				cal = CALIBER_556MMBOX;
				break;
			}

			if (Ammo_BuyCaliber(pl, cal, FALSE) == 1) {
				ps = 1;
			}
		}
	}

	if (ps) {
		Sound_Play(pl, CHAN_ITEM, "buy.ammo");
	}
	Weapons_RefreshAmmo(pl);
}

void
Ammo_AutoFill(player pl)
{
	if (autocvar_fcs_fillweapons == FALSE) {
		return;
	}

	/* TODO: */
}

void
Ammo_Clear(void)
{

}
