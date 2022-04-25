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

/*QUAKED weapon_ak47 (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_ak47.mdl"

COUNTER-STRIKE (1999) ENTITY

AK-47 Weapon

- Buy Menu -
Price: $2500
Terrorists only weapon

*/

#ifdef CLIENT
void
w_rifle_ejectshell(void)
{
	static void w_rifle_ejectshell_death(void) {
		remove(self);
	}
	static void w_rifle_ejectshell_touch(void) {
		if (other == world)
			Sound_Play(self, CHAN_BODY, "modelevent_shell.land");
	}
	entity eShell = spawn();
	setmodel(eShell, "models/rshell.mdl");
	eShell.solid = SOLID_BBOX;
	eShell.movetype = MOVETYPE_BOUNCE;
	eShell.drawmask = MASK_ENGINE;
	eShell.angles = [pSeat->m_eViewModel.angles[0], pSeat->m_eViewModel.angles[1], 0];
	eShell.velocity = pSeat->m_vecPredictedVelocity;

	makevectors(pSeat->m_eViewModel.angles);
	eShell.velocity += (v_forward * 0);
	eShell.velocity += (v_right * -80);
	eShell.velocity += (v_up * 80);
	eShell.touch = w_rifle_ejectshell_touch;

	eShell.avelocity = [0,45,900];
	eShell.think = w_rifle_ejectshell_death;
	eShell.nextthink = time + 2.5f;
	setsize(eShell, [0,0,0], [0,0,0]);
	setorigin(eShell, gettaginfo(pSeat->m_eViewModel, pSeat->m_iVMBones + 1));
}
#endif

enum
{
	AK47_IDLE,
	AK47_RELOAD,
	AK47_DRAW,
	AK47_SHOOT1,
	AK47_SHOOT2,
	AK47_SHOOT3
};

void
w_ak47_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_ak47.fire");
	precache_model("models/w_ak47.mdl");
#else
	Sound_Precache("modelevent_shell.land");
	precache_model("models/v_ak47.mdl");
	precache_model("models/p_ak47.mdl");
#endif
}

void
w_ak47_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.ak47_mag, pl.ammo_762mm, -1);
}

string
w_ak47_wmodel(void)
{
	return "models/w_ak47.mdl";
}

string
w_ak47_pmodel(void)
{
	return "models/p_ak47.mdl";
}

string
w_ak47_deathmsg(void)
{
	return "";
}

int
w_ak47_pickup(player pl, int new, int startammo)
{
#ifdef SERVER

	if (new) {
		if (startammo == -1)
			pl.ak47_mag = 30;
		else
			pl.ak47_mag = startammo;
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
w_ak47_draw(player pl)
{
	Weapons_SetModel("models/v_ak47.mdl");
	Weapons_ViewAnimation(pl, AK47_DRAW);

#ifdef CLIENT
	pl.cs_cross_mindist = 4;
	pl.cs_cross_deltadist = 4;
#endif
}

void
w_ak47_primary(player pl)
{

	if (pl.w_attack_next > 0) {
		return;
	}
	if (!pl.ak47_mag) {
		return;
	}

	Cstrike_ShotMultiplierAdd(pl, 1);
	float accuracy = Cstrike_CalculateAccuracy(pl, 200);
	pl.ak47_mag--;

	int r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(pl, AK47_SHOOT1);
		break;
	case 1:
		Weapons_ViewAnimation(pl, AK47_SHOOT2);
		break;
	default:
		Weapons_ViewAnimation(pl, AK47_SHOOT3);
		break;
	}

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_SHOOT_AK47, 0.45f);
	else
		Animation_PlayerTop(pl, ANIM_CROUCH_SHOOT_AK47, 0.45f);

#ifdef CLIENT
	View_SetMuzzleflash(MUZZLE_RIFLE);
	View_AddEvent(w_rifle_ejectshell, 0.0f);
#else
	TraceAttack_SetRangeModifier(2.375); /* 18 units!!! */
	TraceAttack_SetPenetrationPower(1);
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 36, [accuracy,accuracy], WEAPON_AK47);
	Sound_Play(pl, CHAN_WEAPON, "weapon_ak47.fire");
#endif

	pl.w_attack_next = 0.0955f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_ak47_reload(player pl)
{

	if (pl.w_attack_next > 0.0) {
		return;
	}
	if (pl.ak47_mag >= 30) {
		return;
	}
	if (!pl.ammo_762mm) {
		return;
	}

	Weapons_ViewAnimation(pl, AK47_RELOAD);

#ifdef SERVER
	Weapons_ReloadWeapon(pl, player::ak47_mag, player::ammo_762mm, 30);
#endif

	pl.w_attack_next = 2.4f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_ak47_release(player pl)
{

	w_cstrike_weaponrelease();

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.ak47_mag == 0 && pl.ammo_762mm > 0) {
		Weapons_Reload(pl);
		return;
	}
}

float
w_ak47_aimanim(player pl)
{
	return self.flags & FL_CROUCHING ? ANIM_CROUCH_AIM_AK47 : ANIM_AIM_AK47;
}

void
w_ak47_hud(player pl)
{
#ifdef CLIENT
	Cstrike_DrawCrosshair();
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [72/256,72/256], [24/256, 24/256], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

int
w_ak47_isempty(player pl)
{

	if (pl.ak47_mag <= 0 && pl.ammo_762mm <= 0)
		return 1;

	return 0;
}

void
w_ak47_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (w_ak47_isempty(pl))
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_762mm, AMMO_MAX_762MM, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud11_spr,
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
			g_hud11_spr,
			[0,0],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_ak47 =
{
	.name		= "ak47",
	.id		= ITEM_AK47,
	.slot		= 0,
	.slot_pos	= 7,
	.weight		= 25,
	.allow_drop	= TRUE,
	.draw		= w_ak47_draw,
	.holster	= __NULL__,
	.primary	= w_ak47_primary,
	.secondary	= __NULL__,
	.reload		= w_ak47_reload,
	.release	= w_ak47_release,
	.postdraw	= w_ak47_hud,
	.precache	= w_ak47_precache,
	.pickup		= w_ak47_pickup,
	.updateammo	= w_ak47_updateammo,
	.wmodel		= w_ak47_wmodel,
	.pmodel		= w_ak47_pmodel,
	.deathmsg	= w_ak47_deathmsg,
	.aimanim	= w_ak47_aimanim,
	.hudpic		= w_ak47_hudpic,
	.type		= csweapon_ranged_type,
	.isempty	= w_ak47_isempty
};

#ifdef SERVER
void
weapon_ak47(void)
{
	Weapons_InitItem(WEAPON_AK47);
}
#endif
