/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

weapon_t w_null = {};
weapon_t g_weapons[] = {
	w_null,
	w_m3,
	w_xm1014,
	w_mp5,
	w_p90,
	w_ump45,
	w_mac10,
	w_tmp,
	w_ak47,
	w_sg552,
	w_m4a1,
	w_aug,
	w_scout,
	w_awp,
	w_g3sg1,
	w_sg550,
	w_para,
	w_usp45,
	w_glock18,
	w_deagle,
	w_p228,
	w_elites,
	w_fiveseven,
	w_knife,
	w_hegrenade,
	w_flashbang,
	w_smokegrenade,
	w_c4bomb
};

int
Cstrike_WeaponToDropUponDeath(player pl)
{
	int best_weapon = WEAPON_KNIFE; /* this will never drop, so an okay default */

	for (int i = 0; i < g_weapons.length; i++) {
		if (pl.g_items & g_weapons[i].id) {
			if (g_weapons[i].slot == 0)
				return i; /* immediately choose this primary weapon */

			best_weapon = i;
		}
	}

	return best_weapon;
}