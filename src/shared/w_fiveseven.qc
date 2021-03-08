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

/*QUAKED weapon_fiveseven (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_fiveseven.mdl"

COUNTER-STRIKE (1999) ENTITY

Five-SeveN Weapon

- Buy Menu -
Price: $750

*/

enum
{
	FIVESEVEN_IDLE,
	FIVESEVEN_SHOOT1,
	FIVESEVEN_SHOOT2,
	FIVESEVEN_SHOOT_EMPTY,
	FIVESEVEN_RELOAD,
	FIVESEVEN_DRAW
};

void
w_fiveseven_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_fiveseven.fire");
	precache_model("models/w_fiveseven.mdl");
#else
	precache_model("models/v_fiveseven.mdl");
	precache_model("models/p_fiveseven.mdl");
#endif
}

void
w_fiveseven_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.fiveseven_mag, pl.ammo_57mm, -1);
}

string
w_fiveseven_wmodel(void)
{
	return "models/w_fiveseven.mdl";
}

string
w_fiveseven_pmodel(void)
{
	return "models/p_fiveseven.mdl";
}

string
w_fiveseven_deathmsg(void)
{
	return "";
}

int
w_fiveseven_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (new) {
		if (startammo == -1)
			pl.fiveseven_mag = 20;
		else
			pl.fiveseven_mag = startammo;
	} else {
		if (pl.ammo_57mm < AMMO_MAX_57MM) {
			pl.ammo_57mm = bound(0, pl.ammo_57mm + 20, AMMO_MAX_57MM);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_fiveseven_draw(void)
{
	player pl = (player)self;
	Weapons_SetModel("models/v_fiveseven.mdl");
	Weapons_ViewAnimation(FIVESEVEN_DRAW);

#ifdef CLIENT
	pl.cs_cross_mindist = 8;
	pl.cs_cross_deltadist = 3;
#endif
}

void
w_fiveseven_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

	if (pl.gflags & GF_SEMI_TOGGLED) {
		return;
	}
	if (!pl.fiveseven_mag) {
		return;
	}

	Cstrike_ShotMultiplierAdd(pl, 1);
	float accuracy = Cstrike_CalculateAccuracy(pl, 200);
	pl.fiveseven_mag--;

#ifdef CLIENT
	View_SetMuzzleflash(MUZZLE_RIFLE);

	if (pl.fiveseven_mag <= 0) {
		Weapons_ViewAnimation(FIVESEVEN_SHOOT_EMPTY);
	} else {
		int r = (float)input_sequence % 2;
		switch (r) {
		case 0:
			Weapons_ViewAnimation(FIVESEVEN_SHOOT1);
			break;
		default:
			Weapons_ViewAnimation(FIVESEVEN_SHOOT2);
			break;
		}
	}
#else
	TraceAttack_SetPenetrationPower(0);
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 25, [accuracy,accuracy], WEAPON_FIVESEVEN);

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT_ONEHAND, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CROUCH_SHOOT_ONEHAND, 0.45f);

	Sound_Play(pl, CHAN_WEAPON, "weapon_fiveseven.fire");
#endif

	pl.gflags |= GF_SEMI_TOGGLED;
	pl.w_attack_next = 0.15f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_fiveseven_reload(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}
	if (pl.fiveseven_mag >= 20) {
		return;
	}
	if (!pl.ammo_57mm) {
		return;
	}

#ifdef CLIENT
	Weapons_ViewAnimation(FIVESEVEN_RELOAD);
#else
	Weapons_ReloadWeapon(pl, player::fiveseven_mag, player::ammo_57mm, 20);
#endif

	pl.w_attack_next = 3.1f;
	pl.w_idle_next = pl.w_attack_next;
}

float
w_fiveseven_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CROUCH_AIM_ONEHAND : ANIM_AIM_ONEHAND;
}

void
w_fiveseven_hud(void)
{
#ifdef CLIENT
	Cstrike_DrawCrosshair();
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [120/256,96/256], [24/256, 24/256], g_hud_color, pSeat->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_fiveseven_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	player pl = (player)self;
	vector hud_col;

	if (pl.fiveseven_mag == 0 && pl.ammo_57mm == 0)
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_57mm, AMMO_MAX_57MM, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud15_spr,
			[0,135/256],
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
			[0,135/256],
			[170/256,45/256],
			hud_col,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_fiveseven =
{
	.name		= "fiveseven",
	.id		= ITEM_FIVESEVEN,
	.slot		= 1,
	.slot_pos	= 5,
	.allow_drop	= TRUE,
	.draw		= w_fiveseven_draw,
	.holster	= __NULL__,
	.primary	= w_fiveseven_primary,
	.secondary	= __NULL__,
	.reload		= w_fiveseven_reload,
	.release	= w_cstrike_weaponrelease,
	.crosshair	= w_fiveseven_hud,
	.precache	= w_fiveseven_precache,
	.pickup		= w_fiveseven_pickup,
	.updateammo	= w_fiveseven_updateammo,
	.wmodel		= w_fiveseven_wmodel,
	.pmodel		= w_fiveseven_pmodel,
	.deathmsg	= w_fiveseven_deathmsg,
	.aimanim	= w_fiveseven_aimanim,
	.hudpic		= w_fiveseven_hudpic
};

#ifdef SERVER
void
weapon_fiveseven(void)
{
	Weapons_InitItem(WEAPON_FIVESEVEN);
}
#endif
