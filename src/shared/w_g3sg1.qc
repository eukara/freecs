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

/*QUAKED weapon_g3sg1 (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_g3sg1.mdl"

COUNTER-STRIKE (1999) ENTITY

Heckler & Koch G3/SG-1 Weapon

- Buy Menu -
Price: $5000

*/

enum
{
	G3SG1_IDLE,
	G3SG1_SHOOT1,
	G3SG1_SHOOT2,
	G3SG1_RELOAD,
	G3SG1_DRAW
};

void
w_g3sg1_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_g3sg1.fire");
	precache_model("models/w_g3sg1.mdl");
#else
	precache_model("models/v_g3sg1.mdl");
	precache_model("models/p_g3sg1.mdl");
#endif
}

void
w_g3sg1_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.g3sg1_mag, pl.ammo_762mm, -1);
}

string
w_g3sg1_wmodel(void)
{
	return "models/w_g3sg1.mdl";
}

string
w_g3sg1_pmodel(void)
{
	return "models/p_g3sg1.mdl";
}

string
w_g3sg1_deathmsg(void)
{
	return "";
}

int
w_g3sg1_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (new) {
		if (startammo == -1)
			pl.g3sg1_mag = 20;
		else
			pl.g3sg1_mag = startammo;
	} else {
		if (pl.ammo_762mm < AMMO_MAX_762MM) {
			pl.ammo_762mm = bound(0, pl.ammo_762mm + 20, AMMO_MAX_762MM);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_g3sg1_draw(void)
{
	player pl = (player)self;
	Weapons_SetModel("models/v_g3sg1.mdl");
	Weapons_ViewAnimation(G3SG1_DRAW);

#ifdef CLIENT
	pl.cs_cross_mindist = 6;
	pl.cs_cross_deltadist = 4;
#endif
}

void
w_g3sg1_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}
	if (!pl.g3sg1_mag) {
		return;
	}

	Cstrike_ShotMultiplierAdd(pl, 1);
	float accuracy = Cstrike_CalculateAccuracy(pl, 200);
	pl.g3sg1_mag--;

#ifdef CLIENT
	View_SetMuzzleflash(MUZZLE_RIFLE);

	int r = (float)input_sequence % 2;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(SCOUT_SHOOT1);
		break;
	default:
		Weapons_ViewAnimation(SCOUT_SHOOT2);
		break;
	}
#else
	TraceAttack_SetPenetrationPower(2);
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 80, [accuracy,accuracy], WEAPON_G3SG1);

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT_RIFLE, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CROUCH_SHOOT_RIFLE, 0.45f);

	Sound_Play(pl, CHAN_WEAPON, "weapon_g3sg1.fire");
#endif

	pl.w_attack_next = 0.25f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_g3sg1_secondary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next) {
		return;
	}
	/* Simple toggle of fovs */
	if (pl.viewzoom == 1.0f) {
		pl.viewzoom = 0.45f;
	} else if (pl.viewzoom == 0.45f) {
		pl.viewzoom = 0.1f;
	} else {
		pl.viewzoom = 1.0f;
	}
	pl.w_attack_next = 0.5f;
}

void
w_g3sg1_reload(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}
	if (pl.g3sg1_mag >= 20) {
		return;
	}
	if (!pl.ammo_762mm) {
		return;
	}

#ifdef CLIENT
	Weapons_ViewAnimation(G3SG1_RELOAD);
#else
	Weapons_ReloadWeapon(pl, player::g3sg1_mag, player::ammo_762mm, 20);
	Weapons_UpdateAmmo(pl, pl.g3sg1_mag, pl.ammo_762mm, -1);
#endif

	pl.w_attack_next = 4.6f;
	pl.w_idle_next = pl.w_attack_next;
}

float
w_g3sg1_aimanim(void)
{
	return w_ak47_aimanim();
}

void
w_g3sg1_hud(void)
{
#ifdef CLIENT
	player pl = (player)self;
	if (pl.viewzoom < 1.0f) {
		Cstrike_DrawScope();
	}
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [72/256,72/256], [24/256, 24/256], g_hud_color, pSeat->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_g3sg1_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	player pl = (player)self;
	vector hud_col;

	if (pl.g3sg1_mag == 0 && pl.ammo_762mm == 0)
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_762mm, AMMO_MAX_762MM, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud5_spr,
			[0,180/256],
			[170/256,45/256],
			hud_col,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			g_hud2_spr,
			[0,180/256],
			[170/256,45/256],
			hud_col,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_g3sg1 =
{
	.name		= "g3sg1",
	.id		= ITEM_G3SG1,
	.slot		= 0,
	.slot_pos	= 13,
	.allow_drop	= TRUE,
	.draw		= w_g3sg1_draw,
	.holster	= __NULL__,
	.primary	= w_g3sg1_primary,
	.secondary	= w_g3sg1_secondary,
	.reload		= w_g3sg1_reload,
	.release	= w_cstrike_weaponrelease,
	.crosshair	= w_g3sg1_hud,
	.precache	= w_g3sg1_precache,
	.pickup		= w_g3sg1_pickup,
	.updateammo	= w_g3sg1_updateammo,
	.wmodel		= w_g3sg1_wmodel,
	.pmodel		= w_g3sg1_pmodel,
	.deathmsg	= w_g3sg1_deathmsg,
	.aimanim	= w_g3sg1_aimanim,
	.hudpic		= w_g3sg1_hudpic
};

#ifdef SERVER
void
weapon_g3sg1(void)
{
	Weapons_InitItem(WEAPON_G3SG1);
}
#endif
