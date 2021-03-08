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

/*QUAKED weapon_scout (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_scout.mdl"

COUNTER-STRIKE (1999) ENTITY

Steyr Scout Weapon

- Buy Menu -
Price: $1250

*/

enum
{
	SCOUT_IDLE,
	SCOUT_SHOOT1,
	SCOUT_SHOOT2,
	SCOUT_RELOAD,
	SCOUT_DRAW
};

void
w_scout_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_scout.fire");
	precache_model("models/w_scout.mdl");
#else
	precache_model("models/v_scout.mdl");
	precache_model("models/p_scout.mdl");
#endif
}

void
w_scout_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.scout_mag, pl.ammo_762mm, -1);
}

string
w_scout_wmodel(void)
{
	return "models/w_scout.mdl";
}

string
w_scout_pmodel(void)
{
	return "models/p_scout.mdl";
}

string
w_scout_deathmsg(void)
{
	return "";
}

int
w_scout_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (new) {
		if (startammo == -1)
			pl.scout_mag = 10;
		else
			pl.scout_mag = startammo;
	} else {
		if (pl.ammo_762mm < AMMO_MAX_762MM) {
			pl.ammo_762mm = bound(0, pl.ammo_762mm + 10, AMMO_MAX_762MM);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_scout_draw(void)
{
	player pl = (player)self;
	Weapons_SetModel("models/v_scout.mdl");
	Weapons_ViewAnimation(SCOUT_DRAW);
	pl.mode_temp = 0;

#ifdef CLIENT
	pl.cs_cross_mindist = 5;
	pl.cs_cross_deltadist = 3;
#endif
}


void
w_scout_release(void)
{
	player pl = (player)self;

	w_cstrike_weaponrelease();

	if (pl.w_idle_next > 0.0f) {
		pl.viewzoom = 1.0f;
		return;
	}

	if (pl.mode_temp == 1) {
		pl.viewzoom = 0.45f;
	} else if (pl.mode_temp == 2) {
		pl.viewzoom = 0.1f;
	} else {
		pl.viewzoom = 1.0f;
	}
}

void
w_scout_secondary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next) {
		return;
	}

#ifdef SSQC
	Sound_Play(pl, CHAN_WEAPON, "weapon_awp.zoom");
#endif

	/* Simple toggle of fovs */
	if (pl.mode_temp == 1) {
		pl.mode_temp = 2;
	} else if (pl.mode_temp == 2) {
		pl.mode_temp = 0;
	} else {
		pl.mode_temp = 1;
	}

	pl.w_attack_next = 0.3f;
	pl.w_idle_next = 0.0f;
	w_scout_release();
}

void
w_scout_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		w_scout_release();
		return;
	}
	if (!pl.scout_mag) {
		return;
	}

	Cstrike_ShotMultiplierAdd(pl, 1);
	float accuracy = Cstrike_CalculateAccuracy(pl, 200);
	pl.scout_mag--;

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
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 75, [accuracy,accuracy], WEAPON_SCOUT);

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT_RIFLE, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CROUCH_SHOOT_RIFLE, 0.45f);

	Sound_Play(pl, CHAN_WEAPON, "weapon_scout.fire");
#endif

	pl.w_attack_next = 1.25f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_scout_reload(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}
	if (pl.scout_mag >= 10) {
		return;
	}
	if (!pl.ammo_762mm) {
		return;
	}

#ifdef CLIENT
	Weapons_ViewAnimation(SCOUT_RELOAD);
#else
	Weapons_ReloadWeapon(pl, player::scout_mag, player::ammo_762mm, 10);
	Weapons_UpdateAmmo(pl, pl.scout_mag, pl.ammo_762mm, -1);
#endif

	pl.w_attack_next = 2.0f;
	pl.w_idle_next = pl.w_attack_next;
}

float
w_scout_aimanim(void)
{
	return w_ak47_aimanim();
}

void
w_scout_hud(void)
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
w_scout_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	player pl = (player)self;
	vector hud_col;

	if (pl.scout_mag == 0 && pl.ammo_762mm == 0)
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_762mm, AMMO_MAX_762MM, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud13_spr,
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
			g_hud12_spr,
			[0,45/256],
			[170/256,45/256],
			hud_col,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_scout =
{
	.name		= "scout",
	.id		= ITEM_SCOUT,
	.slot		= 0,
	.slot_pos	= 11,
	.allow_drop	= TRUE,
	.draw		= w_scout_draw,
	.holster	= __NULL__,
	.primary	= w_scout_primary,
	.secondary	= w_scout_secondary,
	.reload		= w_scout_reload,
	.release	= w_scout_release,
	.crosshair	= w_scout_hud,
	.precache	= w_scout_precache,
	.pickup		= w_scout_pickup,
	.updateammo	= w_scout_updateammo,
	.wmodel		= w_scout_wmodel,
	.pmodel		= w_scout_pmodel,
	.deathmsg	= w_scout_deathmsg,
	.aimanim	= w_scout_aimanim,
	.hudpic		= w_scout_hudpic
};

#ifdef SERVER
void
weapon_scout(void)
{
	Weapons_InitItem(WEAPON_SCOUT);
}
#endif
