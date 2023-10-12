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

/*!QUAKED weapon_m4a1 (0 0 1) (-16 -16 0) (16 16 32)

COUNTER-STRIKE (1999) ENTITY

Colt M4A1 Carbine Weapon

- Buy Menu -
Price: $3100
Counter-Terrorists only weapon

-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
model="models/w_m4a1.mdl"
*/

enum
{
	M4A1_IDLE,
	M4A1_SHOOT1,
	M4A1_SHOOT2,
	M4A1_SHOOT3,
	M4A1_RELOAD,
	M4A1_DRAW,
	M4A1_ADDSIL,
	M4A1_IDLEUNSIL,
	M4A1_SHOOT1UNSIL,
	M4A1_SHOOT2UNSIL,
	M4A1_SHOOT3UNSIL,
	M4A1_RELOADUNSIL,
	M4A1_DRAWUNSIL,
	M4A1_DETACHSIL
};

void
w_m4a1_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_m4a1.fire");
	Sound_Precache("weapon_m4a1.silenced");
	precache_model("models/w_m4a1.mdl");
#else
	precache_model("models/v_m4a1.mdl");
	precache_model("models/p_m4a1.mdl");
#endif
}

void
w_m4a1_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.m4a1_mag, pl.ammo_556mm, -1);
}

string
w_m4a1_wmodel(void)
{
	return "models/w_m4a1.mdl";
}

string
w_m4a1_pmodel(player pl)
{
	return "models/p_m4a1.mdl";
}

string
w_m4a1_deathmsg(void)
{
	return "";
}

int
w_m4a1_pickup(player pl, int new, int startammo)
{
#ifdef SERVER
	Cstrike_ShotMultiplierUpdate(pl);
	if (new) {
		if (startammo == -1)
			pl.m4a1_mag = 30;
		else
			pl.m4a1_mag = startammo;
	} else {
		if (pl.ammo_556mm < AMMO_MAX_556MM) {
			pl.ammo_556mm = bound(0, pl.ammo_556mm + 30, AMMO_MAX_556MM);
		} else {
			return (0);
		}
	}
#endif
	return (1);
}

void
w_m4a1_draw(player pl)
{
	
	Weapons_SetModel("models/v_m4a1.mdl");
	
	if (pl.mode_m4a1 == 1) {
		Weapons_ViewAnimation(pl, M4A1_DRAW);
	} else {
		Weapons_ViewAnimation(pl, M4A1_DRAWUNSIL);
	}

#ifdef CLIENT
	pl.cs_cross_mindist = 4;
	pl.cs_cross_deltadist = 3;
	CStrikeView_UpdateGeomset(pl);
#endif
}

void
w_m4a1_primary(player pl)
{
	int dmg = 0;

	if (pl.w_attack_next > 0.0) {
		return;
	}
	if (!pl.m4a1_mag) {
		return;
	}


	float accuracy = Cstrike_CalculateAccuracy(pl, 60, 3);
//	accuracy += pl.cs_shotmultiplier*pl.cs_shotmultiplier / 500;
	pl.m4a1_mag--;

	int r = (float)input_sequence % 3;
	if (pl.mode_m4a1 == 1) {
		switch (r) {
		case 0:
			Weapons_ViewAnimation(pl, M4A1_SHOOT1);
			break;
		case 1:
			Weapons_ViewAnimation(pl, M4A1_SHOOT2);
			break;
		default:
			Weapons_ViewAnimation(pl, M4A1_SHOOT3);
			break;
		}
	} else {
		switch (r) {
		case 0:
			Weapons_ViewAnimation(pl, M4A1_SHOOT1UNSIL);
			break;
		case 1:
			Weapons_ViewAnimation(pl, M4A1_SHOOT2UNSIL);
			break;
		default:
			Weapons_ViewAnimation(pl, M4A1_SHOOT3UNSIL);
			break;
		}
	}

	if (pl.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_SHOOT_RIFLE, 0.45f);
	else
		Animation_PlayerTop(pl, ANIM_CROUCH_SHOOT_RIFLE, 0.45f);

	/* actual firing */
#ifdef CLIENT
	if (pl.mode_m4a1 == 1) {
		View_SetMuzzleflash(0);
	} else {
		View_SetMuzzleflash(MUZZLE_RIFLE);
	}
	View_AddEvent(w_rifle_ejectshell, 0.0f);
#else
	/* Different sounds without silencer */
	if (pl.mode_m4a1 == 1) {
		Sound_Play(pl, CHAN_WEAPON, "weapon_m4a1.silenced");
	} else {
		Sound_Play(pl, CHAN_WEAPON, "weapon_m4a1.fire");
	}

	dmg = Skill_GetValue("plr_m4a1_dmg", 33);
	TraceAttack_SetRangeModifier(2.125);
	TraceAttack_SetPenetrationPower(1);
	Cstrike_BulletRecoil_ApplyPre(pl,.96f);
	TraceAttack_FireBulletsWithDecal(1, pl.origin + pl.view_ofs, dmg,  [accuracy,accuracy], WEAPON_M4A1, "Impact.BigShot");
	Cstrike_BulletRecoil_ApplyPost(pl,.96f);
#endif

	Cstrike_ShotMultiplierAdd(pl, 0.8f, 1.025f,accuracy*0.8);
	pl.w_attack_next = 0.0875f;
	pl.w_idle_next = 2.0f;
}

