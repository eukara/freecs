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

/*QUAKED weapon_mac10 (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_mac10.mdl"

COUNTER-STRIKE (1999) ENTITY

Ingram MAC-10 Weapon

- Buy Menu -
Price: $1400

*/

enum
{
	MAC10_IDLE,
	MAC10_RELOAD,
	MAC10_DRAW,
	MAC10_SHOOT1,
	MAC10_SHOOT2,
	MAC10_SHOOT3
};

void
w_mac10_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_mac10.fire");
	precache_model("models/w_mac10.mdl");
#else
	precache_model("models/v_mac10.mdl");
	precache_model("models/p_mac10.mdl");
#endif
}

void
w_mac10_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.mac10_mag, pl.ammo_45acp, -1);
}

string
w_mac10_wmodel(void)
{
	return "models/w_mac10.mdl";
}

string
w_mac10_pmodel(void)
{
	return "models/p_mac10.mdl";
}

string
w_mac10_deathmsg(void)
{
	return "";
}

int
w_mac10_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (new) {
		if (startammo == -1)
			pl.mac10_mag = 30;
		else
			pl.mac10_mag = startammo;
	} else {
		if (pl.ammo_45acp < AMMO_MAX_45ACP) {
			pl.ammo_45acp = bound(0, pl.ammo_45acp + 30, AMMO_MAX_45ACP);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_mac10_draw(void)
{
	player pl = (player)self;
	Weapons_SetModel("models/v_mac10.mdl");
	Weapons_ViewAnimation(MAC10_DRAW);

#ifdef CLIENT
	pl.cs_cross_mindist = 9;
	pl.cs_cross_deltadist = 3;
#endif
}

void
w_mac10_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}
	if (!pl.mac10_mag) {
		return;
	}

	Cstrike_ShotMultiplierAdd(pl, 1);
	float accuracy = Cstrike_CalculateAccuracy(pl, 200);
	pl.mac10_mag--;

#ifdef CLIENT
	View_SetMuzzleflash(MUZZLE_RIFLE);

	int r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(MAC10_SHOOT1);
		break;
	case 1:
		Weapons_ViewAnimation(MAC10_SHOOT2);
		break;
	default:
		Weapons_ViewAnimation(MAC10_SHOOT3);
		break;
	}
#else
	TraceAttack_SetPenetrationPower(0);
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 29, [accuracy,accuracy], WEAPON_MAC10);

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT_MP5, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CROUCH_SHOOT_MP5, 0.45f);

	Sound_Play(pl, CHAN_WEAPON, "weapon_mac10.fire");
#endif

	pl.w_attack_next = 0.07f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_mac10_reload(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}
	if (pl.mac10_mag >= 30) {
		return;
	}
	if (!pl.ammo_45acp) {
		return;
	}

#ifdef CLIENT
	Weapons_ViewAnimation(MAC10_RELOAD);
#else
	Weapons_ReloadWeapon(pl, player::mac10_mag, player::ammo_45acp, 30);
	Weapons_UpdateAmmo(pl, pl.mac10_mag, pl.ammo_45acp, -1);
#endif

	pl.w_attack_next = 3.2f;
	pl.w_idle_next = pl.w_attack_next;
}

float
w_mac10_aimanim(void)
{
	return w_deagle_aimanim();
}

void
w_mac10_hud(void)
{
#ifdef CLIENT
	Cstrike_DrawCrosshair();
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [96/256,72/256], [24/256, 24/256], g_hud_color, pSeat->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_mac10_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	player pl = (player)self;
	vector hud_col;

	if (pl.mac10_mag == 0 && pl.ammo_45acp == 0)
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_45acp, AMMO_MAX_45ACP, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud15_spr,
			[0,0],
			[170/256,45/256],
			hud_col,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			g_hud14_spr,
			[0,0],
			[170/256,45/256],
			hud_col,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_mac10 =
{
	.name		= "mac10",
	.id		= ITEM_MAC10,
	.slot		= 0,
	.slot_pos	= 5,
	.allow_drop	= TRUE,
	.draw		= w_mac10_draw,
	.holster	= __NULL__,
	.primary	= w_mac10_primary,
	.secondary	= __NULL__,
	.reload		= w_mac10_reload,
	.release	= w_cstrike_weaponrelease,
	.crosshair	= w_mac10_hud,
	.precache	= w_mac10_precache,
	.pickup		= w_mac10_pickup,
	.updateammo	= w_mac10_updateammo,
	.wmodel		= w_mac10_wmodel,
	.pmodel		= w_mac10_pmodel,
	.deathmsg	= w_mac10_deathmsg,
	.aimanim	= w_mac10_aimanim,
	.hudpic		= w_mac10_hudpic
};

#ifdef SERVER
void
weapon_mac10(void)
{
	Weapons_InitItem(WEAPON_MAC10);
}
#endif
