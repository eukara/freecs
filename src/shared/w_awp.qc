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

/*QUAKED weapon_awp (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_awp.mdl"

COUNTER-STRIKE (1999) ENTITY

AWP (AI Arctic Warfare/Magnum) Weapon

- Buy Menu -
Price: $4750

*/

#ifdef CLIENT
void
w_sniper_ejectshell(void)
{
	static void w_sniper_ejectshelldeath(void) {
		remove(self);
	}
	static void w_sniper_ejectshell_touch(void) {
		if (other == world)
			Sound_Play(self, CHAN_BODY, "modelevent_shell.land");
	}
	entity eShell = spawn();
	setmodel(eShell, "models/rshell_big.mdl");
	eShell.solid = SOLID_BBOX;
	eShell.movetype = MOVETYPE_BOUNCE;
	eShell.drawmask = MASK_ENGINE;
	eShell.angles = [pSeat->m_eViewModel.angles[0], pSeat->m_eViewModel.angles[1], 0];
	eShell.velocity = pSeat->m_vecPredictedVelocity;

	makevectors(pSeat->m_eViewModel.angles);
	eShell.velocity += (v_forward * 0);
	eShell.velocity += (v_right * -80);
	eShell.velocity += (v_up * 100);
	eShell.touch = w_sniper_ejectshell_touch;

	eShell.avelocity = [0,45,900];
	eShell.think = w_sniper_ejectshelldeath;
	eShell.nextthink = time + 2.5f;
	setsize(eShell, [0,0,0], [0,0,0]);
	setorigin(eShell, gettaginfo(pSeat->m_eViewModel, pSeat->m_iVMBones + 1));
}
#endif

enum
{
	AWP_IDLE,
	AWP_SHOOT1,
	AWP_SHOOT2,
	AWP_SHOOT3,
	AWP_RELOAD,
	AWP_DRAW
};

void
w_awp_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_awp.fire");
	Sound_Precache("weapon_awp.zoom");
	precache_model("models/w_awp.mdl");
#else
	precache_model("models/v_awp.mdl");
	precache_model("models/p_awp.mdl");
#endif
}

void
w_awp_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.awp_mag, pl.ammo_338mag, pl.mode_temp);
}

string
w_awp_wmodel(void)
{
	return "models/w_awp.mdl";
}

string
w_awp_pmodel(player pl)
{
	return "models/p_awp.mdl";
}

string
w_awp_deathmsg(void)
{
	return "";
}

int
w_awp_pickup(player pl, int new, int startammo)
{
#ifdef SERVER

	if (new) {
		if (startammo == -1)
			pl.awp_mag = 10;
		else
			pl.awp_mag = startammo;
	} else {
		if (pl.ammo_338mag < 20) {
			pl.ammo_338mag = bound(0, pl.ammo_338mag + 10, 20);
		} else {
			return (0);
		}
	}
#endif
	return (1);
}

void
w_awp_draw(player pl)
{
	Weapons_SetModel("models/v_awp.mdl");
	Weapons_ViewAnimation(pl, AWP_DRAW);
	pl.mode_temp = 0;

#ifdef CLIENT
	pl.cs_cross_mindist = 8;
	pl.cs_cross_deltadist = 3;
#endif
}

void
w_awp_release(player pl)
{

	w_cstrike_weaponrelease();

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.awp_mag == 0 && pl.ammo_338mag > 0) {
		Weapons_Reload(pl);
		return;
	}

	if (pl.w_idle_next > 0.0f) {
		pl.viewzoom = 1.0f;
		Weapons_EnableModel();
		return;
	}

	if (pl.mode_temp == 1) {
		pl.viewzoom = 0.45f;
		Weapons_DisableModel();
	} else if (pl.mode_temp == 2) {
		pl.viewzoom = 0.1f;
		Weapons_DisableModel();
	} else {
		pl.viewzoom = 1.0f;
		Weapons_EnableModel();
	}
}

