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

/*QUAKED weapon_sg552 (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_sg552.mdl"

COUNTER-STRIKE (1999) ENTITY

SIG SG 552 Commando Weapon

- Buy Menu -
Price: $3500

*/

enum
{
	SG552_IDLE,
	SG552_RELOAD,
	SG552_DRAW,
	SG552_SHOOT1,
	SG552_SHOOT2,
	SG552_SHOOT3
};

void
w_sg552_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_sg552.fire");
	precache_model("models/w_sg552.mdl");
#else
	precache_model("models/v_sg552.mdl");
	precache_model("models/p_sg552.mdl");
#endif
}

void
w_sg552_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.sg552_mag, pl.ammo_556mm, -1);
}

string
w_sg552_wmodel(void)
{
	return "models/w_sg552.mdl";
}

string
w_sg552_pmodel(player pl)
{
	return "models/p_sg552.mdl";
}

string
w_sg552_deathmsg(void)
{
	return "";
}

int
w_sg552_pickup(player pl, int new, int startammo)
{
#ifdef SERVER

	if (new) {
		if (startammo == -1)
			pl.sg552_mag = 30;
		else
			pl.sg552_mag = startammo;
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
w_sg552_draw(player pl)
{
	Weapons_SetModel("models/v_sg552.mdl");
	Weapons_ViewAnimation(pl, SG552_DRAW);

#ifdef CLIENT
	pl.cs_cross_mindist = 5;
	pl.cs_cross_deltadist = 3;
#endif
}

void
w_sg552_primary(player pl)
{
	int dmg = 0;

	if (pl.w_attack_next > 0.0)
		return;
	if (!pl.sg552_mag)
		return;


	float accuracy = Cstrike_CalculateAccuracy(pl, 75,3)*pl.viewzoom;
	pl.sg552_mag--;

	int r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(pl, SG552_SHOOT1);
		break;
	case 1:
		Weapons_ViewAnimation(pl, SG552_SHOOT2);
		break;
	default:
		Weapons_ViewAnimation(pl, SG552_SHOOT3);
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
	dmg = Skill_GetValue("plr_sg552_dmg", 33);
	TraceAttack_SetRangeModifier(2.125);
	TraceAttack_SetPenetrationPower(1);
	Cstrike_BulletRecoil_ApplyPre(pl,0.726f);
	TraceAttack_FireBulletsWithDecal(1, pl.origin + pl.view_ofs, dmg, [accuracy,accuracy], WEAPON_SG552, "Impact.BigShot");
	Cstrike_BulletRecoil_ApplyPost(pl,0.725f);
	Sound_Play(pl, CHAN_WEAPON, "weapon_sg552.fire");
#endif

	Cstrike_ShotMultiplierAdd(pl, 2.2, 0.9,accuracy);
	if (pl.viewzoom == 1.0f)
		pl.w_attack_next = 0.0825f;
	else
		pl.w_attack_next = 0.15f;

	pl.w_idle_next = pl.w_attack_next;
}

void
w_sg552_secondary(player pl)
{

	if (pl.w_attack_next)
		return;

	/* Simple toggle of fovs */
	if (pl.viewzoom == 1.0f)
		pl.viewzoom = 0.2f;
	else
		pl.viewzoom = 1.0f;

	pl.w_attack_next = 0.5f;
}

void
w_sg552_reload(player pl)
{

	if (pl.w_attack_next > 0.0)
		return;
	if (pl.sg552_mag >= 30)
		return;
	if (!pl.ammo_556mm)
		return;

	Weapons_ViewAnimation(pl, SG552_RELOAD);

	pl.w_attack_next = 3.2f;
	pl.w_idle_next = pl.w_attack_next;

#ifdef SERVER
	static void w_weapon_reload_done(void) {
		player pl = (player)self;
		Weapons_ReloadWeapon(pl, player::sg552_mag, player::ammo_556mm, 30);
	}

	pl.think = w_weapon_reload_done;
	pl.nextthink = time + pl.w_attack_next - 0.1f;
#endif
}

void
w_sg552_release(player pl)
{

	w_cstrike_weaponrelease();

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.sg552_mag == 0 && pl.ammo_556mm > 0) {
		Weapons_Reload(pl);
		return;
	}
}

float
w_sg552_aimanim(player pl)
{
	return w_ak47_aimanim(pl);
}

void
w_sg552_hud(player pl)
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
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [0,96/256], [24/256, 24/256], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

int
w_sg552_isempty(player pl)
{

	if (pl.sg552_mag <= 0 && pl.ammo_556mm <= 0)
		return 1;

	return 0;
}

void
w_sg552_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (w_sg552_isempty(pl))
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_556mm, AMMO_MAX_556MM, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud11_spr,
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
			g_hud10_spr,
			[0,45/256],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_sg552 =
{
	.name		= "sg552",
	.id		= ITEM_SG552,
	.slot		= 0,
	.slot_pos	= 8,
	.weight		= 25,
	.allow_drop	= TRUE,
	.draw		= w_sg552_draw,
	.holster	= __NULL__,
	.primary	= w_sg552_primary,
	.secondary	= w_sg552_secondary,
	.reload		= w_sg552_reload,
	.release	= w_sg552_release,
	.postdraw	= w_sg552_hud,
	.precache	= w_sg552_precache,
	.pickup		= w_sg552_pickup,
	.updateammo	= w_sg552_updateammo,
	.wmodel		= w_sg552_wmodel,
	.pmodel		= w_sg552_pmodel,
	.deathmsg	= w_sg552_deathmsg,
	.aimanim	= w_sg552_aimanim,
	.hudpic		= w_sg552_hudpic,
	.type		= csweapon_ranged_type,
	.isempty	= w_sg552_isempty
};

#ifdef SERVER
void
weapon_sg552(void)
{
	Weapons_InitItem(WEAPON_SG552);
}
#endif
