/*
 * Copyright (c) 2016-2021 Marco Cawthorne <marco@icculus.org>
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
w_fiveseven_pickup(player pl, int new, int startammo)
{
#ifdef SERVER

	if (new) {
		if (startammo == -1)
			pl.fiveseven_mag = 20;
		else
			pl.fiveseven_mag = startammo;
	} else {
		if (pl.ammo_57mm < AMMO_MAX_57MM) {
			pl.ammo_57mm = bound(0, pl.ammo_57mm + 20, AMMO_MAX_57MM);
		} else {
			return (0);
		}
	}
#endif
	return (1);
}

void
w_fiveseven_draw(player pl)
{
	Weapons_SetModel("models/v_fiveseven.mdl");
	Weapons_ViewAnimation(pl, FIVESEVEN_DRAW);

#ifdef CLIENT
	pl.cs_cross_mindist = 8;
	pl.cs_cross_deltadist = 3;
#endif
}

void
w_fiveseven_primary(player pl)
{

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

	if (pl.fiveseven_mag <= 0) {
		Weapons_ViewAnimation(pl, FIVESEVEN_SHOOT_EMPTY);
	} else {
		int r = (float)input_sequence % 2;
		switch (r) {
		case 0:
			Weapons_ViewAnimation(pl, FIVESEVEN_SHOOT1);
			break;
		default:
			Weapons_ViewAnimation(pl, FIVESEVEN_SHOOT2);
			break;
		}
	}

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_SHOOT_ONEHAND, 0.45f);
	else
		Animation_PlayerTop(pl, ANIM_CROUCH_SHOOT_ONEHAND, 0.45f);

#ifdef CLIENT
	View_SetMuzzleflash(MUZZLE_RIFLE);
	View_AddEvent(w_pistol_ejectshell, 0.0f);
#else
	TraceAttack_SetRangeModifier(1.875); /* 14 but not 15 */
	TraceAttack_SetPenetrationPower(1);
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 25, [accuracy,accuracy], WEAPON_FIVESEVEN);
	Sound_Play(pl, CHAN_WEAPON, "weapon_fiveseven.fire");
#endif

	pl.gflags |= GF_SEMI_TOGGLED;
	pl.w_attack_next = 0.15f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_fiveseven_reload(player pl)
{

	if (pl.w_attack_next > 0.0)
		return;
	if (pl.fiveseven_mag >= 20)
		return;
	if (!pl.ammo_57mm)
		return;

	Weapons_ViewAnimation(pl, FIVESEVEN_RELOAD);

#ifdef SERVER
	Weapons_ReloadWeapon(pl, player::fiveseven_mag, player::ammo_57mm, 20);
#endif

	pl.w_attack_next = 3.1f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_fiveseven_release(player pl)
{

	w_cstrike_weaponrelease();

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.fiveseven_mag == 0 && pl.ammo_57mm > 0) {
		Weapons_Reload(pl);
		return;
	}
}

float
w_fiveseven_aimanim(player pl)
{
	return self.flags & FL_CROUCHING ? ANIM_CROUCH_AIM_ONEHAND : ANIM_AIM_ONEHAND;
}

void
w_fiveseven_hud(player pl)
{
#ifdef CLIENT
	Cstrike_DrawCrosshair();
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [120/256,96/256], [24/256, 24/256], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

int
w_fiveseven_isempty(player pl)
{

	if (pl.fiveseven_mag <= 0 && pl.ammo_57mm <= 0)
		return 1;

	return 0;
}

void
w_fiveseven_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (w_fiveseven_isempty(pl))
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
			a,
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
			a,
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
	.weight		= 5,
	.allow_drop	= TRUE,
	.draw		= w_fiveseven_draw,
	.holster	= __NULL__,
	.primary	= w_fiveseven_primary,
	.secondary	= __NULL__,
	.reload		= w_fiveseven_reload,
	.release	= w_fiveseven_release,
	.postdraw	= w_fiveseven_hud,
	.precache	= w_fiveseven_precache,
	.pickup		= w_fiveseven_pickup,
	.updateammo	= w_fiveseven_updateammo,
	.wmodel		= w_fiveseven_wmodel,
	.pmodel		= w_fiveseven_pmodel,
	.deathmsg	= w_fiveseven_deathmsg,
	.aimanim	= w_fiveseven_aimanim,
	.hudpic		= w_fiveseven_hudpic,
	.type		= csweapon_ranged_type,
	.isempty	= w_fiveseven_isempty
};

#ifdef SERVER
void
weapon_fiveseven(void)
{
	Weapons_InitItem(WEAPON_FIVESEVEN);
}
#endif
