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

/*QUAKED weapon_deagle (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_deagle.mdl"

COUNTER-STRIKE (1999) ENTITY

Desert Eagle .50 AE Weapon

- Buy Menu -
Price: $650

*/

enum
{
	DEAGLE_IDLE,
	DEAGLE_SHOOT1,
	DEAGLE_SHOOT2,
	DEAGLE_SHOOT_EMPTY,
	DEAGLE_RELOAD,
	DEAGLE_DRAW
};

void
w_deagle_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_deagle.fire");
	precache_model("models/w_deagle.mdl");
#else
	precache_model("models/v_deagle.mdl");
	precache_model("models/p_deagle.mdl");
#endif
}

void
w_deagle_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.deagle_mag, pl.ammo_50ae, -1);
}

string
w_deagle_wmodel(void)
{
	return "models/w_deagle.mdl";
}

string
w_deagle_pmodel(void)
{
	return "models/p_deagle.mdl";
}

string
w_deagle_deathmsg(void)
{
	return "";
}

int
w_deagle_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (new) {
		if (startammo == -1)
			pl.deagle_mag = 7;
		else
			pl.deagle_mag = startammo;
	} else {
		if (pl.ammo_50ae < AMMO_MAX_50AE) {
			pl.ammo_50ae = bound(0, pl.ammo_50ae + 7, AMMO_MAX_50AE);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_deagle_draw(void)
{
	player pl = (player)self;
	Weapons_SetModel("models/v_deagle.mdl");
	Weapons_ViewAnimation(DEAGLE_DRAW);

#ifdef CLIENT
	pl.cs_cross_mindist = 8;
	pl.cs_cross_deltadist = 3;
#endif
}

void
w_deagle_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

	if (pl.gflags & GF_SEMI_TOGGLED) {
		return;
	}
	if (!pl.deagle_mag) {
		return;
	}

	Cstrike_ShotMultiplierAdd(pl, 1);
	float accuracy = Cstrike_CalculateAccuracy(pl, 200);
	pl.deagle_mag--;

#ifdef CLIENT
	View_SetMuzzleflash(MUZZLE_RIFLE);

	if (pl.deagle_mag <= 0) {
		Weapons_ViewAnimation(DEAGLE_SHOOT_EMPTY);
	} else {
		int r = (float)input_sequence % 2;
		switch (r) {
		case 0:
			Weapons_ViewAnimation(DEAGLE_SHOOT1);
			break;
		default:
			Weapons_ViewAnimation(DEAGLE_SHOOT2);
			break;
		}
	}
#else
	TraceAttack_SetPenetrationPower(1);
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 54, [accuracy,accuracy], WEAPON_DEAGLE);

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_CROUCH_SHOOT_ONEHAND, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_SHOOT_ONEHAND, 0.45f);

	Sound_Play(pl, CHAN_WEAPON, "weapon_deagle.fire");
#endif

	pl.gflags |= GF_SEMI_TOGGLED;
	pl.w_attack_next = 0.15f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_deagle_reload(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}
	if (pl.deagle_mag >= 7) {
		return;
	}
	if (!pl.ammo_50ae) {
		return;
	}

#ifdef CLIENT
	Weapons_ViewAnimation(DEAGLE_RELOAD);
#else
	Weapons_ReloadWeapon(pl, player::deagle_mag, player::ammo_50ae, 7);
#endif

	pl.w_attack_next = 2.1f;
	pl.w_idle_next = pl.w_attack_next;
}

float
w_deagle_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CROUCH_AIM_ONEHAND : ANIM_AIM_ONEHAND;
}

void
w_deagle_hud(void)
{
#ifdef CLIENT
	Cstrike_DrawCrosshair();
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [24/256,72/256], [24/256, 24/256], g_hud_color, pSeat->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_deagle_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	player pl = (player)self;
	vector hud_col;

	if (pl.deagle_mag == 0 && pl.ammo_50ae == 0)
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_50ae, AMMO_MAX_50AE, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud11_spr,
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
			g_hud10_spr,
			[0,90/256],
			[170/256,45/256],
			hud_col,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_deagle =
{
	.name		= "deagle",
	.id		= ITEM_DEAGLE,
	.slot		= 1,
	.slot_pos	= 2,
	.allow_drop	= TRUE,
	.draw		= w_deagle_draw,
	.holster	= __NULL__,
	.primary	= w_deagle_primary,
	.secondary	= __NULL__,
	.reload		= w_deagle_reload,
	.release	= w_cstrike_weaponrelease,
	.crosshair	= w_deagle_hud,
	.precache	= w_deagle_precache,
	.pickup		= w_deagle_pickup,
	.updateammo	= w_deagle_updateammo,
	.wmodel		= w_deagle_wmodel,
	.pmodel		= w_deagle_pmodel,
	.deathmsg	= w_deagle_deathmsg,
	.aimanim	= w_deagle_aimanim,
	.hudpic		= w_deagle_hudpic
};

#ifdef SERVER
void
weapon_deagle(void)
{
	Weapons_InitItem(WEAPON_DEAGLE);
}
#endif
