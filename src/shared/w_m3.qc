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

/*QUAKED weapon_m3 (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_m3.mdl"

COUNTER-STRIKE (1999) ENTITY

Benneli M3 Super90 Weapon

- Buy Menu -
Price: $1700

*/

#ifdef CLIENT
void
w_m3_ejectshell(void)
{
	static void w_m3_ejectshell_death(void) {
		remove(self);
	}
	static void w_m3_ejectshell_touch(void) {
		if (other == world)
			Sound_Play(self, CHAN_BODY, "modelevent_shotgunshell.land");
	}
	entity eShell = spawn();
	setmodel(eShell, "models/shotgunshell.mdl");
	eShell.solid = SOLID_BBOX;
	eShell.movetype = MOVETYPE_BOUNCE;
	eShell.drawmask = MASK_ENGINE;
	eShell.angles = [pSeat->m_eViewModel.angles[0], pSeat->m_eViewModel.angles[1] + 20, 0];
	eShell.velocity = pSeat->m_vecPredictedVelocity;

	makevectors(pSeat->m_eViewModel.angles);
	eShell.velocity += (v_forward * 0);
	eShell.velocity += (v_right * -80);
	eShell.velocity += (v_up * 100);
	eShell.touch = w_m3_ejectshell_touch;

	eShell.avelocity = [0,45,900];
	eShell.think = w_m3_ejectshell_death;
	eShell.renderflags |= RF_DEPTHHACK;
	eShell.nextthink = time + 2.5f;
	setsize(eShell, [0,0,0], [0,0,0]);
	setorigin(eShell, pSeat->m_eViewModel.origin + (v_forward * 10) + (v_right * 10) + (v_up * -8));
}
#endif

enum
{
	M3_IDLE,
	M3_SHOOT1,
	M3_SHOOT2,
	M3_INSERT,
	M3_RELOAD_END,
	M3_RELOAD_START,
	M3_DRAW
};

enum
{
	M3S_IDLE,
	M3S_RELOAD_START,
	M3S_RELOAD,
	M3S_RELOAD_END
};

void
w_m3_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_m3.fire");
	precache_model("models/w_m3.mdl");
#else
	precache_model("models/v_m3.mdl");
	precache_model("models/p_m3.mdl");
	Sound_Precache("modelevent_shotgunshell.land");
#endif
}

void
w_m3_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.m3_mag, pl.ammo_buckshot, -1);
}

string
w_m3_wmodel(void)
{
	return "models/w_m3.mdl";
}

string
w_m3_pmodel(player pl)
{
	return "models/p_m3.mdl";
}

string
w_m3_deathmsg(void)
{
	return "";
}

int
w_m3_pickup(player pl, int new, int startammo)
{
#ifdef SERVER

	if (new) {
		if (startammo == -1)
			pl.m3_mag = 8;
		else
			pl.m3_mag = startammo;
	} else {
		if (pl.ammo_buckshot < AMMO_MAX_BUCKSHOT) {
			pl.ammo_buckshot = bound(0, pl.ammo_buckshot + 8, AMMO_MAX_BUCKSHOT);
		} else {
			return (0);
		}
	}
#endif
	return (1);
}

void
w_m3_draw(player pl)
{
	Weapons_SetModel("models/v_m3.mdl");
	Weapons_ViewAnimation(pl, M3_DRAW);
	pl.mode_temp = 0;

#ifdef CLIENT
	pl.cs_cross_mindist = 8;
	pl.cs_cross_deltadist = 6;
#endif
}

void w_m3_release(player pl);

void
w_m3_primary(player pl)
{

	if (pl.w_attack_next > 0.0) {
		w_m3_release(pl);
		return;
	}

	/* interrupt reloading if no longer empty */
	if (pl.mode_temp == M3S_RELOAD && pl.m3_mag >= 1) {
		pl.mode_temp = M3S_RELOAD_END;
		w_m3_release(pl);
		return;
	} else if (pl.mode_temp > M3S_IDLE) {
		w_m3_release(pl);
		return;
	}

	/* Ammo check */
	if (pl.m3_mag <= 0) {
		w_m3_release(pl);
		return;
	}

	pl.m3_mag--;

	int r = (float)input_sequence % 2;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(pl, M3_SHOOT1);
		break;
	default:
		Weapons_ViewAnimation(pl, M3_SHOOT2);
		break;
	}

