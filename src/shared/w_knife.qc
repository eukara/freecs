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

/*QUAKED weapon_knife (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_knife.mdl"

COUNTER-STRIKE (1999) ENTITY

Knife Weapon

Default arsenal on both teams

*/

enum
{
	KNIFE_IDLE1,
	KNIFE_SLASH1,
	KNIFE_SLASH2,
	KNIFE_DRAW,
	KNIFE_STAB,
	KNIFE_STAB_MISS,
	KNIFE_MIDSLASH1,
	KNIFE_MIDSLASH2
};

void
w_knife_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_knife.hit");
	Sound_Precache("weapon_knife.hitbody");
	Sound_Precache("weapon_knife.hithard");
	Sound_Precache("weapon_knife.miss");
	precache_model("models/w_knife.mdl");
#else
	precache_model("models/v_knife.mdl");
	precache_model("models/p_knife.mdl");
#endif
}

void
w_knife_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, -1, -1, -1);
}

string
w_knife_wmodel(void)
{
	return "models/w_knife.mdl";
}

string
w_knife_pmodel(void)
{
	return "models/p_knife.mdl";
}

string
w_knife_deathmsg(void)
{
	return "";
}

void
w_knife_draw(void)
{
#ifdef CLIENT
	Weapons_SetModel("models/v_knife.mdl");
	Weapons_ViewAnimation(KNIFE_DRAW);
#endif
}

void
w_knife_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}
	pl.w_attack_next = 0.7f;

#ifdef CLIENT
	int r = (float)input_sequence % 2;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(KNIFE_SLASH1);
		break;
	default:
		Weapons_ViewAnimation(KNIFE_SLASH2);
		break;
	}
#else
	vector src;
	Weapons_MakeVectors();
	src = pl.origin + pl.view_ofs;
	traceline(src, src + (v_forward * 32), FALSE, pl);

	Sound_Play(pl, CHAN_WEAPON, "weapon_knife.miss");

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_CROUCH_SHOOT_KNIFE, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_SHOOT_KNIFE, 0.45f);

	if (trace_fraction >= 1.0) {
		return;
	}

	if (trace_ent.iBleeds) {
		FX_Blood(trace_endpos, [1,0,0]);
		Sound_Play(pl, CHAN_WEAPON, "weapon_knife.hitbody");
	} else {
		Sound_Play(pl, CHAN_WEAPON, "weapon_knife.hit");
	}

	if (trace_ent.takedamage) {
		Damage_Apply(trace_ent, pl, 15, WEAPON_KNIFE, DMG_SLASH);
	}
#endif
}

void
w_knife_secondary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}
	pl.w_attack_next = 1.2f;

#ifdef CLIENT
	Weapons_ViewAnimation(KNIFE_STAB);
#else
	
	vector src;
	Weapons_MakeVectors();
	src = pl.origin + pl.view_ofs;
	traceline(src, src + (v_forward * 32), FALSE, pl);

	Sound_Play(pl, CHAN_WEAPON, "weapon_knife.miss");

	if (trace_fraction >= 1.0) {
		return;
	}

	/* don't bother with decals, we got squibs */
	if (trace_ent.iBleeds) {
		FX_Blood(trace_endpos, [1,0,0]);
		Sound_Play(pl, CHAN_WEAPON, "weapon_knife.hitbody");
	} else {
		Sound_Play(pl, CHAN_WEAPON, "weapon_knife.hit");
	}

	if (trace_ent.takedamage) {
		Damage_Apply(trace_ent, pl, 65, WEAPON_KNIFE, DMG_SLASH);
	}
#endif
}

float
w_knife_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CROUCH_AIM_KNIFE : ANIM_AIM_KNIFE;
}

void
w_knife_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_hud11_spr,
			[0,135/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			g_hud10_spr,
			[0,135/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_knife =
{
	.name		= "knife",
	.id		= ITEM_KNIFE,
	.slot		= 2,
	.slot_pos	= 0,
	.allow_drop	= FALSE,
	.draw		= w_knife_draw,
	.holster	= __NULL__,
	.primary	= w_knife_primary,
	.secondary	= w_knife_secondary,
	.reload		= __NULL__,
	.release	= __NULL__,
	.crosshair	= __NULL__,
	.precache	= w_knife_precache,
	.pickup		= __NULL__,
	.updateammo	= w_knife_updateammo,
	.wmodel		= w_knife_wmodel,
	.pmodel		= w_knife_pmodel,
	.deathmsg	= w_knife_deathmsg,
	.aimanim	= w_knife_aimanim,
	.hudpic		= w_knife_hudpic
};

#ifdef SERVER
void
weapon_knife(void)
{
	Weapons_InitItem(WEAPON_KNIFE);
}
#endif
