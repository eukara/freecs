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

/*QUAKED weapon_aug (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_aug.mdl"

COUNTER-STRIKE (1999) ENTITY

Steyr AUG Weapon

- Buy Menu -
Price: $3500
Counter-Terrorists only weapon

*/

enum
{
	AUG_IDLE,
	AUG_RELOAD,
	AUG_DRAW,
	AUG_SHOOT1,
	AUG_SHOOT2,
	AUG_SHOOT3
};

void
w_aug_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_aug.fire");
	precache_model("models/w_aug.mdl");
#else
	precache_model("models/v_aug.mdl");
	precache_model("models/p_aug.mdl");
#endif
}

void
w_aug_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.aug_mag, pl.ammo_762mm, -1);
}

string
w_aug_wmodel(void)
{
	return "models/w_aug.mdl";
}

string
w_aug_pmodel(void)
{
	return "models/p_aug.mdl";
}

string
w_aug_deathmsg(void)
{
	return "";
}

int
w_aug_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (new) {
		if (startammo == -1)
			pl.aug_mag = 30;
		else
			pl.aug_mag = startammo;
	} else {
		if (pl.ammo_762mm < AMMO_MAX_762MM) {
			pl.ammo_762mm = bound(0, pl.ammo_762mm + 30, AMMO_MAX_762MM);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_aug_draw(void)
{
	player pl = (player)self;
	Weapons_SetModel("models/v_aug.mdl");
	Weapons_ViewAnimation(AUG_DRAW);

#ifdef CLIENT
	pl.cs_cross_mindist = 3;
	pl.cs_cross_deltadist = 3;
#endif
}

void
w_aug_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}
	if (!pl.aug_mag) {
		return;
	}

	Cstrike_ShotMultiplierAdd(pl, 1);
	float accuracy = Cstrike_CalculateAccuracy(pl, 215);
	pl.aug_mag--;

#ifdef CLIENT
	View_SetMuzzleflash(MUZZLE_RIFLE);

	int r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(AUG_SHOOT1);
		break;
	case 1:
		Weapons_ViewAnimation(AUG_SHOOT2);
		break;
	default:
		Weapons_ViewAnimation(AUG_SHOOT3);
		break;
	}
#else
	TraceAttack_SetPenetrationPower(1);
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 32, [accuracy,accuracy], WEAPON_AUG);

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT_RIFLE, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CROUCH_SHOOT_RIFLE, 0.45f);

	Sound_Play(pl, CHAN_WEAPON, "weapon_aug.fire");
#endif

	if (pl.viewzoom == 1.0f) {
		pl.w_attack_next = 0.0825f;
	} else {
		pl.w_attack_next = 0.15f;
	}
	pl.w_idle_next = pl.w_attack_next;
}

void
w_aug_secondary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next) {
		return;
	}
	/* Simple toggle of fovs */
	if (pl.viewzoom == 1.0f) {
		pl.viewzoom = 0.2f;
	} else {
		pl.viewzoom = 1.0f;
	}
	pl.w_attack_next = 0.5f;
}

void
w_aug_reload(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}
	if (pl.aug_mag >= 30) {
		return;
	}
	if (!pl.ammo_762mm) {
		return;
	}

#ifdef CLIENT
	Weapons_ViewAnimation(AUG_RELOAD);
#else
	Weapons_ReloadWeapon(pl, player::aug_mag, player::ammo_762mm, 30);
#endif

	pl.w_attack_next = 3.3f;
	pl.w_idle_next = pl.w_attack_next;
}

float
w_aug_aimanim(void)
{
	return w_ak47_aimanim();
}

void
w_aug_hud(void)
{
#ifdef CLIENT
	player pl = (player)self;
	if (pl.viewzoom == 1.0f) {
		Cstrike_DrawCrosshair();
	} else {
		Cstrike_DrawSimpleCrosshair();
	}
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [72/256,72/256], [24/256, 24/256], g_hud_color, pSeat->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_aug_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	player pl = (player)self;
	vector hud_col;

	if (pl.aug_mag == 0 && pl.ammo_762mm == 0)
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_762mm, AMMO_MAX_762MM, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud15_spr,
			[0,45/256],
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
			[0,45/256],
			[170/256,45/256],
			hud_col,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_aug =
{
	.name		= "aug",
	.id		= ITEM_AUG,
	.slot		= 0,
	.slot_pos	= 10,
	.allow_drop	= TRUE,
	.draw		= w_aug_draw,
	.holster	= __NULL__,
	.primary	= w_aug_primary,
	.secondary	= w_aug_secondary,
	.reload		= w_aug_reload,
	.release	= w_cstrike_weaponrelease,
	.crosshair	= w_aug_hud,
	.precache	= w_aug_precache,
	.pickup		= w_aug_pickup,
	.updateammo	= w_aug_updateammo,
	.wmodel		= w_aug_wmodel,
	.pmodel		= w_aug_pmodel,
	.deathmsg	= w_aug_deathmsg,
	.aimanim	= w_aug_aimanim,
	.hudpic		= w_aug_hudpic
};

#ifdef SERVER
void
weapon_aug(void)
{
	Weapons_InitItem(WEAPON_AUG);
}
#endif
