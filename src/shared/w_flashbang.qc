/*
 * Copyright (c) 2016-2021 Marco Hladik <marco@icculus.org>
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

/*QUAKED weapon_flashbang (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_flashbang.mdl"

COUNTER-STRIKE (1999) ENTITY

Concussion (Flashbang) Grenade Weapon

When thrown, nearby players become blinded temporarily from the blast.

- Buy Menu -
Price: $200

*/

enum
{
	FLASHBANG_IDLE,
	FLASHBANG_PULLPIN,
	FLASHBANG_THROW,
	FLASHBANG_DRAW,
};

void
w_flashbang_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_flashbang.bounce");
	Sound_Precache("weapon_flashbang.explode");
	precache_model("models/w_flashbang.mdl");
#else
	precache_model("models/v_flashbang.mdl");
	precache_model("models/p_flashbang.mdl");
#endif
}

void
w_flashbang_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, -1, pl.ammo_fbgrenade, pl.mode_temp);
}

int
w_flashbang_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (pl.ammo_fbgrenade < AMMO_MAX_FLASHBANG) {
		pl.ammo_fbgrenade = bound(0, pl.ammo_fbgrenade + 1, AMMO_MAX_FLASHBANG);
	} else {
		return FALSE;
	}
#endif
	return TRUE;
}

string
w_flashbang_wmodel(void)
{
	return "models/w_flashbang.mdl";
}

string
w_flashbang_pmodel(void)
{
	return "models/p_flashbang.mdl";
}

string
w_flashbang_deathmsg(void)
{
	return "";
}

void
w_flashbang_draw(void)
{
	player pl = (player)self;
	Weapons_SetModel("models/v_flashbang.mdl");
	Weapons_ViewAnimation(FLASHBANG_DRAW);
	pl.mode_temp = 0;
}

#ifdef SERVER
void w_flashbang_throw(void)
{
	static void flashbang_explode(void)
	{
		FX_Flashbang(self.origin);
		Sound_Play(self, CHAN_BODY, "weapon_flashbang.explode");
		remove(self);
	}
	
	static void flashbang_touch(void)
	{
		if (other.takedamage == DAMAGE_YES) {
			Damage_Apply(other, self.owner, 15, WEAPON_FLASHBANG, DMG_BLUNT);
		} else {
			Sound_Play(self, CHAN_BODY, "weapon_flashbang.bounce");
		}
		self.frame = 0;
	}

	player pl = (player)self;
	vector vPLAngle = pl.v_angle;
	if (vPLAngle[0] < 0) {
		vPLAngle[0] = -10 + vPLAngle[0] * ((90 - 10) / 90.0);
	} else {
		vPLAngle[0] = -10 + vPLAngle[0] * ((90 + 10) / 90.0);
	}

	float flVel = (90 - vPLAngle[0]) * 5;
	if (flVel > 1000) {
		flVel = 1000;
	}

	makevectors(vPLAngle);
	vector vecSrc = pl.origin + pl.view_ofs + v_forward * 16;
	vector vecThrow = v_forward * flVel + pl.velocity;

	entity eGrenade = spawn();
	eGrenade.owner = pl;
	eGrenade.classname = "remove_me";
	eGrenade.solid = SOLID_BBOX;
	eGrenade.frame = 1;
	eGrenade.velocity = vecThrow;
	eGrenade.movetype = MOVETYPE_BOUNCE;
	eGrenade.think = flashbang_explode;
	eGrenade.touch = flashbang_touch;
	eGrenade.nextthink = time + 4.0f;
	setmodel(eGrenade, "models/w_flashbang.mdl");
	setsize(eGrenade, [0,0,0], [0,0,0]);
	setorigin(eGrenade, vecSrc);
}
#endif

void
w_flashbang_primary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next > 0.0) {
		return;
	}
	
	/* We're abusing this network variable for the holding check */
	if (pl.mode_temp > 0) {
		return;
	}

	/* Ammo check */
	if (pl.ammo_fbgrenade <= 0) {
		return;
	}

	Weapons_ViewAnimation(FLASHBANG_PULLPIN);

	pl.mode_temp = 1;
	pl.w_attack_next = 0.975f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_flashbang_release(void)
{
	player pl = (player)self;
	
	if (pl.w_idle_next > 0.0) {
		return;
	}

	if (pl.mode_temp == 1) {
		pl.ammo_fbgrenade--;
#ifdef CLIENT
		Weapons_ViewAnimation(FLASHBANG_THROW);
#else
		w_flashbang_throw();
#endif
		pl.mode_temp = 2;
		pl.w_attack_next = 1.0f;
		pl.w_idle_next = 0.5f;
	} else if (pl.mode_temp == 2) {
#ifdef CLIENT
		Weapons_ViewAnimation(FLASHBANG_DRAW);
#else
		if (!pl.ammo_fbgrenade) {
			Weapons_RemoveItem(pl, WEAPON_FLASHBANG);
		}
#endif
		pl.w_attack_next = 0.5f;
		pl.w_idle_next = 0.5f;
		pl.mode_temp = 0;
	}
}

float
w_flashbang_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CROUCH_AIM_GRENADE : ANIM_AIM_GRENADE;
}

void
w_flashbang_hud(void)
{
#ifdef CLIENT

	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [48/256,96/256], [24/256, 24/256], g_hud_color, pSeat->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_flashbang_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	player pl = (player)self;

	HUD_DrawAmmoBar(pos, pl.ammo_fbgrenade, AMMO_MAX_FLASHBANG, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud6_spr,
			[0,90/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			g_hud3_spr,
			[0,90/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_flashbang =
{
	.name		= "flashbang",
	.id		= ITEM_FLASHBANG,
	.slot		= 3,
	.slot_pos	= 1,
	.allow_drop	= FALSE,
	.draw		= w_flashbang_draw,
	.holster	= __NULL__,
	.primary	= w_flashbang_primary,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= w_flashbang_release,
	.crosshair	= w_flashbang_hud,
	.precache	= w_flashbang_precache,
	.pickup		= w_flashbang_pickup,
	.updateammo	= w_flashbang_updateammo,
	.wmodel		= w_flashbang_wmodel,
	.pmodel		= w_flashbang_pmodel,
	.deathmsg	= w_flashbang_deathmsg,
	.aimanim	= w_flashbang_aimanim,
	.hudpic		= w_flashbang_hudpic
};

#ifdef SERVER
void
weapon_flashbang(void)
{
	Weapons_InitItem(WEAPON_FLASHBANG);
}
#endif
