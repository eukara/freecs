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

/*QUAKED weapon_tmp (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_tmp.mdl"

COUNTER-STRIKE (1999) ENTITY

Steyr Tactical Weapon

- Buy Menu -
Price: $1250

*/

enum
{
	TMP_IDLE,
	TMP_RELOAD,
	TMP_DRAW,
	TMP_SHOOT1,
	TMP_SHOOT2,
	TMP_SHOOT3
};

void
w_tmp_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_tmp.fire");
	precache_model("models/w_tmp.mdl");
#else
	precache_model("models/v_tmp.mdl");
	precache_model("models/p_tmp.mdl");
#endif
}

void
w_tmp_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.tmp_mag, pl.ammo_9mm, -1);
}

string
w_tmp_wmodel(void)
{
	return "models/w_tmp.mdl";
}

string
w_tmp_pmodel(player pl)
{
	return "models/p_tmp.mdl";
}

string
w_tmp_deathmsg(void)
{
	return "";
}

int
w_tmp_pickup(player pl, int new, int startammo)
{
#ifdef SERVER

	if (new) {
		if (startammo == -1)
			pl.tmp_mag = 30;
		else
			pl.tmp_mag = startammo;
	} else {
		if (pl.ammo_9mm < AMMO_MAX_9MM) {
			pl.ammo_9mm = bound(0, pl.ammo_9mm + 30, AMMO_MAX_9MM);
		} else {
			return (0);
		}
	}
#endif
	return (1);
}

void
w_tmp_draw(player pl)
{
	Weapons_SetModel("models/v_tmp.mdl");
	Weapons_ViewAnimation(pl, TMP_DRAW);

#ifdef CLIENT
	pl.cs_cross_mindist = 7;
	pl.cs_cross_deltadist = 3;
#endif
}

void
w_tmp_primary(player pl)
{
	int dmg = 0;

	if (pl.w_attack_next > 0.0)
		return;
	if (!pl.tmp_mag)
		return;

	Cstrike_ShotMultiplierAdd(pl, 1);
	float accuracy = Cstrike_CalculateAccuracy(pl, 200);
	pl.tmp_mag--;

	int r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(pl, TMP_SHOOT1);
		break;
	case 1:
		Weapons_ViewAnimation(pl, TMP_SHOOT2);
		break;
	default:
		Weapons_ViewAnimation(pl, TMP_SHOOT3);
		break;
	}

	if (pl.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_SHOOT_MP5, 0.45f);
	else
		Animation_PlayerTop(pl, ANIM_CROUCH_SHOOT_MP5, 0.45f);

#ifdef CLIENT
	View_SetMuzzleflash(MUZZLE_RIFLE);
	View_AddEvent(w_pistol_ejectshell, 0.0f);
#else
	dmg = Skill_GetValue("plr_tmp_dmg", 26);
	TraceAttack_SetRangeModifier(1.25); /* 9 but not 10 */
	TraceAttack_SetPenetrationPower(1);
	TraceAttack_FireBulletsWithDecal(1, pl.origin + pl.view_ofs, dmg, [accuracy,accuracy], WEAPON_TMP, "Impact.BigShot");
	Sound_Play(pl, CHAN_WEAPON, "weapon_tmp.fire");
#endif

	pl.w_attack_next = 0.07f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_tmp_reload(player pl)
{

	if (pl.w_attack_next > 0.0)
		return;
	if (pl.tmp_mag >= 30)
		return;
	if (!pl.ammo_9mm)
		return;

	Weapons_ViewAnimation(pl, TMP_RELOAD);

	pl.w_attack_next = 2.1f;
	pl.w_idle_next = pl.w_attack_next;

#ifdef SERVER
	static void w_weapon_reload_done(void) {
		player pl = (player)self;
		Weapons_ReloadWeapon(pl, player::tmp_mag, player::ammo_9mm, 30);
	}

	pl.think = w_weapon_reload_done;
	pl.nextthink = time + pl.w_attack_next - 0.1f;
#endif
}

void
w_tmp_release(player pl)
{

	w_cstrike_weaponrelease();

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.tmp_mag == 0 && pl.ammo_9mm > 0) {
		Weapons_Reload(pl);
		return;
	}
}

float
w_tmp_aimanim(player pl)
{
	return w_ak47_aimanim(pl);
}

void
w_tmp_hud(player pl)
{
#ifdef CLIENT
	Cstrike_DrawCrosshair();
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [48/256,72/256], [24/256, 24/256], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

int
w_tmp_isempty(player pl)
{

	if (pl.tmp_mag <= 0 && pl.ammo_9mm <= 0)
		return 1;

	return 0;
}

void
w_tmp_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (w_tmp_isempty(pl))
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_9mm, AMMO_MAX_9MM, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud5_spr,
			[0,0],
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
			[0,0],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_tmp =
{
	.name		= "tmp",
	.id		= ITEM_TMP,
	.slot		= 0,
	.slot_pos	= 6,
	.weight		= 25,
	.allow_drop	= TRUE,
	.draw		= w_tmp_draw,
	.holster	= __NULL__,
	.primary	= w_tmp_primary,
	.secondary	= __NULL__,
	.reload		= w_tmp_reload,
	.release	= w_tmp_release,
	.postdraw	= w_tmp_hud,
	.precache	= w_tmp_precache,
	.pickup		= w_tmp_pickup,
	.updateammo	= w_tmp_updateammo,
	.wmodel		= w_tmp_wmodel,
	.pmodel		= w_tmp_pmodel,
	.deathmsg	= w_tmp_deathmsg,
	.aimanim	= w_tmp_aimanim,
	.hudpic		= w_tmp_hudpic,
	.type		= csweapon_ranged_type,
	.isempty	= w_tmp_isempty
};

#ifdef SERVER
void
weapon_tmp(void)
{
	Weapons_InitItem(WEAPON_TMP);
}
#endif
