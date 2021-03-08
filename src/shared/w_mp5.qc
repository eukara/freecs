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

/*QUAKED weapon_mp5navy (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_mp5.mdl"

COUNTER-STRIKE (1999) ENTITY

Heckler & Koch MP5-Navy Weapon

- Buy Menu -
Price: $1500

*/

enum
{
	MP5_IDLE,
	MP5_RELOAD,
	MP5_DRAW,
	MP5_SHOOT1,
	MP5_SHOOT2,
	MP5_SHOOT3
};

void
w_mp5_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_mp5.fire");
	precache_model("models/w_mp5.mdl");
#else
	precache_model("models/v_mp5.mdl");
	precache_model("models/p_mp5.mdl");
#endif
}

void
w_mp5_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.mp5_mag, pl.ammo_9mm, -1);
}

string
w_mp5_wmodel(void)
{
	return "models/w_mp5.mdl";
}

string
w_mp5_pmodel(void)
{
	return "models/p_mp5.mdl";
}

string
w_mp5_deathmsg(void)
{
	return "";
}

int
w_mp5_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (new) {
		if (startammo == -1)
			pl.mp5_mag = 30;
		else
			pl.mp5_mag = startammo;
	} else {
		if (pl.ammo_9mm < AMMO_MAX_9MM) {
			pl.ammo_9mm = bound(0, pl.ammo_9mm + 30, AMMO_MAX_9MM);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_mp5_draw(void)
{
	player pl = (player)self;
	Weapons_SetModel("models/v_mp5.mdl");
	Weapons_ViewAnimation(MP5_DRAW);

#ifdef CLIENT
	pl.cs_cross_mindist = 5;
	pl.cs_cross_deltadist = 2;
#endif
}

void
w_mp5_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}
	if (!pl.mp5_mag) {
		return;
	}

	Cstrike_ShotMultiplierAdd(pl, 1);
	float accuracy = Cstrike_CalculateAccuracy(pl, 220);
	pl.mp5_mag--;

#ifdef CLIENT
	View_SetMuzzleflash(MUZZLE_RIFLE);

	int r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(MP5_SHOOT1);
		break;
	case 1:
		Weapons_ViewAnimation(MP5_SHOOT2);
		break;
	default:
		Weapons_ViewAnimation(MP5_SHOOT3);
		break;
	}
#else
	TraceAttack_SetPenetrationPower(0);
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 26, [accuracy,accuracy], WEAPON_MP5);

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT_MP5, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CROUCH_SHOOT_MP5, 0.45f);

	Sound_Play(pl, CHAN_WEAPON, "weapon_mp5.fire");
#endif

	pl.w_attack_next = 0.08f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_mp5_reload(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}
	if (pl.mp5_mag >= 30) {
		return;
	}
	if (!pl.ammo_9mm) {
		return;
	}

#ifdef CLIENT
	Weapons_ViewAnimation(MP5_RELOAD);
#else
	Weapons_ReloadWeapon(pl, player::mp5_mag, player::ammo_9mm, 30);
	Weapons_UpdateAmmo(pl, pl.mp5_mag, pl.ammo_9mm, -1);
#endif

	pl.w_attack_next = 2.6f;
	pl.w_idle_next = pl.w_attack_next;
}

float
w_mp5_aimanim(void)
{
	return w_ak47_aimanim();
}

void
w_mp5_hud(void)
{
#ifdef CLIENT
	Cstrike_DrawCrosshair();
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [48/256,72/256], [24/256, 24/256], g_hud_color, pSeat->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_mp5_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	player pl = (player)self;
	vector hud_col;

	if (pl.mp5_mag == 0 && pl.ammo_9mm == 0)
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_9mm, AMMO_MAX_9MM, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud4_spr,
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
			g_hud1_spr,
			[0,180/256],
			[170/256,45/256],
			hud_col,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_mp5 =
{
	.name		= "mp5navy",
	.id		= ITEM_MP5,
	.slot		= 0,
	.slot_pos	= 2,
	.allow_drop	= TRUE,
	.draw		= w_mp5_draw,
	.holster	= __NULL__,
	.primary	= w_mp5_primary,
	.secondary	= __NULL__,
	.reload		= w_mp5_reload,
	.release	= w_cstrike_weaponrelease,
	.crosshair	= w_mp5_hud,
	.precache	= w_mp5_precache,
	.pickup		= w_mp5_pickup,
	.updateammo	= w_mp5_updateammo,
	.wmodel		= w_mp5_wmodel,
	.pmodel		= w_mp5_pmodel,
	.deathmsg	= w_mp5_deathmsg,
	.aimanim	= w_mp5_aimanim,
	.hudpic		= w_mp5_hudpic
};

#ifdef SERVER
void
weapon_mp5navy(void)
{
	Weapons_InitItem(WEAPON_MP5);
}
#endif
