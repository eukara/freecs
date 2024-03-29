/*
 * Copyright (c) 2016-2022 Marco Cawthorne <marco@icculus.org>
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

/*!QUAKED weapon_aug (0 0 1) (-16 -16 0) (16 16 32)

COUNTER-STRIKE (1999) ENTITY

Steyr AUG Weapon

- Buy Menu -
Price: $3500
Counter-Terrorists only weapon

-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
model="models/w_aug.mdl"
*/

enum
{
	AUG_IDLE,
	AUG_RELOAD,
	AUG_DRAW,
	AUG_SHOOT1,
	AUG_SHOOT2,
	AUG_SHOOT3
};

void
w_aug_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_aug.fire");
	precache_model("models/w_aug.mdl");
#else
	precache_model("models/v_aug.mdl");
	precache_model("models/p_aug.mdl");
#endif
}

void
w_aug_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.aug_mag, pl.ammo_762mm, -1);
}

string
w_aug_wmodel(void)
{
	return "models/w_aug.mdl";
}

string
w_aug_pmodel(player pl)
{
	return "models/p_aug.mdl";
}

string
w_aug_deathmsg(void)
{
	return "";
}

int
w_aug_pickup(player pl, int new, int startammo)
{
#ifdef SERVER

	if (new) {
		if (startammo == -1)
			pl.aug_mag = 30;
		else
			pl.aug_mag = startammo;
	} else {
		if (pl.ammo_762mm < AMMO_MAX_762MM) {
			pl.ammo_762mm = bound(0, pl.ammo_762mm + 30, AMMO_MAX_762MM);
		} else {
			return (0);
		}
	}
#endif
	return (1);
}

void
w_aug_draw(player pl)
{
	Weapons_SetModel("models/v_aug.mdl");
	Weapons_ViewAnimation(pl, AUG_DRAW);

#ifdef CLIENT
	pl.cs_cross_mindist = 3;
	pl.cs_cross_deltadist = 3;
	CStrikeView_UpdateGeomset(pl);
#endif
}

void
w_aug_primary(player pl)
{
	int dmg = 0;

	if (pl.w_attack_next > 0.0) {
		return;
	}
	if (!pl.aug_mag) {
		return;
	}


	float accuracy = Cstrike_CalculateAccuracy(pl, 35,2);
	pl.aug_mag--;

	int r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(pl, AUG_SHOOT1);
		break;
	case 1:
		Weapons_ViewAnimation(pl, AUG_SHOOT2);
		break;
	default:
		Weapons_ViewAnimation(pl, AUG_SHOOT3);
		break;
	}

	if (pl.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_SHOOT_RIFLE, 0.45f);
	else
		Animation_PlayerTop(pl, ANIM_CROUCH_SHOOT_RIFLE, 0.45f);

#ifdef CLIENT
	View_SetMuzzleflash(MUZZLE_RIFLE);
	View_AddEvent(w_rifle_ejectshell, 0.0f);
#else
	dmg = Skill_GetValue("plr_aug_dmg", 32);
	TraceAttack_SetRangeModifier(2.125);
	TraceAttack_SetPenetrationPower(1);
	Cstrike_BulletRecoil_ApplyPre(pl,1.03);
	TraceAttack_FireBulletsWithDecal(1, pl.origin + pl.view_ofs, dmg, [accuracy,accuracy], WEAPON_AUG, "Impact.BigShot");
	Cstrike_BulletRecoil_ApplyPost(pl,1.03);
	Sound_Play(pl, CHAN_WEAPON, "weapon_aug.fire");
#endif

	Cstrike_ShotMultiplierAdd(pl, 0.7f, 1.1f,accuracy);
	if (pl.viewzoom == 1.0f) {
		pl.w_attack_next = 0.0825f;
	} else {
		pl.w_attack_next = 0.15f;
	}
	pl.w_idle_next = pl.w_attack_next;
}

void
w_aug_secondary(player pl)
{
	if (pl.w_attack_next) {
		return;
	}
	/* Simple toggle of fovs */
	if (pl.viewzoom == 1.0f) {
		pl.viewzoom = 0.2f;
	} else {
		pl.viewzoom = 1.0f;
	}
	pl.w_attack_next = 0.5f;
}

void
w_aug_reload(player pl)
{

	if (pl.w_attack_next > 0.0) {
		return;
	}
	if (pl.aug_mag >= 30) {
		return;
	}
	if (!pl.ammo_762mm) {
		return;
	}
	Weapons_ViewAnimation(pl, AUG_RELOAD);
	pl.w_attack_next = 3.3f;
	pl.w_idle_next = pl.w_attack_next;

#ifdef SERVER
	static void w_weapon_reload_done(void) {
		player pl = (player)self;
		Weapons_ReloadWeapon(pl, player::aug_mag, player::ammo_762mm, 30);
		Cstrike_ShotReset(pl);
	}

	pl.think = w_weapon_reload_done;
	pl.nextthink = time + pl.w_attack_next - 0.1f;
#endif
}

void
w_aug_release(player pl)
{

	w_cstrike_weaponrelease();

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.aug_mag == 0 && pl.ammo_762mm > 0) {
		Weapons_Reload(pl);
		return;
	}
}

float
w_aug_aimanim(player pl)
{
	return w_ak47_aimanim(pl);
}

void
w_aug_hud(player pl)
{
#ifdef CLIENT
	if (pl.viewzoom == 1.0f) {
		Cstrike_DrawCrosshair();
	} else {
		Cstrike_DrawSimpleCrosshair();
	}
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [72/256,72/256], [24/256, 24/256], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

int
w_aug_isempty(player pl)
{

	if (pl.aug_mag <= 0 && pl.ammo_762mm <= 0)
		return 1;

	return 0;
}

void
w_aug_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (w_aug_isempty(pl))
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_762mm, AMMO_MAX_762MM, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud15_spr,
			[0,45/256],
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
			[0,45/256],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_aug =
{
	.name		= "aug",
	.id		= ITEM_AUG,
	.slot		= 0,
	.slot_pos	= 10,
	.weight		= 25,
	.allow_drop	= TRUE,
	.draw		= w_aug_draw,
	.holster	= __NULL__,
	.primary	= w_aug_primary,
	.secondary	= w_aug_secondary,
	.reload		= w_aug_reload,
	.release	= w_aug_release,
	.postdraw	= w_aug_hud,
	.precache	= w_aug_precache,
	.pickup		= w_aug_pickup,
	.updateammo	= w_aug_updateammo,
	.wmodel		= w_aug_wmodel,
	.pmodel		= w_aug_pmodel,
	.deathmsg	= w_aug_deathmsg,
	.aimanim	= w_aug_aimanim,
	.hudpic		= w_aug_hudpic,
	.type		= csweapon_ranged_type,
	.isempty	= w_aug_isempty
};

#ifdef SERVER
void
weapon_aug(void)
{
	Weapons_InitItem(WEAPON_AUG);
}
#endif
