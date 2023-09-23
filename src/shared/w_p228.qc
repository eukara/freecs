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

/*!QUAKED weapon_p228 (0 0 1) (-16 -16 0) (16 16 32)

COUNTER-STRIKE (1999) ENTITY

SIG P228 Weapon

- Buy Menu -
Price: $600

-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
model="models/w_p228.mdl"
*/

enum
{
	P228_IDLE,
	P228_SHOOT1,
	P228_SHOOT2,
	P228_SHOOT3,
	P228_SHOOT_EMPTY,
	P228_RELOAD,
	P228_DRAW
};

void
w_p228_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_p228.fire");
	precache_model("models/w_p228.mdl");
#else
	precache_model("models/v_p228.mdl");
	precache_model("models/p_p228.mdl");
#endif
}

void
w_p228_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.p228_mag, pl.ammo_357sig, -1);
}

string
w_p228_wmodel(void)
{
	return "models/w_p228.mdl";
}

string
w_p228_pmodel(player pl)
{
	return "models/p_p228.mdl";
}

string
w_p228_deathmsg(void)
{
	return "";
}

int
w_p228_pickup(player pl, int new, int startammo)
{
#ifdef SERVER

	if (new) {
		if (startammo == -1)
			pl.p228_mag = 13;
		else
			pl.p228_mag = startammo;
	} else {
		if (pl.ammo_357sig < AMMO_MAX_357SIG) {
			pl.ammo_357sig = bound(0, pl.ammo_357sig + 13, AMMO_MAX_357SIG);
		} else {
			return (0);
		}
	}
#endif
	return (1);
}

void
w_p228_draw(player pl)
{
	Weapons_SetModel("models/v_p228.mdl");
	Weapons_ViewAnimation(pl, P228_DRAW);

#ifdef CLIENT
	pl.cs_cross_mindist = 8;
	pl.cs_cross_deltadist = 3;
#endif
}

void
w_p228_primary(player pl)
{

	if (pl.w_attack_next > 0.0)
		return;
	if (pl.gflags & GF_SEMI_TOGGLED)
		return;
	if (!pl.p228_mag)
		return;


	float accuracy = Cstrike_CalculateAccuracy(pl, 200,1.6) + 0.004f;
	int dmg = 0;
	pl.p228_mag--;

	if (pl.p228_mag <= 0) {
		Weapons_ViewAnimation(pl, P228_SHOOT_EMPTY);
	} else {
		int r = (float)input_sequence % 3;
		switch (r) {
		case 0:
			Weapons_ViewAnimation(pl, P228_SHOOT1);
			break;
		case 1:
			Weapons_ViewAnimation(pl, P228_SHOOT2);
			break;
		default:
			Weapons_ViewAnimation(pl, P228_SHOOT3);
			break;
		}
	}

	if (pl.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_SHOOT_ONEHAND, 0.45f);
	else
		Animation_PlayerTop(pl, ANIM_CROUCH_SHOOT_ONEHAND, 0.45f);

#ifdef CLIENT
	View_SetMuzzleflash(MUZZLE_RIFLE);
	View_AddEvent(w_pistol_ejectshell, 0.0f);
#else
	dmg = Skill_GetValue("plr_p228_dmg", 40);
	TraceAttack_SetRangeModifier(1.5); /* penetrates 11, but not 12 units */
	TraceAttack_SetPenetrationPower(1);
	Cstrike_BulletRecoil_ApplyPre(pl,1.05);
	TraceAttack_FireBulletsWithDecal(1, pl.origin + pl.view_ofs, dmg, [accuracy,accuracy], WEAPON_P228, "Impact.BigShot");
	Cstrike_BulletRecoil_ApplyPost(pl,1.05);
	Sound_Play(pl, CHAN_WEAPON, "weapon_p228.fire");
#endif
	Cstrike_ShotMultiplierAdd(pl, 6, 0.5f,accuracy);

	pl.gflags |= GF_SEMI_TOGGLED;
	pl.w_attack_next = 0.1425f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_p228_reload(player pl)
{

	if (pl.w_attack_next > 0.0)
		return;
	if (pl.p228_mag >= 13)
		return;
	if (!pl.ammo_357sig)
		return;

	Weapons_ViewAnimation(pl, P228_RELOAD);

	pl.w_attack_next = 2.7f;
	pl.w_idle_next = pl.w_attack_next;

#ifdef SERVER
	static void w_weapon_reload_done(void) {
		player pl = (player)self;
		Weapons_ReloadWeapon(pl, player::p228_mag, player::ammo_357sig, 13);
		Cstrike_ShotReset(pl);
	}

	pl.think = w_weapon_reload_done;
	pl.nextthink = time + pl.w_attack_next - 0.1f;
#endif
}

void
w_p228_release(player pl)
{

	w_cstrike_weaponrelease();

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.p228_mag == 0 && pl.ammo_357sig > 0) {
		Weapons_Reload(pl);
		return;
	}
}

float
w_p228_aimanim(player pl)
{
	return w_deagle_aimanim(pl);
}

void
w_p228_hud(player pl)
{
#ifdef CLIENT
	Cstrike_DrawCrosshair();
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [120/256,72/256], [24/256, 24/256], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

int
w_p228_isempty(player pl)
{

	if (pl.p228_mag <= 0 && pl.ammo_357sig <= 0)
		return 1;

	return 0;
}

void
w_p228_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (w_p228_isempty(pl))
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_357sig, AMMO_MAX_357SIG, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud13_spr,
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
			g_hud12_spr,
			[0,90/256],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_p228 =
{
	.name		= "p228",
	.id		= ITEM_P228,
	.slot		= 1,
	.slot_pos	= 3,
	.weight		= 5,
	.allow_drop	= TRUE,
	.draw		= w_p228_draw,
	.holster	= __NULL__,
	.primary	= w_p228_primary,
	.secondary	= __NULL__,
	.reload		= w_p228_reload,
	.release	= w_p228_release,
	.postdraw	= w_p228_hud,
	.precache	= w_p228_precache,
	.pickup		= w_p228_pickup,
	.updateammo	= w_p228_updateammo,
	.wmodel		= w_p228_wmodel,
	.pmodel		= w_p228_pmodel,
	.deathmsg	= w_p228_deathmsg,
	.aimanim	= w_p228_aimanim,
	.hudpic		= w_p228_hudpic,
	.type		= csweapon_ranged_type,
	.isempty	= w_p228_isempty
};

#ifdef SERVER
void
weapon_p228(void)
{
	Weapons_InitItem(WEAPON_P228);
}
#endif
