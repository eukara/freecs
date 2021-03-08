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

/*QUAKED weapon_m3 (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_m3.mdl"

COUNTER-STRIKE (1999) ENTITY

Benneli M3 Super90 Weapon

- Buy Menu -
Price: $1700

*/

enum
{
	M3_IDLE,
	M3_SHOOT1,
	M3_SHOOT2,
	M3_INSERT,
	M3_RELOAD_END,
	M3_RELOAD_START,
	M3_DRAW
};

enum
{
	M3S_IDLE,
	M3S_RELOAD_START,
	M3S_RELOAD,
	M3S_RELOAD_END
};

void
w_m3_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_m3.fire");
	precache_model("models/w_m3.mdl");
#else
	precache_model("models/v_m3.mdl");
	precache_model("models/p_m3.mdl");
#endif
}

void
w_m3_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.m3_mag, pl.ammo_buckshot, -1);
}

string
w_m3_wmodel(void)
{
	return "models/w_m3.mdl";
}

string
w_m3_pmodel(void)
{
	return "models/p_m3.mdl";
}

string
w_m3_deathmsg(void)
{
	return "";
}

int
w_m3_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (new) {
		if (startammo == -1)
			pl.m3_mag = 8;
		else
			pl.m3_mag = startammo;
	} else {
		if (pl.ammo_buckshot < AMMO_MAX_BUCKSHOT) {
			pl.ammo_buckshot = bound(0, pl.ammo_buckshot + 8, AMMO_MAX_BUCKSHOT);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_m3_draw(void)
{
	player pl = (player)self;
	Weapons_SetModel("models/v_m3.mdl");
	Weapons_ViewAnimation(M3_DRAW);
	pl.mode_temp = 0;

#ifdef CLIENT
	pl.cs_cross_mindist = 8;
	pl.cs_cross_deltadist = 6;
#endif
}

void
w_m3_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

#ifdef CLIENT
	if (!pl.m3_mag) {
		return;
	}
#else
	if (!pl.m3_mag) {
		return;
	}
#endif

	Cstrike_ShotMultiplierAdd(pl, 9);
	float accuracy = Cstrike_CalculateAccuracy(pl, 200);

#ifdef CLIENT
	pl.m3_mag--;
	View_SetMuzzleflash(MUZZLE_RIFLE);
#else
	TraceAttack_SetPenetrationPower(0);
	TraceAttack_FireBullets(9, pl.origin + pl.view_ofs, 26, [accuracy,accuracy], WEAPON_M3);
	pl.m3_mag--;

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT_SHOTGUN, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CROUCH_SHOOT_SHOTGUN, 0.45f);

	Sound_Play(pl, CHAN_WEAPON, "weapon_m3.fire");
#endif

	int r = (float)input_sequence % 2;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(M3_SHOOT1);
		break;
	default:
		Weapons_ViewAnimation(M3_SHOOT2);
		break;
	}

	pl.w_attack_next = 1.0f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_m3_reload(void)
{
	player pl = (player)self;
#ifdef CLIENT
	if (pl.m3_mag >= 8) {
		return;
	}
	if (pl.ammo_buckshot <= 0) { 
		return;
	}
#else
	if (pl.m3_mag >= 8) {
		return;
	}
	if (pl.ammo_buckshot <= 0) {
		return;
	}
#endif
	
	if (pl.mode_temp > M3S_IDLE) {
		return;
	}
	pl.mode_temp = M3S_RELOAD_START;
	pl.w_idle_next = 0.0f;
}

void
w_m3_release(void)
{
	player pl = (player)self;

	w_cstrike_weaponrelease();

	if (pl.w_idle_next > 0.0) {
		return;
	}

	if (pl.mode_temp == M3S_RELOAD_START) {
		Weapons_ViewAnimation(M3_RELOAD_START);
		pl.mode_temp = M3S_RELOAD;
		pl.w_idle_next = 0.65f;
	} else if (pl.mode_temp == M3S_RELOAD) {
		Weapons_ViewAnimation(M3_INSERT);
#ifdef CLIENT
		pl.m3_mag++;
		pl.ammo_buckshot--;

		if (pl.ammo_buckshot <= 0 || pl.m3_mag >= 8) {
			pl.mode_temp = M3S_RELOAD_END;
		}
#else
		pl.m3_mag++;
		pl.ammo_buckshot--;
		w_m3_updateammo(pl);
		if (pl.ammo_buckshot <= 0 || pl.m3_mag >= 8) {
			pl.mode_temp = M3S_RELOAD_END;
		}
#endif
		pl.w_idle_next = 0.5f;	
	} else if (pl.mode_temp == M3S_RELOAD_END) {
		Weapons_ViewAnimation(M3_RELOAD_END);
		pl.mode_temp = M3S_IDLE;
		pl.w_idle_next = 10.0f;
		pl.w_attack_next = 0.5f;
	}
}

float
w_m3_aimanim(void)
{
	return w_ak47_aimanim();
}

void
w_m3_hud(void)
{
#ifdef CLIENT
	Cstrike_DrawCrosshair();
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [0,72/256], [24/256, 24/256], g_hud_color, pSeat->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_m3_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	player pl = (player)self;
	vector hud_col;

	if (pl.m3_mag == 0 && pl.ammo_buckshot == 0)
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_buckshot, AMMO_MAX_BUCKSHOT, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud4_spr,
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
			g_hud1_spr,
			[0,135/256],
			[170/256,45/256],
			hud_col,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_m3 =
{
	.name		= "m3",
	.id		= ITEM_M3,
	.slot		= 0,
	.slot_pos	= 0,
	.allow_drop	= TRUE,
	.draw		= w_m3_draw,
	.holster	= __NULL__,
	.primary	= w_m3_primary,
	.secondary	= __NULL__,
	.reload		= w_m3_reload,
	.release	= w_m3_release,
	.crosshair	= w_m3_hud,
	.precache	= w_m3_precache,
	.pickup		= w_m3_pickup,
	.updateammo	= w_m3_updateammo,
	.wmodel		= w_m3_wmodel,
	.pmodel		= w_m3_pmodel,
	.deathmsg	= w_m3_deathmsg,
	.aimanim	= w_m3_aimanim,
	.hudpic		= w_m3_hudpic
};

#ifdef SERVER
void
weapon_m3(void)
{
	Weapons_InitItem(WEAPON_M3);
}
#endif
