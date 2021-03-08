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

/*QUAKED weapon_m249 (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_m249.mdl"

COUNTER-STRIKE (1999) ENTITY

FN M249 Para Weapon

- Buy Menu -
Price: $5750

*/

enum
{
	PARA_IDLE,
	PARA_SHOOT1,
	PARA_SHOOT2,
	PARA_RELOAD,
	PARA_DRAW
};

void
w_para_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_para.fire");
	precache_model("models/w_m249.mdl");
#else
	precache_model("models/v_m249.mdl");
	precache_model("models/p_m249.mdl");
#endif
}

void
w_para_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.para_mag, pl.ammo_556mmbox, -1);
}

string
w_para_wmodel(void)
{
	return "models/w_m249.mdl";
}

string
w_para_pmodel(void)
{
	return "models/p_m249.mdl";
}

string
w_para_deathmsg(void)
{
	return "";
}

int
w_para_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (new) {
		if (startammo == -1)
			pl.para_mag = 100;
		else
			pl.para_mag = startammo;
	} else {
		if (pl.ammo_556mmbox < AMMO_MAX_556MMBOX) {
			pl.ammo_556mmbox = bound(0, pl.ammo_556mmbox + 100, AMMO_MAX_556MMBOX);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_para_draw(void)
{
	player pl = (player)self;
	Weapons_SetModel("models/v_m249.mdl");
	Weapons_ViewAnimation(PARA_DRAW);

#ifdef CLIENT
	pl.cs_cross_mindist = 6;
	pl.cs_cross_deltadist = 3;
#endif
}

void
w_para_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}
	if (!pl.para_mag) {
		return;
	}

	Cstrike_ShotMultiplierAdd(pl, 1);
	float accuracy = Cstrike_CalculateAccuracy(pl, 175);
	pl.para_mag--;

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
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 35, [accuracy,accuracy], WEAPON_PARA);

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_CROUCH_SHOOT_PARA, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_SHOOT_PARA, 0.45f);

	Sound_Play(pl, CHAN_WEAPON, "weapon_para.fire");
#endif

	pl.w_attack_next = 0.1f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_para_reload(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}
	if (pl.para_mag >= 100) {
		return;
	}
	if (!pl.ammo_556mmbox) {
		return;
	}

#ifdef CLIENT
	Weapons_ViewAnimation(PARA_RELOAD);
#else
	Weapons_ReloadWeapon(pl, player::para_mag, player::ammo_556mmbox, 100);
	Weapons_UpdateAmmo(pl, pl.para_mag, pl.ammo_556mmbox, -1);
#endif

	pl.w_attack_next = 3.0f;
	pl.w_idle_next = pl.w_attack_next;
}

float
w_para_aimanim(void)
{
	return w_ak47_aimanim();
}

void
w_para_hud(void)
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
w_para_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	player pl = (player)self;
	vector hud_col;

	if (pl.para_mag == 0 && pl.ammo_556mmbox == 0)
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_556mmbox, AMMO_MAX_556MMBOX, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud6_spr,
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
			g_hud3_spr,
			[0,0],
			[170/256,45/256],
			hud_col,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_para =
{
	.name		= "m249",
	.id		= ITEM_PARA,
	.slot		= 0,
	.slot_pos	= 15,
	.allow_drop	= TRUE,
	.draw		= w_para_draw,
	.holster	= __NULL__,
	.primary	= w_para_primary,
	.secondary	= __NULL__,
	.reload		= w_para_reload,
	.release	= w_cstrike_weaponrelease,
	.crosshair	= w_para_hud,
	.precache	= w_para_precache,
	.pickup		= w_para_pickup,
	.updateammo	= w_para_updateammo,
	.wmodel		= w_para_wmodel,
	.pmodel		= w_para_pmodel,
	.deathmsg	= w_para_deathmsg,
	.aimanim	= w_para_aimanim,
	.hudpic		= w_para_hudpic
};

#ifdef SERVER
void
weapon_m249(void)
{
	Weapons_InitItem(WEAPON_PARA);
}
#endif
