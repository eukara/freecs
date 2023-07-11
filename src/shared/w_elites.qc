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

/*!QUAKED weapon_elites (0 0 1) (-16 -16 0) (16 16 32)

COUNTER-STRIKE (1999) ENTITY

Dual Beretta 96G (Elites) Weapon

- Buy Menu -
Price: $1000

-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
model="models/w_elite.mdl"
*/

#ifdef CLIENT
void
w_elites_ejectshell(int side)
{
	static void w_elites_ejectshell_death(void) {
		remove(self);
	}
	static void w_elites_ejectshell_touch(void) {
		if (other == world)
			Sound_Play(self, CHAN_BODY, "modelevent_shell.land");
	}
	entity eShell = spawn();
	setmodel(eShell, "models/pshell.mdl");
	eShell.solid = SOLID_BBOX;
	eShell.movetype = MOVETYPE_BOUNCE;
	eShell.drawmask = MASK_ENGINE;
	eShell.angles = [pSeat->m_eViewModel.angles[0], pSeat->m_eViewModel.angles[1], 0];
	eShell.velocity = pSeat->m_vecPredictedVelocity;

	makevectors(pSeat->m_eViewModel.angles);
	eShell.velocity += (v_forward * 0);
	eShell.velocity += (v_right * -80);
	eShell.velocity += (v_up * 100);
	eShell.touch = w_elites_ejectshell_touch;

	eShell.avelocity = [0,45,900];
	eShell.think = w_elites_ejectshell_death;
	eShell.nextthink = time + 2.5f;
	setsize(eShell, [0,0,0], [0,0,0]);
	setorigin(eShell, gettaginfo(pSeat->m_eViewModel, pSeat->m_iVMBones + 1 + side));
}

void
w_pistol_ejectshell_left(void)
{
	w_elites_ejectshell(1);
}

void
w_pistol_ejectshell_right(void)
{
	w_elites_ejectshell(0);
}
#endif

enum
{
	ELITES_IDLE,
	ELITES_IDLE_LEFTEMPTY,
	ELITES_SHOOT_LEFT1,
	ELITES_SHOOT_LEFT2,
	ELITES_SHOOT_LEFT3,
	ELITES_SHOOT_LEFT4,
	ELITES_SHOOT_LEFT5,
	ELITES_SHOOT_LEFTLAST,
	ELITES_SHOOT_RIGHT1,
	ELITES_SHOOT_RIGHT2,
	ELITES_SHOOT_RIGHT3,
	ELITES_SHOOT_RIGHT4,
	ELITES_SHOOT_RIGHT5,
	ELITES_SHOOT_RIGHTLAST,
	ELITES_RELOAD,
	ELITES_DRAW
};

void
w_elites_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_elites.fire");
	precache_model("models/w_elite.mdl");
#else
	precache_model("models/v_elite.mdl");
	precache_model("models/p_elite.mdl");
#endif
}

void
w_elites_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.elites_mag, pl.ammo_9mm, -1);
}

string
w_elites_wmodel(void)
{
	return "models/w_elite.mdl";
}

string
w_elites_pmodel(player pl)
{
	return "models/p_elite.mdl";
}

string
w_elites_deathmsg(void)
{
	return "";
}

