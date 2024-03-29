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

/*!QUAKED weapon_c4bomb (0 0 1) (-16 -16 0) (16 16 32)

COUNTER-STRIKE (1999) ENTITY

C4 Bomb Weapon, Bomb Defusal Gamemode Entity

Default arsenal for Terrorists

Can only be picked up by Terrorists and planted in
func_bombtarget brush entities.

-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
model="models/w_c4.mdl"
*/

/* C4 weapon logic */

enum
{
	C4_IDLE,
	C4_DRAW,
	C4_DROP,
	C4_ENTERCODE
};

enum
{
	C4S_NONE,
	C4S_ENTERINGCODE,
	C4S_DROPPING,
	C4S_DONE
};

void
w_c4bomb_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_c4bomb.disarm");
	Sound_Precache("weapon_c4bomb.disarmed");
	Sound_Precache("weapon_c4bomb.explode");
	Sound_Precache("weapon_c4bomb.plant");
	Sound_Precache("weapon_c4bomb.beep1");
	Sound_Precache("weapon_c4bomb.beep2");
	Sound_Precache("weapon_c4bomb.beep3");
	Sound_Precache("weapon_c4bomb.beep4");
	Sound_Precache("weapon_c4bomb.beep5");
	precache_sound("weapons/c4_beep1.wav");
	precache_sound("weapons/c4_beep2.wav");
	precache_sound("weapons/c4_beep3.wav");
	precache_sound("weapons/c4_beep4.wav");
	precache_sound("weapons/c4_beep5.wav");
	precache_sound("weapons/c4_disarmed.wav");
	precache_sound("weapons/c4_disarm.wav");
	precache_model("models/w_c4.mdl");
	precache_model("models/w_backpack.mdl");
	precache_model("sprites/ledglow.spr");
#else
	precache_model("models/v_c4.mdl");
	precache_model("models/p_c4.mdl");
#endif
}

void
w_c4bomb_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, -1, 1, -1);
}

string
w_c4bomb_wmodel(void)
{
	return "models/w_backpack.mdl";
}

string
w_c4bomb_pmodel(player pl)
{
	return "models/p_c4.mdl";
}

string
w_c4bomb_deathmsg(void)
{
	return "";
}

void
w_c4bomb_draw(player pl)
{
	Weapons_SetModel("models/v_c4.mdl");
	Weapons_ViewAnimation(pl, C4_DRAW);
	pl.mode_temp = 0;

#ifdef CLIENT
	CStrikeView_UpdateGeomset(pl);
#endif
}

void
w_c4bomb_release(player pl)
{

	w_cstrike_weaponrelease();
	
	if (pl.mode_temp == C4S_DROPPING) {
		if (pl.w_idle_next <= 0.0f) {
			pl.mode_temp = C4S_DONE;
#ifdef SERVER
			C4Bomb_Plant(pl);
			Weapons_RemoveItem(pl, WEAPON_C4BOMB);
#endif
		}
		return;
	}

	/* reset animation */
	if (pl.mode_temp != C4S_NONE) {
		Weapons_ViewAnimation(pl, C4_IDLE);
	}
	pl.mode_temp = C4S_NONE;
	pl.w_idle_next = 0.0f;
}

void
w_c4bomb_primary(player pl)
{

	if (!(pl.gflags & GF_BOMBZONE)) {
		return;
	}

	pl.flags |= FL_FROZEN;
	input_movevalues = [0,0,0];

	switch (pl.mode_temp) {
	case C4S_NONE:
			pl.mode_temp = C4S_ENTERINGCODE;
			Weapons_ViewAnimation(pl, C4_ENTERCODE);
			pl.w_idle_next = 3.0f;
			break;
	case C4S_ENTERINGCODE:
			if (pl.w_idle_next <= 0.0f) {
				pl.mode_temp = C4S_DROPPING;
				Weapons_ViewAnimation(pl, C4_DROP);
				pl.w_idle_next = 1.0f;
			}
			break;
	case C4S_DROPPING:
			w_c4bomb_release(pl);
			return;
			break;
	default:
		break;
	}

	pl.w_attack_next = 0.0f;
}

float
w_c4bomb_aimanim(player pl)
{
	return self.flags & FL_CROUCHING ? ANIM_CROUCH_AIM_C4 : ANIM_AIM_C4;
}

void
w_c4bomb_hud(player pl)
{
#ifdef CLIENT
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [96/256,96/256], [24/256, 24/256], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

int
w_c4bomb_pickup(player pl, int new, int startammo)
{
#ifdef SERVER

	if (pl.team != TEAM_T)
		return (0);
#endif
	return (1);
}

void
w_c4bomb_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud4_spr,
			[0,0],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			g_hud1_spr,
			[0,0],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_c4bomb =
{
	.name		= "c4",
	.id		= ITEM_C4BOMB,
	.slot		= 4,
	.slot_pos	= 0,
	.allow_drop	= TRUE,
	.draw		= w_c4bomb_draw,
	.holster	= __NULL__,
	.primary	= w_c4bomb_primary,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= w_c4bomb_release,
	.postdraw	= w_c4bomb_hud,
	.precache	= w_c4bomb_precache,
	.pickup		= w_c4bomb_pickup,
	.updateammo	= w_c4bomb_updateammo,
	.wmodel		= w_c4bomb_wmodel,
	.pmodel		= w_c4bomb_pmodel,
	.deathmsg	= w_c4bomb_deathmsg,
	.aimanim	= w_c4bomb_aimanim,
	.hudpic		= w_c4bomb_hudpic
};

#ifdef SERVER
void
weapon_c4bomb(void)
{
	Weapons_InitItem(WEAPON_C4BOMB);
}
#endif
