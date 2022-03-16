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

/*QUAKED weapon_g3sg1 (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_g3sg1.mdl"

COUNTER-STRIKE (1999) ENTITY

Heckler & Koch G3/SG-1 Weapon

- Buy Menu -
Price: $5000

*/

enum
{
	G3SG1_IDLE,
	G3SG1_SHOOT1,
	G3SG1_SHOOT2,
	G3SG1_RELOAD,
	G3SG1_DRAW
};

void
w_g3sg1_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_g3sg1.fire");
	precache_model("models/w_g3sg1.mdl");
#else
	precache_model("models/v_g3sg1.mdl");
	precache_model("models/p_g3sg1.mdl");
#endif
}

void
w_g3sg1_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.g3sg1_mag, pl.ammo_762mm, -1);
}

string
w_g3sg1_wmodel(void)
{
	return "models/w_g3sg1.mdl";
}

string
w_g3sg1_pmodel(void)
{
	return "models/p_g3sg1.mdl";
}

string
w_g3sg1_deathmsg(void)
{
	return "";
}

int
w_g3sg1_pickup(player pl, int new, int startammo)
{
#ifdef SERVER

	if (new) {
		if (startammo == -1)
			pl.g3sg1_mag = 20;
		else
			pl.g3sg1_mag = startammo;
	} else {
		if (pl.ammo_762mm < AMMO_MAX_762MM) {
			pl.ammo_762mm = bound(0, pl.ammo_762mm + 20, AMMO_MAX_762MM);
		} else {
			return (0);
		}
	}
#endif
	return (1);
}

void
w_g3sg1_draw(player pl)
{
	Weapons_SetModel("models/v_g3sg1.mdl");
	Weapons_ViewAnimation(pl, G3SG1_DRAW);

#ifdef CLIENT
	pl.cs_cross_mindist = 6;
	pl.cs_cross_deltadist = 4;
#endif
}

void
w_g3sg1_primary(player pl)
{

	if (pl.w_attack_next > 0.0) {
		return;
	}
	if (!pl.g3sg1_mag) {
		return;
	}

	Cstrike_ShotMultiplierAdd(pl, 1);
	float accuracy = Cstrike_CalculateAccuracy(pl, 200);
	pl.g3sg1_mag--;

	int r = (float)input_sequence % 2;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(pl, SCOUT_SHOOT1);
		break;
	default:
		Weapons_ViewAnimation(pl, SCOUT_SHOOT2);
		break;
	}

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_SHOOT_RIFLE, 0.45f);
	else
		Animation_PlayerTop(pl, ANIM_CROUCH_SHOOT_RIFLE, 0.45f);

#ifdef CLIENT
	View_SetMuzzleflash(MUZZLE_RIFLE);
	View_AddEvent(w_rifle_ejectshell, 0.0f);
#else
	TraceAttack_SetPenetrationPower(2);
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 80, [accuracy,accuracy], WEAPON_G3SG1);
	Sound_Play(pl, CHAN_WEAPON, "weapon_g3sg1.fire");
#endif

	pl.w_attack_next = 0.25f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_g3sg1_secondary(player pl)
{
	if (pl.w_attack_next) {
		return;
	}
	/* Simple toggle of fovs */
	if (pl.viewzoom == 1.0f) {
		pl.viewzoom = 0.45f;
		Weapons_DisableModel();
	} else if (pl.viewzoom == 0.45f) {
		pl.viewzoom = 0.1f;
		Weapons_DisableModel();
	} else {
		pl.viewzoom = 1.0f;
		Weapons_EnableModel();
	}
	pl.w_attack_next = 0.5f;
}

void
w_g3sg1_reload(player pl)
{

	if (pl.w_attack_next > 0.0)
		return;
	if (pl.g3sg1_mag >= 20)
		return;
	if (!pl.ammo_762mm)
		return;

	Weapons_ViewAnimation(pl, G3SG1_RELOAD);

#ifdef SERVER
	Weapons_ReloadWeapon(pl, player::g3sg1_mag, player::ammo_762mm, 20);
	Weapons_UpdateAmmo(pl, pl.g3sg1_mag, pl.ammo_762mm, -1);
#endif

	pl.w_attack_next = 4.6f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_g3sg1_release(player pl)
{

	w_cstrike_weaponrelease();

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.g3sg1_mag == 0 && pl.ammo_762mm > 0) {
		Weapons_Reload(pl);
		return;
	}
}

float
w_g3sg1_aimanim(player pl)
{
	return w_ak47_aimanim(pl);
}

void
w_g3sg1_hud(player pl)
{
#ifdef CLIENT
	if (pl.viewzoom < 1.0f) {
		Cstrike_DrawScope();
	}
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [72/256,72/256], [24/256, 24/256], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

int
w_g3sg1_isempty(player pl)
{

	if (pl.g3sg1_mag <= 0 && pl.ammo_762mm <= 0)
		return 1;

	return 0;
}

void
w_g3sg1_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (w_g3sg1_isempty(pl))
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_762mm, AMMO_MAX_762MM, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud5_spr,
			[0,180/256],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			g_hud2_spr,
			[0,180/256],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_g3sg1 =
{
	.name		= "g3sg1",
	.id		= ITEM_G3SG1,
	.slot		= 0,
	.slot_pos	= 13,
	.weight		= 25,
	.allow_drop	= TRUE,
	.draw		= w_g3sg1_draw,
	.holster	= __NULL__,
	.primary	= w_g3sg1_primary,
	.secondary	= w_g3sg1_secondary,
	.reload		= w_g3sg1_reload,
	.release	= w_g3sg1_release,
	.postdraw	= w_g3sg1_hud,
	.precache	= w_g3sg1_precache,
	.pickup		= w_g3sg1_pickup,
	.updateammo	= w_g3sg1_updateammo,
	.wmodel		= w_g3sg1_wmodel,
	.pmodel		= w_g3sg1_pmodel,
	.deathmsg	= w_g3sg1_deathmsg,
	.aimanim	= w_g3sg1_aimanim,
	.hudpic		= w_g3sg1_hudpic,
	.type		= csweapon_ranged_type,
	.isempty	= w_g3sg1_isempty
};

#ifdef SERVER
void
weapon_g3sg1(void)
{
	Weapons_InitItem(WEAPON_G3SG1);
}
#endif
