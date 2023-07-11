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

/*!QUAKED weapon_xm1014 (0 0 1) (-16 -16 0) (16 16 32)

COUNTER-STRIKE (1999) ENTITY

Benneli XM1014 Weapon

- Buy Menu -
Price: $3000

-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
model="models/w_xm1014.mdl"
*/

#ifdef CLIENT
void
w_xm1014_ejectshell(void)
{
	static void w_xm1014_ejectshell_death(void) {
		remove(self);
	}
	static void w_xm1014_ejectshell_touch(void) {
		if (other == world)
			Sound_Play(self, CHAN_BODY, "modelevent_shotgunshell.land");
	}
	entity eShell = spawn();
	setmodel(eShell, "models/shotgunshell.mdl");
	eShell.solid = SOLID_BBOX;
	eShell.movetype = MOVETYPE_BOUNCE;
	eShell.drawmask = MASK_ENGINE;
	eShell.angles = [pSeat->m_eViewModel.angles[0], pSeat->m_eViewModel.angles[1], 0];
	eShell.velocity = pSeat->m_vecPredictedVelocity;

	makevectors(pSeat->m_eViewModel.angles);
	eShell.velocity += (v_forward * 0);
	eShell.velocity += (v_right * 80);
	eShell.velocity += (v_up * 100);
	eShell.touch = w_xm1014_ejectshell_touch;

	eShell.avelocity = [0,45,900];
	eShell.think = w_xm1014_ejectshell_death;
	eShell.nextthink = time + 2.5f;
	setsize(eShell, [0,0,0], [0,0,0]);
	setorigin(eShell, pSeat->m_eViewModel.origin + (v_forward * 26) + (v_right * 8) + (v_up * -8));
}
#endif

enum
{
	XM1014_IDLE,
	XM1014_SHOOT1,
	XM1014_SHOOT2,
	XM1014_INSERT,
	XM1014_RELOAD_END,
	XM1014_RELOAD_START,
	XM1014_DRAW
};

enum
{
	XM1014S_IDLE,
	XM1014S_RELOAD_START,
	XM1014S_RELOAD,
	XM1014S_RELOAD_END
};

void
w_xm1014_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_xm1014.fire");
	Sound_Precache("weapon_xm1014.insertshell");
	precache_model("models/w_xm1014.mdl");
#else
	precache_model("models/v_xm1014.mdl");
	precache_model("models/p_xm1014.mdl");
#endif
}

void
w_xm1014_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.xm1014_mag, pl.ammo_buckshot, -1);
}

string
w_xm1014_wmodel(void)
{
	return "models/w_xm1014.mdl";
}

string
w_xm1014_pmodel(player pl)
{
	return "models/p_xm1014.mdl";
}

string
w_xm1014_deathmsg(void)
{
	return "";
}

int
w_xm1014_pickup(player pl, int new, int startammo)
{
#ifdef SERVER

	if (new) {
		if (startammo == -1)
			pl.xm1014_mag = 7;
		else
			pl.xm1014_mag = startammo;
	} else {
		if (pl.ammo_buckshot < AMMO_MAX_BUCKSHOT) {
			pl.ammo_buckshot = bound(0, pl.ammo_buckshot + 7, AMMO_MAX_BUCKSHOT);
		} else {
			return (0);
		}
	}
#endif
	return (1);
}

void
w_xm1014_draw(player pl)
{
	Weapons_SetModel("models/v_xm1014.mdl");
	Weapons_ViewAnimation(pl, XM1014_DRAW);
	pl.mode_temp = 0;

#ifdef CLIENT
	pl.cs_cross_mindist = 9;
	pl.cs_cross_deltadist = 4;
#endif
}


void w_xm1014_release(player pl);

void
w_xm1014_primary(player pl)
{
	int dmg = 0;
	int r = 0;

	if (pl.w_attack_next > 0.0) {
		w_xm1014_release(pl);
		return;
	}

	/* interrupt reloading if no longer empty */
	if (pl.mode_temp == XM1014S_RELOAD && pl.xm1014_mag >= 1) {
		pl.mode_temp = XM1014S_RELOAD_END;
		w_xm1014_release(pl);
		return;
	} else if (pl.mode_temp > XM1014S_IDLE) {
		w_xm1014_release(pl);
		return;
	}

	/* Ammo check */
	if (pl.xm1014_mag <= 0) {
		w_xm1014_release(pl);
		return;
	}

	pl.xm1014_mag--;

	r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(pl, XM1014_SHOOT1);
		break;
	default:
		Weapons_ViewAnimation(pl, XM1014_SHOOT2);
		break;
	}

	if (pl.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_SHOOT_SHOTGUN, 0.45f);
	else
		Animation_PlayerTop(pl, ANIM_CROUCH_SHOOT_SHOTGUN, 0.45f);

