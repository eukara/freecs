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

/*QUAKED weapon_deagle (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_deagle.mdl"

COUNTER-STRIKE (1999) ENTITY

Desert Eagle .50 AE Weapon

- Buy Menu -
Price: $650

*/

#ifdef CLIENT
void
w_pistol_ejectshell(void)
{
	static void w_pistol_ejectshell_death(void) {
		remove(self);
	}
	static void w_pistol_ejectshell_touch(void) {
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
	eShell.touch = w_pistol_ejectshell_touch;

	eShell.avelocity = [0,45,900];
	eShell.think = w_pistol_ejectshell_death;
	eShell.nextthink = time + 2.5f;
	setsize(eShell, [0,0,0], [0,0,0]);
	setorigin(eShell, gettaginfo(pSeat->m_eViewModel, pSeat->m_iVMBones + 1));
}
#endif

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
w_deagle_pickup(player pl, int new, int startammo)
{
#ifdef SERVER

	if (new) {
		if (startammo == -1)
			pl.deagle_mag = 7;
		else
			pl.deagle_mag = startammo;
	} else {
		if (pl.ammo_50ae < AMMO_MAX_50AE) {
			pl.ammo_50ae = bound(0, pl.ammo_50ae + 7, AMMO_MAX_50AE);
		} else {
			return (0);
		}
	}
#endif
	return (1);
}

void
w_deagle_draw(player pl)
{
	Weapons_SetModel("models/v_deagle.mdl");
	Weapons_ViewAnimation(pl, DEAGLE_DRAW);

#ifdef CLIENT
	pl.cs_cross_mindist = 8;
	pl.cs_cross_deltadist = 3;
#endif
}

void
w_deagle_primary(player pl)
{

	if (pl.w_attack_next > 0.0)
		return;
	if (pl.gflags & GF_SEMI_TOGGLED)
		return;
	if (!pl.deagle_mag)
		return;

	Cstrike_ShotMultiplierAdd(pl, 1);
	float accuracy = Cstrike_CalculateAccuracy(pl, 200);
	pl.deagle_mag--;

	if (pl.deagle_mag <= 0) {
		Weapons_ViewAnimation(pl, DEAGLE_SHOOT_EMPTY);
	} else {
		int r = (float)input_sequence % 2;
		switch (r) {
		case 0:
			Weapons_ViewAnimation(pl, DEAGLE_SHOOT1);
			break;
		default:
			Weapons_ViewAnimation(pl, DEAGLE_SHOOT2);
			break;
		}
	}

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_CROUCH_SHOOT_ONEHAND, 0.45f);
	else
		Animation_PlayerTop(pl, ANIM_SHOOT_ONEHAND, 0.45f);

#ifdef CLIENT
	View_SetMuzzleflash(MUZZLE_RIFLE);
	View_AddEvent(w_pistol_ejectshell, 0.0f);
#else
	TraceAttack_SetRangeModifier(0.81);
	TraceAttack_SetPenetrationPower(2);
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 54, [accuracy,accuracy], WEAPON_DEAGLE);
	Sound_Play(pl, CHAN_WEAPON, "weapon_deagle.fire");
#endif

	pl.gflags |= GF_SEMI_TOGGLED;
	pl.w_attack_next = 0.15f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_deagle_reload(player pl)
{

	if (pl.w_attack_next > 0.0) {
		return;
	}
	if (pl.deagle_mag >= 7) {
		return;
	}
	if (!pl.ammo_50ae) {
		return;
	}
	Weapons_ViewAnimation(pl, DEAGLE_RELOAD);

#ifdef SERVER
	Weapons_ReloadWeapon(pl, player::deagle_mag, player::ammo_50ae, 7);
#endif

	pl.w_attack_next = 2.1f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_deagle_release(player pl)
{

	w_cstrike_weaponrelease();

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.deagle_mag == 0 && pl.ammo_50ae > 0) {
		Weapons_Reload(pl);
		return;
	}
}

float
w_deagle_aimanim(player pl)
{
	return self.flags & FL_CROUCHING ? ANIM_CROUCH_AIM_ONEHAND : ANIM_AIM_ONEHAND;
}

void
w_deagle_hud(player pl)
{
#ifdef CLIENT
	Cstrike_DrawCrosshair();
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [24/256,72/256], [24/256, 24/256], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

int
w_deagle_isempty(player pl)
{

	if (pl.deagle_mag <= 0 && pl.ammo_50ae <= 0)
		return 1;

	return 0;
}

void
w_deagle_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (w_deagle_isempty(pl))
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
			a,
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
			a,
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
	.weight		= 7,
	.allow_drop	= TRUE,
	.draw		= w_deagle_draw,
	.holster	= __NULL__,
	.primary	= w_deagle_primary,
	.secondary	= __NULL__,
	.reload		= w_deagle_reload,
	.release	= w_deagle_release,
	.postdraw	= w_deagle_hud,
	.precache	= w_deagle_precache,
	.pickup		= w_deagle_pickup,
	.updateammo	= w_deagle_updateammo,
	.wmodel		= w_deagle_wmodel,
	.pmodel		= w_deagle_pmodel,
	.deathmsg	= w_deagle_deathmsg,
	.aimanim	= w_deagle_aimanim,
	.hudpic		= w_deagle_hudpic,
	.type		= csweapon_ranged_type,
	.isempty	= w_deagle_isempty
};

#ifdef SERVER
void
weapon_deagle(void)
{
	Weapons_InitItem(WEAPON_DEAGLE);
}
#endif
