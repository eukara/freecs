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

/*QUAKED weapon_mp5navy (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_mp5.mdl"

COUNTER-STRIKE (1999) ENTITY

Heckler & Koch MP5-Navy Weapon

- Buy Menu -
Price: $1500

*/

enum
{
	MP5_IDLE,
	MP5_RELOAD,
	MP5_DRAW,
	MP5_SHOOT1,
	MP5_SHOOT2,
	MP5_SHOOT3
};

void
w_mp5_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_mp5.fire");
	precache_model("models/w_mp5.mdl");
#else
	precache_model("models/v_mp5.mdl");
	precache_model("models/p_mp5.mdl");
#endif
}

void
w_mp5_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.mp5_mag, pl.ammo_9mm, -1);
}

string
w_mp5_wmodel(void)
{
	return "models/w_mp5.mdl";
}

string
w_mp5_pmodel(player pl)
{
	return "models/p_mp5.mdl";
}

string
w_mp5_deathmsg(void)
{
	return "";
}

int
w_mp5_pickup(player pl, int new, int startammo)
{
#ifdef SERVER

	if (new) {
		if (startammo == -1)
			pl.mp5_mag = 30;
		else
			pl.mp5_mag = startammo;
	} else {
		if (pl.ammo_9mm < AMMO_MAX_9MM) {
			pl.ammo_9mm = bound(0, pl.ammo_9mm + 30, AMMO_MAX_9MM);
		} else {
			return (0);
		}
	}
#endif
	return (1);
}

void
w_mp5_draw(player pl)
{
	Weapons_SetModel("models/v_mp5.mdl");
	Weapons_ViewAnimation(pl, MP5_DRAW);

#ifdef CLIENT
	pl.cs_cross_mindist = 5;
	pl.cs_cross_deltadist = 2;
#endif
}

void
w_mp5_primary(player pl)
{
	int dmg = 0;

	if (pl.w_attack_next > 0.0)
		return;
	if (!pl.mp5_mag)
		return;


	float accuracy = Cstrike_CalculateAccuracy(pl,60,1.25)+0.0045f;
	pl.mp5_mag--;

	int r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(pl, MP5_SHOOT1);
		break;
	case 1:
		Weapons_ViewAnimation(pl, MP5_SHOOT2);
		break;
	default:
		Weapons_ViewAnimation(pl, MP5_SHOOT3);
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
	dmg = Skill_GetValue("plr_mp5_dmg", 26);
	TraceAttack_SetRangeModifier(1.25); /* 9 units but not 10 */
	TraceAttack_SetPenetrationPower(1);
	Cstrike_BulletRecoil_ApplyPre(pl,.825f);
	TraceAttack_FireBulletsWithDecal(1, pl.origin + pl.view_ofs, dmg, [accuracy,accuracy], WEAPON_MP5, "Impact.BigShot");
	Cstrike_BulletRecoil_ApplyPost(pl,.825f);
	Sound_Play(pl, CHAN_WEAPON, "weapon_mp5.fire");
#endif

	Cstrike_ShotMultiplierAdd(pl, .5f, 1.25f,accuracy);
	pl.w_attack_next = 0.08f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_mp5_reload(player pl)
{

	if (pl.w_attack_next > 0.0)
		return;
	if (pl.mp5_mag >= 30)
		return;
	if (!pl.ammo_9mm)
		return;

	Weapons_ViewAnimation(pl, MP5_RELOAD);

	pl.w_attack_next = 2.6f;
	pl.w_idle_next = pl.w_attack_next;

#ifdef SERVER
	static void w_weapon_reload_done(void) {
		player pl = (player)self;
		Weapons_ReloadWeapon(pl, player::mp5_mag, player::ammo_9mm, 30);
	}

	pl.think = w_weapon_reload_done;
	pl.nextthink = time + pl.w_attack_next - 0.1f;
#endif
}

void
w_mp5_release(player pl)
{

	w_cstrike_weaponrelease();

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.mp5_mag == 0 && pl.ammo_9mm > 0) {
		Weapons_Reload(pl);
		return;
	}
}

float
w_mp5_aimanim(player pl)
{
	return w_ak47_aimanim(pl);
}

void
w_mp5_hud(player pl)
{
#ifdef CLIENT
	Cstrike_DrawCrosshair();
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [48/256,72/256], [24/256, 24/256], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

int
w_mp5_isempty(player pl)
{

	if (pl.mp5_mag <= 0 && pl.ammo_9mm <= 0)
		return 1;

	return 0;
}

void
w_mp5_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (w_mp5_isempty(pl))
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_9mm, AMMO_MAX_9MM, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud4_spr,
			[0,180/256],
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
			[0,180/256],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_mp5 =
{
	.name		= "mp5navy",
	.id		= ITEM_MP5,
	.slot		= 0,
	.slot_pos	= 2,
	.weight		= 25,
	.allow_drop	= TRUE,
	.draw		= w_mp5_draw,
	.holster	= __NULL__,
	.primary	= w_mp5_primary,
	.secondary	= __NULL__,
	.reload		= w_mp5_reload,
	.release	= w_mp5_release,
	.postdraw	= w_mp5_hud,
	.precache	= w_mp5_precache,
	.pickup		= w_mp5_pickup,
	.updateammo	= w_mp5_updateammo,
	.wmodel		= w_mp5_wmodel,
	.pmodel		= w_mp5_pmodel,
	.deathmsg	= w_mp5_deathmsg,
	.aimanim	= w_mp5_aimanim,
	.hudpic		= w_mp5_hudpic,
	.type		= csweapon_ranged_type,
	.isempty	= w_mp5_isempty
};

#ifdef SERVER
void
weapon_mp5navy(void)
{
	Weapons_InitItem(WEAPON_MP5);
}
#endif
