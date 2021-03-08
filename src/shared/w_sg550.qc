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

/*QUAKED weapon_sg550 (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_sg550.mdl"

COUNTER-STRIKE (1999) ENTITY

SIG SG 550 Weapon

- Buy Menu -
Price: $4200

*/

enum
{
	SG550_IDLE,
	SG550_SHOOT1,
	SG550_SHOOT2,
	SG550_RELOAD,
	SG550_DRAW,
};

void
w_sg550_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_sg550.fire");
	precache_model("models/w_sg550.mdl");
#else
	precache_model("models/v_sg550.mdl");
	precache_model("models/p_sg550.mdl");
#endif
}

void
w_sg550_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.sg550_mag, pl.ammo_556mm, -1);
}

string
w_sg550_wmodel(void)
{
	return "models/w_sg550.mdl";
}

string
w_sg550_pmodel(void)
{
	return "models/p_sg550.mdl";
}

string
w_sg550_deathmsg(void)
{
	return "";
}

int
w_sg550_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (new) {
		if (startammo == -1)
			pl.sg550_mag = 30;
		else
			pl.sg550_mag = startammo;
	} else {
		if (pl.ammo_556mm < AMMO_MAX_556MM) {
			pl.ammo_556mm = bound(0, pl.ammo_556mm + 30, AMMO_MAX_556MM);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_sg550_draw(void)
{
	player pl = (player)self;
	Weapons_SetModel("models/v_sg550.mdl");
	Weapons_ViewAnimation(SG550_DRAW);

#ifdef CLIENT
	pl.cs_cross_mindist = 5;
	pl.cs_cross_deltadist = 3;
#endif
}

void
w_sg550_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}
	if (!pl.sg550_mag) {
		return;
	}

	Cstrike_ShotMultiplierAdd(pl, 1);
	float accuracy = Cstrike_CalculateAccuracy(pl, 200);
	pl.sg550_mag--;

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
	TraceAttack_SetPenetrationPower(1);
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 70, [accuracy,accuracy], WEAPON_SG550);

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT_RIFLE, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CROUCH_SHOOT_RIFLE, 0.45f);

	Sound_Play(pl, CHAN_WEAPON, "weapon_sg550.fire");
#endif

	pl.w_attack_next = 0.25f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_sg550_secondary(void)
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
w_sg550_reload(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}
	if (pl.sg550_mag >= 30) {
		return;
	}
	if (!pl.ammo_556mm) {
		return;
	}

#ifdef CLIENT
	Weapons_ViewAnimation(SG550_RELOAD);
#else
	Weapons_ReloadWeapon(pl, player::sg550_mag, player::ammo_556mm, 30);
	Weapons_UpdateAmmo(pl, pl.sg550_mag, pl.ammo_556mm, -1);
#endif

	pl.w_attack_next = 3.8f;
	pl.w_idle_next = pl.w_attack_next;
}

float
w_sg550_aimanim(void)
{
	return w_ak47_aimanim();
}

void
w_sg550_hud(void)
{
#ifdef CLIENT
	player pl = (player)self;
	if (pl.viewzoom < 1.0f) {
		Cstrike_DrawScope();
	}
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [0,96/256], [24/256, 24/256], g_hud_color, pSeat->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_sg550_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	player pl = (player)self;
	vector hud_col;

	if (pl.sg550_mag == 0 && pl.ammo_556mm == 0)
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_556mm, AMMO_MAX_556MM, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud15_spr,
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
			g_hud14_spr,
			[0,180/256],
			[170/256,45/256],
			hud_col,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_sg550 =
{
	.name		= "sg550",
	.id		= ITEM_SG550,
	.slot		= 0,
	.slot_pos	= 14,
	.allow_drop	= TRUE,
	.draw		= w_sg550_draw,
	.holster	= __NULL__,
	.primary	= w_sg550_primary,
	.secondary	= w_sg550_secondary,
	.reload		= w_sg550_reload,
	.release	= w_cstrike_weaponrelease,
	.crosshair	= w_sg550_hud,
	.precache	= w_sg550_precache,
	.pickup		= w_sg550_pickup,
	.updateammo	= w_sg550_updateammo,
	.wmodel		= w_sg550_wmodel,
	.pmodel		= w_sg550_pmodel,
	.deathmsg	= w_sg550_deathmsg,
	.aimanim	= w_sg550_aimanim,
	.hudpic		= w_sg550_hudpic
};

#ifdef SERVER
void
weapon_sg550(void)
{
	Weapons_InitItem(WEAPON_SG550);
}
#endif