void
w_m4a1_secondary(player pl)
{

	if (pl.w_attack_next > 0) {
		return;
	}

	/* toggle silencer */
	pl.mode_m4a1 = 1 - pl.mode_m4a1;

	/* play the animation */
	if (pl.mode_m4a1) {
		Weapons_ViewAnimation(pl, M4A1_ADDSIL);
	} else {
		Weapons_ViewAnimation(pl, M4A1_DETACHSIL);
	}

	pl.w_attack_next = 2.0f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_m4a1_reload(player pl)
{

	if (pl.w_attack_next > 0.0)
		return;
	if (pl.m4a1_mag >= 30)
		return;
	if (!pl.ammo_556mm)
		return;
	Cstrike_ShotMultiplierUpdate(pl);

	if (pl.mode_m4a1 == 1)
		Weapons_ViewAnimation(pl, M4A1_RELOAD);
	else
		Weapons_ViewAnimation(pl, M4A1_RELOADUNSIL);

	pl.w_attack_next = 3.1f;
	pl.w_idle_next = pl.w_attack_next;

#ifdef SERVER
	static void w_weapon_reload_done(void) {
		player pl = (player)self;
		Weapons_ReloadWeapon(pl, player::m4a1_mag, player::ammo_556mm, 30);
		Cstrike_ShotReset(pl);
	}
	
	pl.think = w_weapon_reload_done;
	pl.nextthink = time + pl.w_attack_next - 0.1f;
#endif
}

float
w_m4a1_aimanim(player pl)
{
	return pl.flags & FL_CROUCHING ? ANIM_CROUCH_AIM_RIFLE : ANIM_AIM_RIFLE;
}

void
w_m4a1_hud(player pl)
{
#ifdef CLIENT
	Cstrike_DrawCrosshair();
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [0,96/256], [24/256, 24/256], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_m4a1_release(player pl)
{

	w_cstrike_weaponrelease();

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.m4a1_mag == 0 && pl.ammo_556mm > 0) {
		Weapons_Reload(pl);
		return;
	}

	if (pl.w_idle_next > 0.0) {
		return;
	}

	if (pl.mode_m4a1) {
		Weapons_ViewAnimation(pl, M4A1_IDLE);
	} else {
		Weapons_ViewAnimation(pl, M4A1_IDLEUNSIL);
	}
	pl.w_idle_next = 5.0f;
}

int
w_m4a1_isempty(player pl)
{

	if (pl.m4a1_mag <= 0 && pl.ammo_556mm <= 0)
		return 1;

	return 0;
}

void
w_m4a1_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (w_m4a1_isempty(pl))
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_556mm, AMMO_MAX_556MM, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud5_spr,
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
			g_hud2_spr,
			[0,45/256],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_m4a1 =
{
	.name		= "m4a1",
	.id		= ITEM_M4A1,
	.slot		= 0,
	.slot_pos	= 9,
	.weight		= 25,
	.allow_drop 	= TRUE,
	.draw		= w_m4a1_draw,
	.holster	= __NULL__,
	.primary	= w_m4a1_primary,
	.secondary	= w_m4a1_secondary,
	.reload		= w_m4a1_reload,
	.release	= w_m4a1_release,
	.postdraw	= w_m4a1_hud,
	.precache	= w_m4a1_precache,
	.pickup		= w_m4a1_pickup,
	.updateammo	= w_m4a1_updateammo,
	.wmodel		= w_m4a1_wmodel,
	.pmodel		= w_m4a1_pmodel,
	.deathmsg	= w_m4a1_deathmsg,
	.aimanim	= w_m4a1_aimanim,
	.hudpic		= w_m4a1_hudpic,
	.type		= csweapon_ranged_type,
	.isempty	= w_m4a1_isempty
};

#ifdef SERVER
void
weapon_m4a1(void)
{
	Weapons_InitItem(WEAPON_M4A1);
}
#endif