#ifdef CLIENT
	View_SetMuzzleflash(MUZZLE_RIFLE);
	View_AddEvent(w_m3_ejectshell, 0.6f);
#else
	TraceAttack_SetPenetrationPower(0); /* shotties can't wallbang?! */

	if (pl.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_SHOOT_SHOTGUN, 0.45f);
	else
		Animation_PlayerTop(pl, ANIM_CROUCH_SHOOT_SHOTGUN, 0.45f);

	Sound_Play(pl, CHAN_WEAPON, "weapon_m3.fire");
#endif

	for (int i = 0; i < 9; i++) {
		Cstrike_ShotMultiplierAdd(pl, 1);
		pl.punchangle[0] = -4 * (9 / 6);
#ifdef SERVER
		TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 26, [random(-1,1) * 0.1,random(-1,1) * 0.05], WEAPON_M3);
#endif
	}

	pl.w_attack_next = 1.0f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_m3_reload(player pl)
{

	if (pl.m3_mag >= 8) {
		return;
	}
	if (pl.ammo_buckshot <= 0) {
		return;
	}
	
	if (pl.mode_temp > M3S_IDLE) {
		return;
	}
	pl.mode_temp = M3S_RELOAD_START;
	pl.w_idle_next = 0.0f;
}

void
w_m3_release(player pl)
{

	w_cstrike_weaponrelease();

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.mode_temp == M3S_IDLE && pl.m3_mag == 0 && pl.ammo_buckshot > 0) {
		Weapons_Reload(pl);
		return;
	}

	if (pl.w_idle_next > 0.0) {
		return;
	}

	if (pl.mode_temp == M3S_RELOAD_START) {
		Weapons_ViewAnimation(pl, M3_RELOAD_START);
		pl.mode_temp = M3S_RELOAD;
		pl.w_idle_next = 0.65f;
	} else if (pl.mode_temp == M3S_RELOAD) {
		Weapons_ViewAnimation(pl, M3_INSERT);
		pl.m3_mag++;
		pl.ammo_buckshot--;
		w_m3_updateammo(pl);
		if (pl.ammo_buckshot <= 0 || pl.m3_mag >= 8) {
			pl.mode_temp = M3S_RELOAD_END;
		}
		pl.w_idle_next = 0.5f;	
	} else if (pl.mode_temp == M3S_RELOAD_END) {
		Weapons_ViewAnimation(pl, M3_RELOAD_END);
		pl.mode_temp = M3S_IDLE;
		pl.w_idle_next = 10.0f;
		pl.w_attack_next = 0.5f;
	}
}

float
w_m3_aimanim(player pl)
{
	return w_ak47_aimanim(pl);
}

void
w_m3_hud(player pl)
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
w_m3_isempty(player pl)
{

	if (pl.m3_mag <= 0 && pl.ammo_buckshot <= 0)
		return 1;

	return 0;
}

void
w_m3_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (w_m3_isempty(pl))
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_buckshot, AMMO_MAX_BUCKSHOT, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud4_spr,
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
			g_hud1_spr,
			[0,135/256],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_m3 =
{
	.name		= "m3",
	.id		= ITEM_M3,
	.slot		= 0,
	.slot_pos	= 0,
	.weight		= 20,
	.allow_drop	= TRUE,
	.draw		= w_m3_draw,
	.holster	= __NULL__,
	.primary	= w_m3_primary,
	.secondary	= __NULL__,
	.reload		= w_m3_reload,
	.release	= w_m3_release,
	.postdraw	= w_m3_hud,
	.precache	= w_m3_precache,
	.pickup		= w_m3_pickup,
	.updateammo	= w_m3_updateammo,
	.wmodel		= w_m3_wmodel,
	.pmodel		= w_m3_pmodel,
	.deathmsg	= w_m3_deathmsg,
	.aimanim	= w_m3_aimanim,
	.hudpic		= w_m3_hudpic,
	.type		= csweapon_ranged_type,
	.isempty	= w_m3_isempty
};

#ifdef SERVER
void
weapon_m3(void)
{
	Weapons_InitItem(WEAPON_M3);
}
#endif
