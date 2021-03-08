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

/*QUAKED weapon_xm1014 (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_xm1014.mdl"

COUNTER-STRIKE (1999) ENTITY

Benneli XM1014 Weapon

- Buy Menu -
Price: $3000

*/

enum
{
	XM1014_IDLE,
	XM1014_SHOOT1,
	XM1014_SHOOT2,
	XM1014_INSERT,
	XM1014_RELOAD_END,
	XM1014_RELOAD_START,
	XM1014_DRAW
};

enum
{
	XM1014S_IDLE,
	XM1014S_RELOAD_START,
	XM1014S_RELOAD,
	XM1014S_RELOAD_END
};

void
w_xm1014_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_xm1014.fire");
	Sound_Precache("weapon_xm1014.insertshell");
	precache_model("models/w_xm1014.mdl");
#else
	precache_model("models/v_xm1014.mdl");
	precache_model("models/p_xm1014.mdl");
#endif
}

void
w_xm1014_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.xm1014_mag, pl.ammo_buckshot, -1);
}

string
w_xm1014_wmodel(void)
{
	return "models/w_xm1014.mdl";
}

string
w_xm1014_pmodel(void)
{
	return "models/p_xm1014.mdl";
}

string
w_xm1014_deathmsg(void)
{
	return "";
}

int
w_xm1014_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (new) {
		if (startammo == -1)
			pl.xm1014_mag = 7;
		else
			pl.xm1014_mag = startammo;
	} else {
		if (pl.ammo_buckshot < AMMO_MAX_BUCKSHOT) {
			pl.ammo_buckshot = bound(0, pl.ammo_buckshot + 7, AMMO_MAX_BUCKSHOT);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_xm1014_draw(void)
{
	player pl = (player)self;
	Weapons_SetModel("models/v_xm1014.mdl");
	Weapons_ViewAnimation(XM1014_DRAW);
	pl.mode_temp = 0;

#ifdef CLIENT
	pl.cs_cross_mindist = 9;
	pl.cs_cross_deltadist = 4;
#endif
}

void
w_xm1014_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* ammo check */
#ifdef CLIENT
	if (!pl.xm1014_mag) {
		return;
	}
#else
	if (!pl.xm1014_mag) {
		return;
	}
#endif

	Cstrike_ShotMultiplierAdd(pl, 6);
	float accuracy = Cstrike_CalculateAccuracy(pl, 200);

#ifdef CLIENT
	pl.xm1014_mag--;
	View_SetMuzzleflash(MUZZLE_RIFLE);
#else
	TraceAttack_SetPenetrationPower(0);
	TraceAttack_FireBullets(6, pl.origin + pl.view_ofs, 22, [accuracy,accuracy], WEAPON_XM1014);
	pl.xm1014_mag--;

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT_SHOTGUN, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CROUCH_SHOOT_SHOTGUN, 0.45f);

	Sound_Play(pl, CHAN_WEAPON, "weapon_xm1014.fire");
#endif

	int r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(XM1014_SHOOT1);
		break;
	default:
		Weapons_ViewAnimation(XM1014_SHOOT2);
		break;
	}

	pl.w_attack_next = 0.25f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_xm1014_reload(void)
{
	player pl = (player)self;
#ifdef CLIENT
	if (pl.xm1014_mag >= 7) {
		return;
	}
	if (pl.ammo_buckshot <= 0) { 
		return;
	}
#else
	if (pl.xm1014_mag >= 7) {
		return;
	}
	if (pl.ammo_buckshot <= 0) {
		return;
	}
#endif
	
	if (pl.mode_temp > XM1014S_IDLE) {
		return;
	}
	pl.mode_temp = XM1014S_RELOAD_START;
	pl.w_idle_next = 0.0f;
}

void
w_xm1014_release(void)
{
	player pl = (player)self;

	w_cstrike_weaponrelease();

	if (pl.w_idle_next > 0.0) {
		return;
	}

	if (pl.mode_temp == XM1014S_RELOAD_START) {
		Weapons_ViewAnimation(XM1014_RELOAD_START);
		pl.mode_temp = XM1014S_RELOAD;
		pl.w_idle_next = 0.65f;
	} else if (pl.mode_temp == XM1014S_RELOAD) {
		Weapons_ViewAnimation(XM1014_INSERT);
#ifdef CLIENT
		pl.xm1014_mag++;
		pl.ammo_buckshot--;

		if (pl.ammo_buckshot <= 0 || pl.xm1014_mag >= 7) {
			pl.mode_temp = XM1014S_RELOAD_END;
		}
#else
		pl.xm1014_mag++;
		pl.ammo_buckshot--;
		w_xm1014_updateammo(pl);
		Sound_Play(pl, CHAN_WEAPON, "weapon_xm1014.insertshell");
		if (pl.ammo_buckshot <= 0 || pl.xm1014_mag >= 7) {
			pl.mode_temp = XM1014S_RELOAD_END;
		}
#endif
		pl.w_idle_next = 0.5f;
	} else if (pl.mode_temp == XM1014S_RELOAD_END) {
		Weapons_ViewAnimation(XM1014_RELOAD_END);
		pl.mode_temp = XM1014S_IDLE;
		pl.w_idle_next = 10.0f;
		pl.w_attack_next = 0.5f;
	}
}

float
w_xm1014_aimanim(void)
{
	return w_ak47_aimanim();
}

void
w_xm1014_hud(void)
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
w_xm1014_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	player pl = (player)self;
	vector hud_col;

	if (pl.xm1014_mag == 0 && pl.ammo_buckshot == 0)
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_buckshot, AMMO_MAX_BUCKSHOT, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud13_spr,
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
			g_hud12_spr,
			[0,135/256],
			[170/256,45/256],
			hud_col,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_xm1014 =
{
	.name		= "xm1014",
	.id		= ITEM_XM1014,
	.slot		= 0,
	.slot_pos	= 1,
	.allow_drop	= TRUE,
	.draw		= w_xm1014_draw,
	.holster	= __NULL__,
	.primary	= w_xm1014_primary,
	.secondary	= __NULL__,
	.reload		= w_xm1014_reload,
	.release	= w_xm1014_release,
	.crosshair	= w_xm1014_hud,
	.precache	= w_xm1014_precache,
	.pickup		= w_xm1014_pickup,
	.updateammo	= w_xm1014_updateammo,
	.wmodel		= w_xm1014_wmodel,
	.pmodel		= w_xm1014_pmodel,
	.deathmsg	= w_xm1014_deathmsg,
	.aimanim	= w_xm1014_aimanim,
	.hudpic		= w_xm1014_hudpic
};

#ifdef SERVER
void
weapon_xm1014(void)
{
	Weapons_InitItem(WEAPON_XM1014);
}
#endif
