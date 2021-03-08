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

/*QUAKED weapon_p90 (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_p90.mdl"

COUNTER-STRIKE (1999) ENTITY

FN P90 Weapon

- Buy Menu -
Price: $2350

*/

enum
{
	P90_IDLE,
	P90_RELOAD,
	P90_DRAW,
	P90_SHOOT1,
	P90_SHOOT2,
	P90_SHOOT3
};

void
w_p90_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_p90.fire");
	precache_model("models/w_p90.mdl");
#else
	precache_model("models/v_p90.mdl");
	precache_model("models/p_p90.mdl");
#endif
}

void
w_p90_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.p90_mag, pl.ammo_57mm, -1);
}

string
w_p90_wmodel(void)
{
	return "models/w_p90.mdl";
}

string
w_p90_pmodel(void)
{
	return "models/p_p90.mdl";
}

string
w_p90_deathmsg(void)
{
	return "";
}

int
w_p90_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (new) {
		if (startammo == -1)
			pl.p90_mag = 50;
		else
			pl.p90_mag = startammo;
	} else {
		if (pl.ammo_57mm < AMMO_MAX_57MM) {
			pl.ammo_57mm = bound(0, pl.ammo_57mm + 50, AMMO_MAX_57MM);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_p90_draw(void)
{
	player pl = (player)self;
	Weapons_SetModel("models/v_p90.mdl");
	Weapons_ViewAnimation(P90_DRAW);

#ifdef CLIENT
	pl.cs_cross_mindist = 7;
	pl.cs_cross_deltadist = 3;
#endif
}

void
w_p90_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}
	if (!pl.p90_mag) {
		return;
	}

	Cstrike_ShotMultiplierAdd(pl, 1);
	float accuracy = Cstrike_CalculateAccuracy(pl, 175);
	pl.p90_mag--;

#ifdef CLIENT
	View_SetMuzzleflash(MUZZLE_RIFLE);

	int r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(P90_SHOOT1);
		break;
	case 1:
		Weapons_ViewAnimation(P90_SHOOT2);
		break;
	default:
		Weapons_ViewAnimation(P90_SHOOT3);
		break;
	}
#else
	TraceAttack_SetPenetrationPower(0);
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 26, [accuracy,accuracy], WEAPON_P90);

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT_MP5, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CROUCH_SHOOT_MP5, 0.45f);

	Sound_Play(pl, CHAN_WEAPON, "weapon_p90.fire");
#endif

	pl.w_attack_next = 0.07f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_p90_reload(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}
	if (pl.p90_mag >= 50) {
		return;
	}
	if (!pl.ammo_57mm) {
		return;
	}

#ifdef CLIENT
	Weapons_ViewAnimation(P90_RELOAD);
#else
	Weapons_ReloadWeapon(pl, player::p90_mag, player::ammo_57mm, 50);
	Weapons_UpdateAmmo(pl, pl.p90_mag, pl.ammo_57mm, -1);
#endif

	pl.w_attack_next = 3.3f;
	pl.w_idle_next = pl.w_attack_next;
}

float
w_p90_aimanim(void)
{
	return w_ak47_aimanim();
}

void
w_p90_hud(void)
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
w_p90_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	player pl = (player)self;
	vector hud_col;

	if (pl.p90_mag == 0 && pl.ammo_57mm == 0)
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_57mm, AMMO_MAX_57MM, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud13_spr,
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
			g_hud12_spr,
			[0,0],
			[170/256,45/256],
			hud_col,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_p90 =
{
	.name		= "p90",
	.id		= ITEM_P90,
	.slot		= 0,
	.slot_pos	= 3,
	.allow_drop	= TRUE,
	.draw		= w_p90_draw,
	.holster	= __NULL__,
	.primary	= w_p90_primary,
	.secondary	= __NULL__,
	.reload		= w_p90_reload,
	.release	= w_cstrike_weaponrelease,
	.crosshair	= w_p90_hud,
	.precache	= w_p90_precache,
	.pickup		= w_p90_pickup,
	.updateammo	= w_p90_updateammo,
	.wmodel		= w_p90_wmodel,
	.pmodel		= w_p90_pmodel,
	.deathmsg	= w_p90_deathmsg,
	.aimanim	= w_p90_aimanim,
	.hudpic		= w_p90_hudpic
};

#ifdef SERVER
void
weapon_p90(void)
{
	Weapons_InitItem(WEAPON_P90);
}
#endif
