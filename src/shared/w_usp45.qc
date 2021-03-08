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

/*QUAKED weapon_usp45 (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_usp45.mdl"

COUNTER-STRIKE (1999) ENTITY

Heckler & Koch USP .45 Tactical Weapon

Default arsenal for Counter-Terrorists

- Buy Menu -
Price: $500

*/

enum
{
	USP45_IDLE,
	USP45_SHOOT1,
	USP45_SHOOT2,
	USP45_SHOOT3,
	USP45_SHOOTLAST,
	USP45_RELOAD,
	USP45_DRAW,
	USP45_ADDSIL,
	USP45_IDLEUNSIL,
	USP45_SHOOT1UNSIL,
	USP45_SHOOT2UNSIL,
	USP45_SHOOT3UNSIL,
	USP45_SHOOTLASTUNSIL,
	USP45_RELOADUNSIL,
	USP45_DRAWUNSIL,
	USP45_DETACHSIL
};

void
w_usp45_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_usp45.fire");
	Sound_Precache("weapon_usp45.silenced");
	precache_model("models/w_usp.mdl");
#else
	precache_model("models/v_usp.mdl");
	precache_model("models/p_usp.mdl");
#endif
}

void
w_usp45_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.usp45_mag, pl.ammo_45acp, -1);
}

string
w_usp45_wmodel(void)
{
	return "models/w_usp.mdl";
}

string
w_usp45_pmodel(void)
{
	return "models/p_usp.mdl";
}

string
w_usp45_deathmsg(void)
{
	return "";
}

int
w_usp45_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (new) {
		if (startammo == -1)
			pl.usp45_mag = 12;
		else
			pl.usp45_mag = startammo;
	} else {
		if (pl.ammo_45acp < AMMO_MAX_45ACP) {
			pl.ammo_45acp = bound(0, pl.ammo_45acp + 12, AMMO_MAX_45ACP);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_usp45_draw(void)
{
	player pl = (player)self;
	
	Weapons_SetModel("models/v_usp.mdl");
	if (pl.mode_usp45 == 1) {
		Weapons_ViewAnimation(USP45_DRAW);
	} else {
		Weapons_ViewAnimation(USP45_DRAWUNSIL);
	}

#ifdef CLIENT
	pl.cs_cross_mindist = 8;
	pl.cs_cross_deltadist = 3;
#endif
}

void
w_usp45_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

	if (pl.gflags & GF_SEMI_TOGGLED) {
		return;
	}

	/* ammo check */
	if (!pl.usp45_mag) {
		return;
	}

	Cstrike_ShotMultiplierAdd(pl, 1);
	float accuracy = Cstrike_CalculateAccuracy(pl, 200);
	pl.usp45_mag--;

	/* actual firing */
#ifdef CLIENT
	if (pl.mode_usp45 == 1) {
		View_SetMuzzleflash(0);
	} else {
		View_SetMuzzleflash(MUZZLE_SMALL);
	}
#else
	/* Different sounds without silencer */
	if (pl.mode_usp45 == 1) {
		Sound_Play(pl, CHAN_WEAPON, "weapon_usp45.silenced");
	} else {
		Sound_Play(pl, CHAN_WEAPON, "weapon_usp45.fire");
	}

	TraceAttack_SetPenetrationPower(0);
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 33,  [accuracy,accuracy], WEAPON_USP45);

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT_ONEHAND, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CROUCH_SHOOT_ONEHAND, 0.45f);
#endif

	/* this stuff is predicted */
	int r = (float)input_sequence % 3;
	if (pl.mode_usp45 == 1) {
		if (pl.usp45_mag <= 0) {
			Weapons_ViewAnimation(USP45_SHOOTLAST);
		} else {
			switch (r) {
			case 0:
				Weapons_ViewAnimation(USP45_SHOOT1);
				break;
			case 1:
				Weapons_ViewAnimation(USP45_SHOOT2);
				break;
			default:
				Weapons_ViewAnimation(USP45_SHOOT3);
				break;
			}
		}
	} else {
		if (pl.usp45_mag <= 0) {
			Weapons_ViewAnimation(USP45_SHOOTLASTUNSIL);
		} else {
			switch (r) {
			case 0:
				Weapons_ViewAnimation(USP45_SHOOT1UNSIL);
				break;
			case 1:
				Weapons_ViewAnimation(USP45_SHOOT2UNSIL);
				break;
			default:
				Weapons_ViewAnimation(USP45_SHOOT3UNSIL);
				break;
			}
		}
	}

	pl.gflags |= GF_SEMI_TOGGLED;
	pl.w_attack_next = 0.15f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_usp45_secondary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0) {
		return;
	}

	/* toggle silencer */
	pl.mode_usp45 = 1 - pl.mode_usp45;

	/* play the animation */
	if (pl.mode_usp45) {
		Weapons_ViewAnimation(USP45_ADDSIL);
	} else {
		Weapons_ViewAnimation(USP45_DETACHSIL);
	}

	pl.w_attack_next = 3.1f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_usp45_reload(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}
	if (pl.usp45_mag >= 12) {
		return;
	}
	if (!pl.ammo_45acp) {
		return;
	}

#ifdef CLIENT
	if (pl.mode_usp45 == 1) {
		Weapons_ViewAnimation(USP45_RELOAD);
	} else {
		Weapons_ViewAnimation(USP45_RELOADUNSIL);
	}
#else
	Weapons_ReloadWeapon(pl, player::usp45_mag, player::ammo_45acp, 12);
#endif

	pl.w_attack_next = 2.5f;
}

float
w_usp45_aimanim(void)
{
	return w_deagle_aimanim();
}

void
w_usp45_hud(void)
{
#ifdef CLIENT
	Cstrike_DrawCrosshair();
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [96/256,72/256], [24/256, 24/256], g_hud_color, pSeat->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_usp45_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	player pl = (player)self;
	vector hud_col;

	if (pl.usp45_mag == 0 && pl.ammo_45acp == 0)
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_45acp, AMMO_MAX_45ACP, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud4_spr,
			[0,90/256],
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
			[0,90/256],
			[170/256,45/256],
			hud_col,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_usp45 =
{
	.name		= "usp",
	.id		= ITEM_USP45,
	.slot		= 1,
	.slot_pos	= 0,
	.allow_drop	= TRUE,
	.draw		= w_usp45_draw,
	.holster	= __NULL__,
	.primary	= w_usp45_primary,
	.secondary	= w_usp45_secondary,
	.reload		= w_usp45_reload,
	.release	= w_cstrike_weaponrelease,
	.crosshair	= w_usp45_hud,
	.precache	= w_usp45_precache,
	.pickup		= w_usp45_pickup,
	.updateammo	= w_usp45_updateammo,
	.wmodel		= w_usp45_wmodel,
	.pmodel		= w_usp45_pmodel,
	.deathmsg	= w_usp45_deathmsg,
	.aimanim	= w_usp45_aimanim,
	.hudpic		= w_usp45_hudpic
};

#ifdef SERVER
void
weapon_usp45(void)
{
	Weapons_InitItem(WEAPON_USP45);
}
#endif
