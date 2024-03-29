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

/*!QUAKED weapon_ump45 (0 0 1) (-16 -16 0) (16 16 32)

COUNTER-STRIKE (1999) ENTITY

Heckler & Koch UMP .45 ACP Weapon

- Buy Menu -
Price: $1700

-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
model="models/w_ump45.mdl"
*/

enum
{
	UMP45_IDLE,
	UMP45_RELOAD,
	UMP45_DRAW,
	UMP45_SHOOT1,
	UMP45_SHOOT2,
	UMP45_SHOOT3
};

void
w_ump45_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_ump45.fire");
	precache_model("models/w_ump45.mdl");
#else
	precache_model("models/v_ump45.mdl");
	precache_model("models/p_ump45.mdl");
#endif
}

void
w_ump45_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.ump45_mag, pl.ammo_45acp, -1);
}

string
w_ump45_wmodel(void)
{
	return "models/w_ump45.mdl";
}

string
w_ump45_pmodel(player pl)
{
	return "models/p_ump45.mdl";
}

string
w_ump45_deathmsg(void)
{
	return "";
}

int
w_ump45_pickup(player pl, int new, int startammo)
{
#ifdef SERVER

	if (new) {
		if (startammo == -1)
			pl.ump45_mag = 25;
		else
			pl.ump45_mag = startammo;
	} else {
		if (pl.ammo_45acp < AMMO_MAX_45ACP) {
			pl.ammo_45acp = bound(0, pl.ammo_45acp + 25, AMMO_MAX_45ACP);
		} else {
			return (0);
		}
	}
#endif
	return (1);
}

void
w_ump45_draw(player pl)
{
	Weapons_SetModel("models/v_ump45.mdl");
	Weapons_ViewAnimation(pl, UMP45_DRAW);

#ifdef CLIENT
	pl.cs_cross_mindist = 6;
	pl.cs_cross_deltadist = 3;
	CStrikeView_UpdateGeomset(pl);
#endif
}

void
w_ump45_primary(player pl)
{
	int dmg = 0;

	if (pl.w_attack_next > 0.0)
		return;
	if (!pl.ump45_mag)
		return;


	float accuracy = Cstrike_CalculateAccuracy(pl, 100,1)+0.003;
	pl.ump45_mag--;

	int r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(pl, UMP45_SHOOT1);
		break;
	case 1:
		Weapons_ViewAnimation(pl, UMP45_SHOOT2);
		break;
	default:
		Weapons_ViewAnimation(pl, UMP45_SHOOT3);
		break;
	}

	if (pl.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_SHOOT_MP5, 0.45f);
	else
		Animation_PlayerTop(pl, ANIM_CROUCH_SHOOT_MP5, 0.45f);

#ifdef CLIENT
	View_SetMuzzleflash(MUZZLE_RIFLE);
	View_AddEvent(w_pistol_ejectshell, 0.0f);
#else
	dmg = Skill_GetValue("plr_ump45_dmg", 30);
	TraceAttack_SetRangeModifier(0.875); /* 6, but not 7 */
	TraceAttack_SetPenetrationPower(1);
	Cstrike_BulletRecoil_ApplyPre(pl,1.2);
	TraceAttack_FireBulletsWithDecal(1, pl.origin + pl.view_ofs, dmg, [accuracy,accuracy], WEAPON_UMP45, "Impact.BigShot");
	Cstrike_BulletRecoil_ApplyPost(pl,1.2);
	Sound_Play(pl, CHAN_WEAPON, "weapon_ump45.fire");
#endif
	Cstrike_ShotMultiplierAdd(pl, 1, .9,accuracy);
	pl.w_attack_next = 0.105f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_ump45_reload(player pl)
{

	if (pl.w_attack_next > 0.0)
		return;
	if (pl.ump45_mag >= 25)
		return;
	if (!pl.ammo_45acp)
		return;

	Weapons_ViewAnimation(pl, UMP45_RELOAD);

	pl.w_attack_next = 3.5f;
	pl.w_idle_next = pl.w_attack_next;

#ifdef SERVER
	static void w_weapon_reload_done(void) {
		player pl = (player)self;
		Weapons_ReloadWeapon(pl, player::ump45_mag, player::ammo_45acp, 25);
		Cstrike_ShotReset(pl);
	}

	pl.think = w_weapon_reload_done;
	pl.nextthink = time + pl.w_attack_next - 0.1f;
#endif
}

void
w_ump45_release(player pl)
{

	w_cstrike_weaponrelease();

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.ump45_mag == 0 && pl.ammo_45acp > 0) {
		Weapons_Reload(pl);
		return;
	}
}

float
w_ump45_aimanim(player pl)
{
	return w_ak47_aimanim(pl);
}

void
w_ump45_hud(player pl)
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
w_ump45_isempty(player pl)
{

	if (pl.ump45_mag <= 0 && pl.ammo_45acp <= 0)
		return 1;

	return 0;
}

void
w_ump45_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (w_ump45_isempty(pl))
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_45acp, AMMO_MAX_45ACP, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud16_spr,
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
			g_hud16_spr,
			[0,0],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_ump45 =
{
	.name		= "ump45",
	.id		= ITEM_UMP45,
	.slot		= 0,
	.slot_pos	= 4,
	.weight		= 25,
	.allow_drop	= TRUE,
	.draw		= w_ump45_draw,
	.holster	= __NULL__,
	.primary	= w_ump45_primary,
	.secondary	= __NULL__,
	.reload		= w_ump45_reload,
	.release	= w_ump45_release,
	.postdraw	= w_ump45_hud,
	.precache	= w_ump45_precache,
	.pickup		= w_ump45_pickup,
	.updateammo	= w_ump45_updateammo,
	.wmodel		= w_ump45_wmodel,
	.pmodel		= w_ump45_pmodel,
	.deathmsg	= w_ump45_deathmsg,
	.aimanim	= w_ump45_aimanim,
	.hudpic		= w_ump45_hudpic,
	.type		= csweapon_ranged_type,
	.isempty	= w_ump45_isempty
};

#ifdef SERVER
void
weapon_ump45(void)
{
	Weapons_InitItem(WEAPON_UMP45);
}
#endif