int
w_elites_pickup(player pl, int new, int startammo)
{
#ifdef SERVER

	if (new) {
		if (startammo == -1)
			pl.elites_mag = 30;
		else
			pl.elites_mag = startammo;
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
w_elites_draw(player pl)
{
	Weapons_SetModel("models/v_elite.mdl");
	Weapons_ViewAnimation(pl, ELITES_DRAW);
	pl.mode_temp = 0;

#ifdef CLIENT
	pl.cs_cross_mindist = 4;
	pl.cs_cross_deltadist = 3;
#endif
}

void
w_elites_primary(player pl)
{

	if (pl.w_attack_next > 0.0) {
		return;
	}
	if (pl.gflags & GF_SEMI_TOGGLED) {
		return;
	}
	if (!pl.elites_mag) {
		return;
	}

	pl.mode_temp = 1 - pl.mode_temp;


	float accuracy = Cstrike_CalculateAccuracy(pl, 150,1)+0.002;
	int dmg = 0;
	pl.elites_mag--;

	int r = (float)input_sequence % 5;
	if (pl.mode_temp) {
		if (pl.elites_mag <= 0) {
			Weapons_ViewAnimation(pl, ELITES_SHOOT_LEFTLAST);
		} else {
			switch (r) {
			case 0:
				Weapons_ViewAnimation(pl, ELITES_SHOOT_LEFT1);
				break;
			case 1:
				Weapons_ViewAnimation(pl, ELITES_SHOOT_LEFT2);
				break;
			case 2:
				Weapons_ViewAnimation(pl, ELITES_SHOOT_LEFT3);
				break;
			case 3:
				Weapons_ViewAnimation(pl, ELITES_SHOOT_LEFT4);
				break;
			default:
				Weapons_ViewAnimation(pl, ELITES_SHOOT_LEFT1);
				break;
			}
		}
	} else {
		if (pl.elites_mag <= 0) {
			Weapons_ViewAnimation(pl, ELITES_SHOOT_RIGHTLAST);
		} else {
			switch (r) {
			case 0:
				Weapons_ViewAnimation(pl, ELITES_SHOOT_RIGHT1);
				break;
			case 1:
				Weapons_ViewAnimation(pl, ELITES_SHOOT_RIGHT2);
				break;
			case 2:
				Weapons_ViewAnimation(pl, ELITES_SHOOT_RIGHT3);
				break;
			case 3:
				Weapons_ViewAnimation(pl, ELITES_SHOOT_RIGHT4);
				break;
			default:
				Weapons_ViewAnimation(pl, ELITES_SHOOT_RIGHT1);
				break;
			}
		}
	}

	if (pl.flags & FL_CROUCHING) {
		if (pl.mode_temp)
			Animation_PlayerTop(pl, ANIM_CROUCH_SHOOT2_DUALPISTOLS, 0.45f);
		else
			Animation_PlayerTop(pl, ANIM_CROUCH_SHOOT_DUALPISTOLS, 0.45f);
	} else {
		if (pl.mode_temp)
			Animation_PlayerTop(pl, ANIM_SHOOT2_DUALPISTOLS, 0.45f);
		else
			Animation_PlayerTop(pl, ANIM_SHOOT_DUALPISTOLS, 0.45f);
	}

#ifdef CLIENT
	View_SetMuzzleflash(MUZZLE_RIFLE);

	if (pl.mode_temp)
		View_AddEvent(w_pistol_ejectshell_left, 0.0f);
	else
		View_AddEvent(w_pistol_ejectshell_right, 0.0f);
#else
	dmg = Skill_GetValue("plr_elites_dmg", 45);
	TraceAttack_SetRangeModifier(1.875); /* 14 but not 15 */
	TraceAttack_SetPenetrationPower(1);
	Cstrike_BulletRecoil_ApplyPre(pl,.9f);
	TraceAttack_FireBulletsWithDecal(1, pl.origin + pl.view_ofs, dmg, [accuracy,accuracy], WEAPON_ELITES, "Impact.BigShot");
	Cstrike_BulletRecoil_ApplyPost(pl,.9f);
	Sound_Play(pl, CHAN_WEAPON, "weapon_elites.fire");
#endif
	Cstrike_ShotMultiplierAdd(pl, 3, .85);
	pl.gflags |= GF_SEMI_TOGGLED;
	pl.w_attack_next = 0.13f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_elites_reload(player pl)
{

	if (pl.w_attack_next > 0.0)
		return;
	if (pl.elites_mag >= 30)
		return;
	if (!pl.ammo_9mm)
		return;

	Weapons_ViewAnimation(pl, ELITES_RELOAD);

	pl.w_attack_next = 4.6f;
	pl.w_idle_next = pl.w_attack_next;

#ifdef SERVER
	static void w_weapon_reload_done(void) {
		player pl = (player)self;
		Weapons_ReloadWeapon(pl, player::elites_mag, player::ammo_9mm, 30);
		Cstrike_ShotReset(pl);
	}

	pl.think = w_weapon_reload_done;
	pl.nextthink = time + pl.w_attack_next - 0.1f;
#endif
}

void
w_elites_release(player pl)
{

	w_cstrike_weaponrelease();

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.elites_mag == 0 && pl.ammo_9mm > 0) {
		Weapons_Reload(pl);
		return;
	}
}

float
w_elites_aimanim(player pl)
{
	return pl.flags & FL_CROUCHING ? ANIM_CROUCH_AIM_DUALPISTOLS : ANIM_AIM_DUALPISTOLS;
}

void
w_elites_hud(player pl)
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
w_elites_isempty(player pl)
{

	if (pl.elites_mag <= 0 && pl.ammo_9mm <= 0)
		return 1;

	return 0;
}

void
w_elites_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (w_elites_isempty(pl))
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_9mm, AMMO_MAX_9MM, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud15_spr,
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
			g_hud14_spr,
			[0,90/256],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_elites =
{
	.name		= "elites",
	.id		= ITEM_ELITES,
	.slot		= 1,
	.slot_pos	= 4,
	.weight		= 5,
	.allow_drop	= TRUE,
	.draw		= w_elites_draw,
	.holster	= __NULL__,
	.primary	= w_elites_primary,
	.secondary	= __NULL__,
	.reload		= w_elites_reload,
	.release	= w_elites_release,
	.postdraw	= w_elites_hud,
	.precache	= w_elites_precache,
	.pickup		= w_elites_pickup,
	.updateammo	= w_elites_updateammo,
	.wmodel		= w_elites_wmodel,
	.pmodel		= w_elites_pmodel,
	.deathmsg	= w_elites_deathmsg,
	.aimanim	= w_elites_aimanim,
	.hudpic		= w_elites_hudpic,
	.type		= csweapon_ranged_type,
	.isempty	= w_elites_isempty
};

#ifdef SERVER
void
weapon_elites(void)
{
	Weapons_InitItem(WEAPON_ELITES);
}
#endif
