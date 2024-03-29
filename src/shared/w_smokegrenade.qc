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

/*!QUAKED weapon_smokegrenade (0 0 1) (-16 -16 0) (16 16 32)

COUNTER-STRIKE (1999) ENTITY

Smoke Grenade Weapon

When thrown, the explosion casts view-blocking smoke in that radius.

- Buy Menu -
Price: $300

-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
model="models/w_smokegrenade.mdl"
*/

enum
{
	SMOKEGRENADE_IDLE,
	SMOKEGRENADE_PULLPIN,
	SMOKEGRENADE_THROW,
	SMOKEGRENADE_DRAW,
};

void
w_smokegrenade_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_smokegrenade.bounce");
	Sound_Precache("weapon_smokegrenade.explode");
	precache_model("models/w_smokegrenade.mdl");
#else
	precache_model("models/v_smokegrenade.mdl");
	precache_model("models/p_smokegrenade.mdl");
#endif
}

void
w_smokegrenade_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, -1, pl.ammo_smokegrenade, pl.mode_temp);
}

int
w_smokegrenade_pickup(player pl, int new, int startammo)
{
#ifdef SERVER

	if (pl.ammo_smokegrenade < AMMO_MAX_SMOKE) {
		pl.ammo_smokegrenade = bound(0, pl.ammo_smokegrenade + 1, AMMO_MAX_SMOKE);
	} else {
		return (0);
	}
#endif
	return (1);
}

string
w_smokegrenade_wmodel(void)
{
	return "models/w_smokegrenade.mdl";
}

string
w_smokegrenade_pmodel(player pl)
{
	return "models/p_smokegrenade.mdl";
}

string
w_smokegrenade_deathmsg(void)
{
	return "";
}

void
w_smokegrenade_draw(player pl)
{
	Weapons_SetModel("models/v_smokegrenade.mdl");
	Weapons_ViewAnimation(pl, SMOKEGRENADE_DRAW);
	pl.mode_temp = 0;

#ifdef CLIENT
	CStrikeView_UpdateGeomset(pl);
#endif
}

#ifdef SERVER
void
w_smokegrenade_throw(player pl)
{
	static void smokegrenade_explode(void)
	{
		FX_Smokenade(self.origin);
		Sound_Play(self, CHAN_BODY, "weapon_smokegrenade.explode");
		remove(self);
	}
	
	static void smokegrenade_touch(void)
	{
		if (other.takedamage == DAMAGE_YES) {
			Damage_Apply(other, self.owner, 15, WEAPON_SMOKEGRENADE, DMG_BLUNT);
		} else {
			Sound_Play(self, CHAN_BODY, "weapon_smokegrenade.bounce");
		}
		self.frame = 0;
	}

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
	eGrenade.think = smokegrenade_explode;
	eGrenade.touch = smokegrenade_touch;
	eGrenade.nextthink = time + 4.0f;
	setmodel(eGrenade, "models/w_smokegrenade.mdl");
	setsize(eGrenade, [0,0,0], [0,0,0]);
	setorigin(eGrenade, vecSrc);
}
#endif

void
w_smokegrenade_primary(player pl)
{
	if (pl.w_attack_next > 0.0) {
		return;
	}
	
	/* We're abusing this network variable for the holding check */
	if (pl.mode_temp > 0) {
		return;
	}

	/* Ammo check */
	if (pl.ammo_smokegrenade <= 0) {
#ifdef SERVER
		Weapons_RemoveItem(pl, WEAPON_SMOKEGRENADE);
#endif
		return;
	}

	Weapons_ViewAnimation(pl, SMOKEGRENADE_PULLPIN);
	pl.mode_temp = 1;
	pl.w_attack_next = 0.975f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_smokegrenade_release(player pl)
{

	w_cstrike_weaponrelease();
	
	if (pl.w_idle_next > 0.0) {
		return;
	}

	if (pl.mode_temp == 1) {
		pl.ammo_smokegrenade--;
#ifdef CLIENT
		Weapons_ViewAnimation(pl, SMOKEGRENADE_THROW);
#else
		w_smokegrenade_throw(pl);
#endif
		pl.mode_temp = 2;
		pl.w_attack_next = 1.0f;
		pl.w_idle_next = 0.5f;
	} else if (pl.mode_temp == 2) {
#ifdef CLIENT
		Weapons_ViewAnimation(pl, SMOKEGRENADE_DRAW);
#else
		if (!pl.ammo_smokegrenade) {
			Weapons_RemoveItem(pl, WEAPON_SMOKEGRENADE);
		}
#endif
		pl.w_attack_next = 0.5f;
		pl.w_idle_next = 0.5f;
		pl.mode_temp = 0;
	}
}

float
w_smokegrenade_aimanim(player pl)
{
	return w_flashbang_aimanim(pl);
}

void
w_smokegrenade_hud(player pl)
{
#ifdef CLIENT
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [144/256,96/256], [24/256, 24/256], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

int
w_smokegrenade_isempty(player pl)
{

	if (pl.ammo_smokegrenade <= 0)
		return 1;

	return 0;
}

void
w_smokegrenade_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT

	HUD_DrawAmmoBar(pos, pl.ammo_smokegrenade, AMMO_MAX_SMOKE, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud6_spr,
			[0,135/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			g_hud3_spr,
			[0,135/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_smokegrenade =
{
	.name		= "smokegrenade",
	.id		= ITEM_SMOKEGRENADE,
	.slot		= 3,
	.slot_pos	= 2,
	.allow_drop	= FALSE,
	.draw		= w_smokegrenade_draw,
	.holster	= __NULL__,
	.primary	= w_smokegrenade_primary,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= w_smokegrenade_release,
	.postdraw	= w_smokegrenade_hud,
	.precache	= w_smokegrenade_precache,
	.pickup		= w_smokegrenade_pickup,
	.updateammo	= w_smokegrenade_updateammo,
	.wmodel		= w_smokegrenade_wmodel,
	.pmodel		= w_smokegrenade_pmodel,
	.deathmsg	= w_smokegrenade_deathmsg,
	.aimanim	= w_smokegrenade_aimanim,
	.hudpic		= w_smokegrenade_hudpic,
	.isempty	= w_smokegrenade_isempty
};

#ifdef SERVER
void
weapon_smokegrenade(void)
{
	Weapons_InitItem(WEAPON_SMOKEGRENADE);
}
#endif
