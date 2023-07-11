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

/*!QUAKED weapon_p90 (0 0 1) (-16 -16 0) (16 16 32)

COUNTER-STRIKE (1999) ENTITY

FN P90 Weapon

- Buy Menu -
Price: $2350

-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
model="models/w_p90.mdl"
*/

enum
{
	P90_IDLE,
	P90_RELOAD,
	P90_DRAW,
	P90_SHOOT1,
	P90_SHOOT2,
	P90_SHOOT3
};

void
w_p90_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_p90.fire");
	precache_model("models/w_p90.mdl");
#else
	precache_model("models/v_p90.mdl");
	precache_model("models/p_p90.mdl");
#endif
}

void
w_p90_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.p90_mag, pl.ammo_57mm, -1);
}

string
w_p90_wmodel(void)
{
	return "models/w_p90.mdl";
}

string
w_p90_pmodel(player pl)
{
	return "models/p_p90.mdl";
}

string
w_p90_deathmsg(void)
{
	return "";
}

int
w_p90_pickup(player pl, int new, int startammo)
{
#ifdef SERVER

	if (new) {
		if (startammo == -1)
			pl.p90_mag = 50;
		else
			pl.p90_mag = startammo;
	} else {
		if (pl.ammo_57mm < AMMO_MAX_57MM) {
			pl.ammo_57mm = bound(0, pl.ammo_57mm + 50, AMMO_MAX_57MM);
		} else {
			return (0);
		}
	}
#endif
	return (1);
}

void
w_p90_draw(player pl)
{
	Weapons_SetModel("models/v_p90.mdl");
	Weapons_ViewAnimation(pl, P90_DRAW);

#ifdef CLIENT
	pl.cs_cross_mindist = 7;
	pl.cs_cross_deltadist = 3;
#endif
}

void
w_p90_primary(player pl)
{
	int dmg = 0;

	if (pl.w_attack_next > 0.0)
		return;
	if (!pl.p90_mag)
		return;


	float accuracy = Cstrike_CalculateAccuracy(pl, 50,1)+0.0055;
	pl.p90_mag--;

	int r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(pl, P90_SHOOT1);
		break;
	case 1:
		Weapons_ViewAnimation(pl, P90_SHOOT2);
		break;
	default:
		Weapons_ViewAnimation(pl, P90_SHOOT3);
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
	dmg = Skill_GetValue("plr_p90_dmg", 26);
	TraceAttack_SetRangeModifier(1.875); /* 9 but not 10 */
	TraceAttack_SetPenetrationPower(1);
	Cstrike_BulletRecoil_ApplyPre(pl,1);
	TraceAttack_FireBulletsWithDecal(1, pl.origin + pl.view_ofs, dmg, [accuracy,accuracy], WEAPON_P90, "Impact.BigShot");
	Cstrike_BulletRecoil_ApplyPost(pl,1);
	Sound_Play(pl, CHAN_WEAPON, "weapon_p90.fire");
#endif

	Cstrike_ShotMultiplierAdd(pl, 1.1, 1.1);
	pl.w_attack_next = 0.07f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_p90_reload(player pl)
{

	if (pl.w_attack_next > 0.0)
		return;
	if (pl.p90_mag >= 50)
		return;
	if (!pl.ammo_57mm)
		return;

	Weapons_ViewAnimation(pl, P90_RELOAD);

	pl.w_attack_next = 3.3f;
	pl.w_idle_next = pl.w_attack_next;

#ifdef SERVER
	static void w_weapon_reload_done(void) {
		player pl = (player)self;
		Weapons_ReloadWeapon(pl, player::p90_mag, player::ammo_57mm, 50);
		Cstrike_ShotReset(pl);
	}

	pl.think = w_weapon_reload_done;
	pl.nextthink = time + pl.w_attack_next - 0.1f;
#endif
}

void
w_p90_release(player pl)
{

	w_cstrike_weaponrelease();

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.p90_mag == 0 && pl.ammo_57mm > 0) {
		Weapons_Reload(pl);
		return;
	}
}

float
w_p90_aimanim(player pl)
{
	return w_ak47_aimanim(pl);
}

void
w_p90_hud(player pl)
{
#ifdef CLIENT
	Cstrike_DrawCrosshair();
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [120/256,96/256], [24/256, 24/256], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

int
w_p90_isempty(player pl)
{

	if (pl.p90_mag <= 0 && pl.ammo_57mm <= 0)
		return 1;

	return 0;
}

void
w_p90_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (w_p90_isempty(pl))
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_57mm, AMMO_MAX_57MM, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud13_spr,
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
			g_hud12_spr,
			[0,0],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_p90 =
{
	.name		= "p90",
	.id		= ITEM_P90,
	.slot		= 0,
	.slot_pos	= 3,
	.weight		= 26,
	.allow_drop	= TRUE,
	.draw		= w_p90_draw,
	.holster	= __NULL__,
	.primary	= w_p90_primary,
	.secondary	= __NULL__,
	.reload		= w_p90_reload,
	.release	= w_p90_release,
	.postdraw	= w_p90_hud,
	.precache	= w_p90_precache,
	.pickup		= w_p90_pickup,
	.updateammo	= w_p90_updateammo,
	.wmodel		= w_p90_wmodel,
	.pmodel		= w_p90_pmodel,
	.deathmsg	= w_p90_deathmsg,
	.aimanim	= w_p90_aimanim,
	.hudpic		= w_p90_hudpic,
	.type		= csweapon_ranged_type,
	.isempty	= w_p90_isempty
};

#ifdef SERVER
void
weapon_p90(void)
{
	Weapons_InitItem(WEAPON_P90);
}
#endif
