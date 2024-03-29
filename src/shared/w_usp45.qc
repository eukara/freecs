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

/*!QUAKED weapon_usp45 (0 0 1) (-16 -16 0) (16 16 32)

COUNTER-STRIKE (1999) ENTITY

Heckler & Koch USP .45 Tactical Weapon

Default arsenal for Counter-Terrorists

- Buy Menu -
Price: $500

-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
model="models/w_usp45.mdl"
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
w_usp45_pmodel(player pl)
{
	return "models/p_usp.mdl";
}

string
w_usp45_deathmsg(void)
{
	return "";
}

int
w_usp45_pickup(player pl, int new, int startammo)
{
#ifdef SERVER

	if (new) {
		if (startammo == -1)
			pl.usp45_mag = 12;
		else
			pl.usp45_mag = startammo;
	} else {
		if (pl.ammo_45acp < AMMO_MAX_45ACP) {
			pl.ammo_45acp = bound(0, pl.ammo_45acp + 12, AMMO_MAX_45ACP);
		} else {
			return (0);
		}
	}
#endif
	return (1);
}

void
w_usp45_draw(player pl)
{
	
	Weapons_SetModel("models/v_usp.mdl");
	if (pl.mode_usp45 == 1) {
		Weapons_ViewAnimation(pl, USP45_DRAW);
	} else {
		Weapons_ViewAnimation(pl, USP45_DRAWUNSIL);
	}

#ifdef CLIENT
	pl.cs_cross_mindist = 8;
	pl.cs_cross_deltadist = 3;
	CStrikeView_UpdateGeomset(pl);
#endif
}

void
w_usp45_primary(player pl)
{

	if (pl.w_attack_next > 0.0)
		return;
	if (pl.gflags & GF_SEMI_TOGGLED)
		return;
	if (!pl.usp45_mag)
		return;


	float accuracy = Cstrike_CalculateAccuracy(pl,25,2.2);
	int dmg = 0;
	pl.usp45_mag--;

	/* this stuff is predicted */
	int r = (float)input_sequence % 3;
	if (pl.mode_usp45 == 1) {
		if (pl.usp45_mag <= 0) {
			Weapons_ViewAnimation(pl, USP45_SHOOTLAST);
		} else {
			switch (r) {
			case 0:
				Weapons_ViewAnimation(pl, USP45_SHOOT1);
				break;
			case 1:
				Weapons_ViewAnimation(pl, USP45_SHOOT2);
				break;
			default:
				Weapons_ViewAnimation(pl, USP45_SHOOT3);
				break;
			}
		}
	} else {
		if (pl.usp45_mag <= 0) {
			Weapons_ViewAnimation(pl, USP45_SHOOTLASTUNSIL);
		} else {
			switch (r) {
			case 0:
				Weapons_ViewAnimation(pl, USP45_SHOOT1UNSIL);
				break;
			case 1:
				Weapons_ViewAnimation(pl, USP45_SHOOT2UNSIL);
				break;
			default:
				Weapons_ViewAnimation(pl, USP45_SHOOT3UNSIL);
				break;
			}
		}
	}

	if (pl.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_SHOOT_ONEHAND, 0.45f);
	else
		Animation_PlayerTop(pl, ANIM_CROUCH_SHOOT_ONEHAND, 0.45f);

#ifdef CLIENT
	View_SetMuzzleflash(MUZZLE_SMALL);
	View_AddEvent(w_pistol_ejectshell, 0.0f);
#else
	/* Different sounds without silencer */
	if (pl.mode_usp45 == 1) {
		Sound_Play(pl, CHAN_WEAPON, "weapon_usp45.silenced");
	} else {
		Sound_Play(pl, CHAN_WEAPON, "weapon_usp45.fire");
	}

	/* actual firing */
	dmg = Skill_GetValue("plr_usp45_dmg", 33);
	TraceAttack_SetRangeModifier(0.79); /* can penetrate 6 but not 7 units */
	TraceAttack_SetPenetrationPower(1);
	Cstrike_BulletRecoil_ApplyPre(pl,0.625);
	TraceAttack_FireBulletsWithDecal(1, pl.origin + pl.view_ofs, dmg,  [accuracy,accuracy], WEAPON_USP45, "Impact.BigShot");
	Cstrike_BulletRecoil_ApplyPost(pl,0.625);
#endif
	Cstrike_ShotMultiplierAdd(pl, 2.5, .5,accuracy*0.5);

	pl.gflags |= GF_SEMI_TOGGLED;
	pl.w_attack_next = 0.15f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_usp45_secondary(player pl)
{

	if (pl.w_attack_next > 0)
		return;

	/* toggle silencer */
	pl.mode_usp45 = 1 - pl.mode_usp45;

	/* play the animation */
	if (pl.mode_usp45)
		Weapons_ViewAnimation(pl, USP45_ADDSIL);
	else
		Weapons_ViewAnimation(pl, USP45_DETACHSIL);

	pl.w_attack_next = 3.1f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_usp45_reload(player pl)
{

	if (pl.w_attack_next > 0.0)
		return;
	if (pl.usp45_mag >= 12)
		return;
	if (!pl.ammo_45acp)
		return;

	if (pl.mode_usp45 == 1)
		Weapons_ViewAnimation(pl, USP45_RELOAD);
	else
		Weapons_ViewAnimation(pl, USP45_RELOADUNSIL);

	pl.w_attack_next = 2.5f;
	pl.w_idle_next = pl.w_attack_next;

#ifdef SERVER
	static void w_weapon_reload_done(void) {
		player pl = (player)self;
		Weapons_ReloadWeapon(pl, player::usp45_mag, player::ammo_45acp, 12);
		Cstrike_ShotReset(pl);
	}

	pl.think = w_weapon_reload_done;
	pl.nextthink = time + pl.w_attack_next - 0.1f;
#endif
}

void
w_usp45_release(player pl)
{

	w_cstrike_weaponrelease();

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.usp45_mag == 0 && pl.ammo_45acp > 0) {
		Weapons_Reload(pl);
		return;
	}
}

float
w_usp45_aimanim(player pl)
{
	return w_deagle_aimanim(pl);
}

void
w_usp45_hud(player pl)
{
#ifdef CLIENT
	Cstrike_DrawCrosshair();
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [96/256,72/256], [24/256, 24/256], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

int
w_usp45_isempty(player pl)
{

	if (pl.usp45_mag <= 0 && pl.ammo_45acp <= 0)
		return 1;

	return 0;
}

void
w_usp45_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (w_usp45_isempty(pl))
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
			a,
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
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_usp45 =
{
	.name		= "usp",
	.id			= ITEM_USP45,
	.slot		= 1,
	.slot_pos	= 0,
	.weight		= 5,
	.allow_drop	= TRUE,
	.draw		= w_usp45_draw,
	.holster	= __NULL__,
	.primary	= w_usp45_primary,
	.secondary	= w_usp45_secondary,
	.reload		= w_usp45_reload,
	.release	= w_usp45_release,
	.postdraw	= w_usp45_hud,
	.precache	= w_usp45_precache,
	.pickup		= w_usp45_pickup,
	.updateammo	= w_usp45_updateammo,
	.wmodel		= w_usp45_wmodel,
	.pmodel		= w_usp45_pmodel,
	.deathmsg	= w_usp45_deathmsg,
	.aimanim	= w_usp45_aimanim,
	.hudpic		= w_usp45_hudpic,
	.type		= csweapon_ranged_type,
	.isempty	= w_usp45_isempty
};

#ifdef SERVER
void
weapon_usp45(void)
{
	Weapons_InitItem(WEAPON_USP45);
}
#endif