#ifdef CLIENT
	View_SetMuzzleflash(MUZZLE_RIFLE);
	View_AddEvent(w_xm1014_ejectshell, 0.0f);
#else
	dmg = Skill_GetValue("plr_xm1014_dmg", 22);
	TraceAttack_SetPenetrationPower(0); /* shotties can't wallbang?! */
	Sound_Play(pl, CHAN_WEAPON, "weapon_xm1014.fire");
#endif

	for (int i = 0; i < 6; i++) {
		Cstrike_ShotMultiplierAdd(pl, 1, 1);
		pl.punchangle[0] = -4 * (6 / 6);
#ifdef SERVER
		TraceAttack_FireBulletsWithDecal(1, pl.origin + pl.view_ofs, dmg, [random(-1,1) * 0.1,random(-1,1) * 0.05], WEAPON_M3, "Impact.BigShot");
#endif
	}
	
	pl.w_attack_next = 0.25f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_xm1014_reload(player pl)
{

	if (pl.xm1014_mag >= 7) {
		return;
	}
	if (pl.ammo_buckshot <= 0) {
		return;
	}
	
	if (pl.mode_temp > XM1014S_IDLE) {
		return;
	}
	pl.mode_temp = XM1014S_RELOAD_START;
	pl.w_idle_next = 0.0f;
}

void
w_xm1014_release(player pl)
{

	w_cstrike_weaponrelease();

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.mode_temp == XM1014S_IDLE && pl.xm1014_mag == 0 && pl.ammo_buckshot > 0) {
		Weapons_Reload(pl);
		return;
	}

	if (pl.w_idle_next > 0.0) {
		return;
	}

	if (pl.mode_temp == XM1014S_RELOAD_START) {
		Weapons_ViewAnimation(pl, XM1014_RELOAD_START);
		pl.mode_temp = XM1014S_RELOAD;
		pl.w_idle_next = 0.65f;
	} else if (pl.mode_temp == XM1014S_RELOAD) {
		Weapons_ViewAnimation(pl, XM1014_INSERT);
		pl.xm1014_mag++;
		pl.ammo_buckshot--;
		w_xm1014_updateammo(pl);
#ifdef SERVER
		Sound_Play(pl, CHAN_WEAPON, "weapon_xm1014.insertshell");
#endif
		if (pl.ammo_buckshot <= 0 || pl.xm1014_mag >= 7) {
			pl.mode_temp = XM1014S_RELOAD_END;
		}
		pl.w_idle_next = 0.5f;
	} else if (pl.mode_temp == XM1014S_RELOAD_END) {
		Weapons_ViewAnimation(pl, XM1014_RELOAD_END);
		pl.mode_temp = XM1014S_IDLE;
		pl.w_idle_next = 10.0f;
		pl.w_attack_next = 0.5f;
	}
}

float
w_xm1014_aimanim(player pl)
{
	return w_ak47_aimanim(pl);
}

void
w_xm1014_hud(player pl)
{
#ifdef CLIENT
	Cstrike_DrawCrosshair();
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [0,72/256], [24/256, 24/256], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

int
w_xm1014_isempty(player pl)
{

	if (pl.xm1014_mag <= 0 && pl.ammo_buckshot <= 0)
		return 1;

	return 0;
}

void
w_xm1014_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (w_xm1014_isempty(pl))
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_buckshot, AMMO_MAX_BUCKSHOT, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud13_spr,
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
			g_hud12_spr,
			[0,135/256],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_xm1014 =
{
	.name		= "xm1014",
	.id		= ITEM_XM1014,
	.slot		= 0,
	.slot_pos	= 1,
	.weight		= 20,
	.allow_drop	= TRUE,
	.draw		= w_xm1014_draw,
	.holster	= __NULL__,
	.primary	= w_xm1014_primary,
	.secondary	= __NULL__,
	.reload		= w_xm1014_reload,
	.release	= w_xm1014_release,
	.postdraw	= w_xm1014_hud,
	.precache	= w_xm1014_precache,
	.pickup		= w_xm1014_pickup,
	.updateammo	= w_xm1014_updateammo,
	.wmodel		= w_xm1014_wmodel,
	.pmodel		= w_xm1014_pmodel,
	.deathmsg	= w_xm1014_deathmsg,
	.aimanim	= w_xm1014_aimanim,
	.hudpic		= w_xm1014_hudpic,
	.type		= csweapon_ranged_type,
	.isempty	= w_xm1014_isempty
};

#ifdef SERVER
void
weapon_xm1014(void)
{
	Weapons_InitItem(WEAPON_XM1014);
}
#endif
