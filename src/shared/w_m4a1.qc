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

/*QUAKED weapon_m4a1 (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_m4a1.mdl"

COUNTER-STRIKE (1999) ENTITY

Colt M4A1 Carbine Weapon

- Buy Menu -
Price: $3100
Counter-Terrorists only weapon

*/

enum
{
	M4A1_IDLE,
	M4A1_SHOOT1,
	M4A1_SHOOT2,
	M4A1_SHOOT3,
	M4A1_RELOAD,
	M4A1_DRAW,
	M4A1_ADDSIL,
	M4A1_IDLEUNSIL,
	M4A1_SHOOT1UNSIL,
	M4A1_SHOOT2UNSIL,
	M4A1_SHOOT3UNSIL,
	M4A1_RELOADUNSIL,
	M4A1_DRAWUNSIL,
	M4A1_DETACHSIL
};

void
w_m4a1_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_m4a1.fire");
	Sound_Precache("weapon_m4a1.silenced");
	precache_model("models/w_m4a1.mdl");
#else
	precache_model("models/v_m4a1.mdl");
	precache_model("models/p_m4a1.mdl");
#endif
}

void
w_m4a1_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.m4a1_mag, pl.ammo_556mm, -1);
}

string
w_m4a1_wmodel(void)
{
	return "models/w_m4a1.mdl";
}

string
w_m4a1_pmodel(void)
{
	return "models/p_m4a1.mdl";
}

string
w_m4a1_deathmsg(void)
{
	return "";
}

int
w_m4a1_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (new) {
		if (startammo == -1)
			pl.m4a1_mag = 30;
		else
			pl.m4a1_mag = startammo;
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
w_m4a1_draw(void)
{
	player pl = (player)self;
	
	Weapons_SetModel("models/v_m4a1.mdl");
	
	if (pl.mode_m4a1 == 1) {
		Weapons_ViewAnimation(M4A1_DRAW);
	} else {
		Weapons_ViewAnimation(M4A1_DRAWUNSIL);
	}

#ifdef CLIENT
	pl.cs_cross_mindist = 4;
	pl.cs_cross_deltadist = 3;
#endif
}

void
w_m4a1_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}
	if (!pl.m4a1_mag) {
		return;
	}

	Cstrike_ShotMultiplierAdd(pl, 1);
	float accuracy = Cstrike_CalculateAccuracy(pl, 220);
	pl.m4a1_mag--;

	/* actual firing */
#ifdef CLIENT
	if (pl.mode_m4a1 == 1) {
		View_SetMuzzleflash(0);
	} else {
		View_SetMuzzleflash(MUZZLE_RIFLE);
	}

	/* this stuff is predicted */
	int r = (float)input_sequence % 3;
	if (pl.mode_m4a1 == 1) {
		switch (r) {
		case 0:
			Weapons_ViewAnimation(M4A1_SHOOT1);
			break;
		case 1:
			Weapons_ViewAnimation(M4A1_SHOOT2);
			break;
		default:
			Weapons_ViewAnimation(M4A1_SHOOT3);
			break;
		}
	} else {
		switch (r) {
		case 0:
			Weapons_ViewAnimation(M4A1_SHOOT1UNSIL);
			break;
		case 1:
			Weapons_ViewAnimation(M4A1_SHOOT2UNSIL);
			break;
		default:
			Weapons_ViewAnimation(M4A1_SHOOT3UNSIL);
			break;
		}
	}
#else
	/* Different sounds without silencer */
	if (pl.mode_m4a1 == 1) {
		Sound_Play(pl, CHAN_WEAPON, "weapon_m4a1.silenced");
	} else {
		Sound_Play(pl, CHAN_WEAPON, "weapon_m4a1.fire");
	}

	TraceAttack_SetPenetrationPower(1);
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 33,  [accuracy,accuracy], WEAPON_M4A1);

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT_RIFLE, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CROUCH_SHOOT_RIFLE, 0.45f);
#endif

	pl.w_attack_next = 0.0875f;
	pl.w_idle_next = 2.0f;
}

void
w_m4a1_secondary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0) {
		return;
	}

	/* toggle silencer */
	pl.mode_m4a1 = 1 - pl.mode_m4a1;

	/* play the animation */
	if (pl.mode_m4a1) {
		Weapons_ViewAnimation(M4A1_ADDSIL);
	} else {
		Weapons_ViewAnimation(M4A1_DETACHSIL);
	}

	pl.w_attack_next = 2.0f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_m4a1_reload(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}
	if (pl.m4a1_mag >= 30) {
		return;
	}
	if (!pl.ammo_556mm) {
		return;
	}

#ifdef CLIENT
	if (pl.mode_m4a1 == 1) {
		Weapons_ViewAnimation(M4A1_RELOAD);
	} else {
		Weapons_ViewAnimation(M4A1_RELOADUNSIL);
	}
#else
	Weapons_ReloadWeapon(pl, player::m4a1_mag, player::ammo_556mm, 30);
#endif
	
	pl.w_attack_next = 3.1f;
	pl.w_idle_next = pl.w_attack_next;
}

float
w_m4a1_aimanim(void)
{
	return w_ak47_aimanim();
}

void
w_m4a1_hud(void)
{
#ifdef CLIENT
	Cstrike_DrawCrosshair();
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [0,96/256], [24/256, 24/256], g_hud_color, pSeat->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_m4a1_release(void)
{
	player pl = (player)self;

	w_cstrike_weaponrelease();

	if (pl.w_idle_next > 0.0) {
		return;
	}

	if (pl.mode_m4a1) {
		Weapons_ViewAnimation(M4A1_IDLE);
	} else {
		Weapons_ViewAnimation(M4A1_IDLEUNSIL);
	}
	pl.w_idle_next = 5.0f;
}

void
w_m4a1_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	player pl = (player)self;
	vector hud_col;

	if (pl.m4a1_mag == 0 && pl.ammo_556mm == 0)
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_556mm, AMMO_MAX_556MM, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud5_spr,
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
			g_hud2_spr,
			[0,45/256],
			[170/256,45/256],
			hud_col,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_m4a1 =
{
	.name		= "m4a1",
	.id		= ITEM_M4A1,
	.slot		= 0,
	.slot_pos	= 9,
	.allow_drop 	= TRUE,
	.draw		= w_m4a1_draw,
	.holster	= __NULL__,
	.primary	= w_m4a1_primary,
	.secondary	= w_m4a1_secondary,
	.reload		= w_m4a1_reload,
	.release	= w_m4a1_release,
	.crosshair	= w_m4a1_hud,
	.precache	= w_m4a1_precache,
	.pickup		= w_m4a1_pickup,
	.updateammo	= w_m4a1_updateammo,
	.wmodel		= w_m4a1_wmodel,
	.pmodel		= w_m4a1_pmodel,
	.deathmsg	= w_m4a1_deathmsg,
	.aimanim	= w_m4a1_aimanim,
	.hudpic		= w_m4a1_hudpic
};

#ifdef SERVER
void
weapon_m4a1(void)
{
	Weapons_InitItem(WEAPON_M4A1);
}
#endif
