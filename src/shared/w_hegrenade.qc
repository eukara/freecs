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

/*QUAKED weapon_hegrenade (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_hegrenade.mdl"

COUNTER-STRIKE (1999) ENTITY

HE (High Explosive) Grenade Weapon

When thrown, explodes with a fairly deadly blast radius to players.

- Buy Menu -
Price: $300

*/

enum
{
	HEGRENADE_IDLE,
	HEGRENADE_PULLPIN,
	HEGRENADE_THROW,
	HEGRENADE_DRAW,
};

void
w_hegrenade_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_hegrenade.bounce");
	Sound_Precache("weapon_hegrenade.explode");
	precache_model("models/w_hegrenade.mdl");
#else
	precache_model("models/v_hegrenade.mdl");
	precache_model("models/p_hegrenade.mdl");
#endif
}

void
w_hegrenade_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, -1, pl.ammo_hegrenade, pl.mode_temp);
}

int
w_hegrenade_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (pl.ammo_hegrenade < AMMO_MAX_HENADE) {
		pl.ammo_hegrenade = bound(0, pl.ammo_hegrenade + 1, AMMO_MAX_HENADE);
	} else {
		return FALSE;
	}
#endif
	return TRUE;
}

string
w_hegrenade_wmodel(void)
{
	return "models/w_hegrenade.mdl";
}

string
w_hegrenade_pmodel(void)
{
	return "models/p_hegrenade.mdl";
}

string
w_hegrenade_deathmsg(void)
{
	return "";
}

void
w_hegrenade_draw(void)
{
	Weapons_SetModel("models/v_hegrenade.mdl");
	Weapons_ViewAnimation(HEGRENADE_DRAW);
	player pl = (player)self;
	pl.mode_temp = 0;
}

#ifdef SERVER
void w_hegrenade_throw(void)
{
	static void hegrenade_explode(void)
	{
		float dmg = 100;
		FX_Explosion(self.origin);
		Damage_Radius(self.origin, self.owner, dmg, dmg * 2.5f, TRUE, WEAPON_HEGRENADE);
		Sound_Play(self, CHAN_BODY, "weapon_hegrenade.explode");
		remove(self);
	}
	
	static void hegrenade_touch(void)
	{
		if (other.takedamage == DAMAGE_YES) {
			Damage_Apply(other, self.owner, 15, WEAPON_HEGRENADE, DMG_BLUNT);
		} else {
			Sound_Play(self, CHAN_BODY, "weapon_hegrenade.bounce");
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
	eGrenade.think = hegrenade_explode;
	eGrenade.touch = hegrenade_touch;
	eGrenade.nextthink = time + 4.0f;
	setmodel(eGrenade, "models/w_hegrenade.mdl");
	setsize(eGrenade, [0,0,0], [0,0,0]);
	setorigin(eGrenade, vecSrc);
}
#endif

void
w_hegrenade_primary(void)
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
#ifdef CLIENT
	if (pl.ammo_hegrenade <= 0) {
		return;
	}
#else
	if (pl.ammo_hegrenade <= 0) {
		return;
	}
#endif

	Weapons_ViewAnimation(HEGRENADE_PULLPIN);

	pl.mode_temp = 1;
	pl.w_attack_next = 0.975f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_hegrenade_release(void)
{
	player pl = (player)self;
	
	if (pl.w_idle_next > 0.0) {
		return;
	}

	if (pl.mode_temp == 1) {
#ifdef CLIENT
		pl.ammo_hegrenade--;
		Weapons_ViewAnimation(HEGRENADE_THROW);
#else
		pl.ammo_hegrenade--;
		w_hegrenade_throw();
#endif
		pl.mode_temp = 2;
		pl.w_attack_next = 1.0f;
		pl.w_idle_next = 0.5f;
	} else if (pl.mode_temp == 2) {
#ifdef CLIENT
		Weapons_ViewAnimation(HEGRENADE_DRAW);
#else
		if (!pl.ammo_hegrenade) {
			Weapons_RemoveItem(pl, WEAPON_HEGRENADE);
		}
#endif
		pl.w_attack_next = 0.5f;
		pl.w_idle_next = 0.5f;
		pl.mode_temp = 0;
	}
}

float
w_hegrenade_aimanim(void)
{
	return w_flashbang_aimanim();
}

void
w_hegrenade_hud(void)
{
#ifdef CLIENT

	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [72/256,96/256], [24/256, 24/256], g_hud_color, pSeat->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_hegrenade_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	player pl = (player)self;

	HUD_DrawAmmoBar(pos, pl.ammo_hegrenade, AMMO_MAX_HENADE, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud6_spr,
			[0,45/256],
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
			[0,45/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_hegrenade =
{
	.name		= "hegrenade",
	.id		= ITEM_HEGRENADE,
	.slot		= 3,
	.slot_pos	= 0,
	.allow_drop	= FALSE,
	.draw		= w_hegrenade_draw,
	.holster	= __NULL__,
	.primary	= w_hegrenade_primary,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= w_hegrenade_release,
	.crosshair	= w_hegrenade_hud,
	.precache	= w_hegrenade_precache,
	.pickup		= w_hegrenade_pickup,
	.updateammo	= w_hegrenade_updateammo,
	.wmodel		= w_hegrenade_wmodel,
	.pmodel		= w_hegrenade_pmodel,
	.deathmsg	= w_hegrenade_deathmsg,
	.aimanim	= w_hegrenade_aimanim,
	.hudpic		= w_hegrenade_hudpic
};

#ifdef SERVER
void
weapon_hegrenade(void)
{
	Weapons_InitItem(WEAPON_HEGRENADE);
}
#endif