void
w_awp_secondary(player pl)
{
	if (pl.w_attack_next) {
		return;
	}

#ifdef SSQC
	Sound_Play(pl, CHAN_WEAPON, "weapon_awp.zoom");
#endif

	/* Simple toggle of fovs */
	if (pl.mode_temp == 1) {
		pl.mode_temp = 2;
	} else if (pl.mode_temp == 2) {
		pl.mode_temp = 0;
	} else {
		pl.mode_temp = 1;
	}

	pl.w_attack_next = 0.3f;
	pl.w_idle_next = 0.0f;
	w_awp_release(pl);
}

void
w_awp_primary(player pl)
{

	if (pl.w_attack_next > 0.0) {
		w_awp_release(pl);
		return;
	}
	if (!pl.awp_mag) {
		return;
	}

	Cstrike_ShotMultiplierAdd(pl, 1);
	float accuracy = Cstrike_CalculateAccuracy(pl, -1);
	pl.awp_mag--;

	int r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(pl, AWP_SHOOT1);
		break;
	case 1:
		Weapons_ViewAnimation(pl, AWP_SHOOT2);
		break;
	default:
		Weapons_ViewAnimation(pl, AWP_SHOOT3);
		break;
	}

	if (pl.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_SHOOT_RIFLE, 0.45f);
	else
		Animation_PlayerTop(pl, ANIM_CROUCH_SHOOT_RIFLE, 0.45f);

#ifdef CLIENT
	View_SetMuzzleflash(MUZZLE_RIFLE);
	View_AddEvent(w_sniper_ejectshell, 0.9f);
#else
	TraceAttack_SetRangeModifier(1.375);
	TraceAttack_SetPenetrationPower(2); /* however, we can only penetrate one wall if the first one is 5 units thick or higher */
	TraceAttack_FireBulletsWithDecal(1, pl.origin + pl.view_ofs, 115, [accuracy,accuracy], WEAPON_AWP, "Impact.BigShot");

	Sound_Play(pl, CHAN_WEAPON, "weapon_awp.fire");
#endif

	pl.w_attack_next = 1.2f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_awp_reload(player pl)
{

	if (pl.w_attack_next > 0.0)
		return;
	if (pl.awp_mag >= 10)
		return;
	if (!pl.ammo_338mag)
		return;

	Weapons_ViewAnimation(pl, AWP_RELOAD);

	pl.w_attack_next = 2.9f;
	pl.w_idle_next = pl.w_attack_next;

#ifdef SERVER
	static void w_weapon_reload_done(void) {
		player pl = (player)self;
		Weapons_ReloadWeapon(pl, player::awp_mag, player::ammo_338mag, 10);
	}

	pl.think = w_weapon_reload_done;
	pl.nextthink = time + pl.w_attack_next - 0.1f;
#endif
}

float
w_awp_aimanim(player pl)
{
	return w_ak47_aimanim(pl);
}

void
w_awp_hud(player pl)
{
#ifdef CLIENT
	if (pl.viewzoom < 1.0f) {
		Cstrike_DrawScope();
	}
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [24/256,96/256], [24/256, 24/256], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

int
w_awp_isempty(player pl)
{

	if (pl.awp_mag <= 0 && pl.ammo_338mag <= 0)
		return 1;

	return 0;
}

void
w_awp_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (w_awp_isempty(pl))
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_338mag, AMMO_MAX_338MAG, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud5_spr,
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
			g_hud2_spr,
			[0,135/256],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_awp =
{
	.name		= "awp",
	.id		= ITEM_AWP,
	.slot		= 0,
	.slot_pos	= 12,
	.weight		= 30,
	.allow_drop	= TRUE,
	.draw		= w_awp_draw,
	.holster	= __NULL__,
	.primary	= w_awp_primary,
	.secondary	= w_awp_secondary,
	.reload		= w_awp_reload,
	.release	= w_awp_release,
	.postdraw	= w_awp_hud,
	.precache	= w_awp_precache,
	.pickup		= w_awp_pickup,
	.updateammo	= w_awp_updateammo,
	.wmodel		= w_awp_wmodel,
	.pmodel		= w_awp_pmodel,
	.deathmsg	= w_awp_deathmsg,
	.aimanim	= w_awp_aimanim,
	.hudpic		= w_awp_hudpic,
	.type		= csweapon_ranged_type,
	.isempty	= w_awp_isempty
};

#ifdef SERVER
void
weapon_awp(void)
{
	Weapons_InitItem(WEAPON_AWP);
}
#endif
