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

/*!QUAKED weapon_m249 (0 0 1) (-16 -16 0) (16 16 32)

COUNTER-STRIKE (1999) ENTITY

FN M249 Para Weapon

- Buy Menu -
Price: $5750

-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
model="models/w_m249.mdl"
*/

enum
{
	PARA_IDLE,
	PARA_SHOOT1,
	PARA_SHOOT2,
	PARA_RELOAD,
	PARA_DRAW
};

void
w_para_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_para.fire");
	precache_model("models/w_m249.mdl");
#else
	precache_model("models/v_m249.mdl");
	precache_model("models/p_m249.mdl");
#endif
}

void
w_para_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.para_mag, pl.ammo_556mmbox, -1);
}

string
w_para_wmodel(void)
{
	return "models/w_m249.mdl";
}

string
w_para_pmodel(player pl)
{
	return "models/p_m249.mdl";
}

string
w_para_deathmsg(void)
{
	return "";
}

int
w_para_pickup(player pl, int new, int startammo)
{
#ifdef SERVER

	if (new) {
		if (startammo == -1)
			pl.para_mag = 100;
		else
			pl.para_mag = startammo;
	} else {
		if (pl.ammo_556mmbox < AMMO_MAX_556MMBOX) {
			pl.ammo_556mmbox = bound(0, pl.ammo_556mmbox + 100, AMMO_MAX_556MMBOX);
		} else {
			return (0);
		}
	}
#endif
	return (1);
}

void
w_para_draw(player pl)
{
	Weapons_SetModel("models/v_m249.mdl");
	Weapons_ViewAnimation(pl, PARA_DRAW);

#ifdef CLIENT
	pl.cs_cross_mindist = 6;
	pl.cs_cross_deltadist = 3;
	CStrikeView_UpdateGeomset(pl);
#endif
}

void
w_para_primary(player pl)
{
	int dmg = 0;

	if (pl.w_attack_next > 0.0)
		return;
	if (!pl.para_mag)
		return;


	float accuracy = Cstrike_CalculateAccuracy(pl, 70);
	
	pl.para_mag--;

	int r = (float)input_sequence % 2;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(pl, SCOUT_SHOOT1);
		break;
	default:
		Weapons_ViewAnimation(pl, SCOUT_SHOOT2);
		break;
	}

	if (pl.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_CROUCH_SHOOT_PARA, 0.45f);
	else
		Animation_PlayerTop(pl, ANIM_SHOOT_PARA, 0.45f);

#ifdef CLIENT
	View_SetMuzzleflash(MUZZLE_RIFLE);
	View_AddEvent(w_rifle_ejectshell, 0.0f);
#else
	dmg = Skill_GetValue("plr_para_dmg", 35);
	TraceAttack_SetRangeModifier(2.125);
	TraceAttack_SetPenetrationPower(1);
	Cstrike_BulletRecoil_ApplyPost(pl,1);
	TraceAttack_FireBulletsWithDecal(1, pl.origin + pl.view_ofs, dmg, [accuracy,accuracy], WEAPON_PARA, "Impact.BigShot");
	Cstrike_BulletRecoil_ApplyPost(pl,1);
	Sound_Play(pl, CHAN_WEAPON, "weapon_para.fire");
#endif

	Cstrike_ShotMultiplierAdd(pl, 1, 1,accuracy);
	pl.w_attack_next = 0.1f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_para_reload(player pl)
{

	if (pl.w_attack_next > 0.0)
		return;
	if (pl.para_mag >= 100)
		return;
	if (!pl.ammo_556mmbox)
		return;

	Weapons_ViewAnimation(pl, PARA_RELOAD);

	pl.w_attack_next = 3.0f;
	pl.w_idle_next = pl.w_attack_next;

#ifdef SERVER
	static void w_weapon_reload_done(void) {
		player pl = (player)self;
		Weapons_ReloadWeapon(pl, player::para_mag, player::ammo_556mmbox, 100);
		Cstrike_ShotReset(pl);
	}

	pl.think = w_weapon_reload_done;
	pl.nextthink = time + pl.w_attack_next - 0.1f;
#endif
}

void
w_para_release(player pl)
{

	w_cstrike_weaponrelease();

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.para_mag == 0 && pl.ammo_556mmbox > 0) {
		Weapons_Reload(pl);
		return;
	}
}

float
w_para_aimanim(player pl)
{
	return w_ak47_aimanim(pl);
}

void
w_para_hud(player pl)
{
#ifdef CLIENT
	Cstrike_DrawCrosshair();
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [0,96/256], [24/256, 24/256], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

int
w_para_isempty(player pl)
{

	if (pl.para_mag <= 0 && pl.ammo_556mmbox <= 0)
		return 1;

	return 0;
}

void
w_para_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (w_para_isempty(pl))
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_556mmbox, AMMO_MAX_556MMBOX, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud6_spr,
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
			g_hud3_spr,
			[0,0],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_para =
{
	.name		= "m249",
	.id		= ITEM_PARA,
	.slot		= 0,
	.slot_pos	= 15,
	.weight		= 25,
	.allow_drop	= TRUE,
	.draw		= w_para_draw,
	.holster	= __NULL__,
	.primary	= w_para_primary,
	.secondary	= __NULL__,
	.reload		= w_para_reload,
	.release	= w_para_release,
	.postdraw	= w_para_hud,
	.precache	= w_para_precache,
	.pickup		= w_para_pickup,
	.updateammo	= w_para_updateammo,
	.wmodel		= w_para_wmodel,
	.pmodel		= w_para_pmodel,
	.deathmsg	= w_para_deathmsg,
	.aimanim	= w_para_aimanim,
	.hudpic		= w_para_hudpic,
	.type		= csweapon_ranged_type,
	.isempty	= w_para_isempty
};

#ifdef SERVER
void
weapon_m249(void)
{
	Weapons_InitItem(WEAPON_PARA);
}
#endif
