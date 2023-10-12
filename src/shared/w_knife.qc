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

/*!QUAKED weapon_knife (0 0 1) (-16 -16 0) (16 16 32)

COUNTER-STRIKE (1999) ENTITY

Knife Weapon

Default arsenal on both teams

-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
model="models/w_knife.mdl"
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
w_knife_pmodel(player pl)
{
	return "models/p_knife.mdl";
}

string
w_knife_deathmsg(void)
{
	return "";
}

void
w_knife_draw(player pl)
{
	Weapons_SetModel("models/v_knife.mdl");
	Weapons_ViewAnimation(pl, KNIFE_DRAW);

#ifdef CLIENT
	CStrikeView_UpdateGeomset(pl);
#endif
}

void
w_knife_primary(player pl)
{

	if (pl.w_attack_next > 0.0) {
		return;
	}
	pl.w_attack_next = 0.7f;

	int r = (float)input_sequence % 2;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(pl, KNIFE_SLASH1);
		break;
	default:
		Weapons_ViewAnimation(pl, KNIFE_SLASH2);
		break;
	}

	if (pl.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_CROUCH_SHOOT_KNIFE, 1.33f);
	else
		Animation_PlayerTop(pl, ANIM_SHOOT_KNIFE, 1.33f);

#ifdef SERVER
	vector src;
	int range = Skill_GetValue("plr_knife_range", 48);

	Weapons_MakeVectors(pl);
	src = pl.origin + pl.view_ofs;
	traceline(src, src + (v_forward * range), MOVE_HITMODEL, pl);

	Sound_Play(pl, CHAN_WEAPON, "weapon_knife.miss");

	if (trace_fraction >= 1.0) {
		return;
	}

	if (trace_ent.iBleeds) {
		FX_Blood(trace_endpos, [1,0,0]);
		Sound_Play(pl, CHAN_WEAPON, "weapon_knife.hitbody");
	} else {
		Sound_Play(pl, CHAN_WEAPON, "weapon_knife.hit");
	}

	/* let's calculate damage! */
	if (trace_ent.takedamage) {
		/* values taken from https://counterstrike.fandom.com/wiki/Knife */
		int dmg = 0;

		switch (trace_surface_id) {
		case BODY_HEAD:
			dmg = Skill_GetValue("plr_knife_dmghead", 60);
			break;
		case BODY_STOMACH:
			dmg = Skill_GetValue("plr_knife_dmgstomach", 18);
			break;
		case BODY_LEGLEFT:
		case BODY_LEGRIGHT:
			dmg = Skill_GetValue("plr_knife_dmglegs", 11);
			break;
		case BODY_CHEST:
			dmg = Skill_GetValue("plr_knife_dmgchest", 15);
			break;
		case BODY_ARMLEFT:
		case BODY_ARMRIGHT:
			dmg = Skill_GetValue("plr_knife_dmgarms", 15);
			break;
		case BODY_DEFAULT:
		default:
			dmg = Skill_GetValue("plr_knife_dmg", 15);
			break;
		}
		Damage_Apply(trace_ent, pl, dmg, WEAPON_KNIFE, DMG_SLASH);
	}
#endif
}

void
w_knife_secondary(player pl)
{

	if (pl.w_attack_next > 0.0) {
		return;
	}
	pl.w_attack_next = 1.2f;


	Weapons_ViewAnimation(pl, KNIFE_STAB);

	if (pl.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_CROUCH_SHOOT_KNIFE, 1.33f);
	else
		Animation_PlayerTop(pl, ANIM_SHOOT_KNIFE, 1.33f);

#ifdef SERVER
	vector src;
	int range = Skill_GetValue("plr_knife_altrange", 48);

	Weapons_MakeVectors(pl);
	src = pl.origin + pl.view_ofs;
	traceline(src, src + (v_forward * range), MOVE_HITMODEL, pl);

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

	/* let's calculate damage! */
	if (trace_ent.takedamage) {
		/* values taken from https://counterstrike.fandom.com/wiki/Knife */
		int dmg = 0;
		switch (trace_surface_id) {
		case BODY_HEAD:
			dmg = Skill_GetValue("plr_knife_altdmghead", 260);
			break;
		case BODY_STOMACH:
			dmg = Skill_GetValue("plr_knife_altdmgstomach", 81);
			break;
		case BODY_LEGLEFT:
		case BODY_LEGRIGHT:
			dmg = Skill_GetValue("plr_knife_altdmglegs", 48);
			break;
		case BODY_CHEST:
			dmg = Skill_GetValue("plr_knife_altdmgchest", 65);
			break;
		case BODY_ARMLEFT:
		case BODY_ARMRIGHT:
			dmg = Skill_GetValue("plr_knife_altdmgarms", 65);
			break;
		case BODY_DEFAULT:
		default:
			dmg = Skill_GetValue("plr_knife_altdmg", 65);
			break;
		}

		/* secondary can do a backstab */
		if (trace_ent.classname == "player") {
			player otherpl = (player)trace_ent;
			if (otherpl.IsFacing(pl) == false) {
				dmg *= 3;
			}
		}

		Damage_Apply(trace_ent, pl, dmg, WEAPON_KNIFE, DMG_SLASH);
	}
#endif
}

float
w_knife_aimanim(player pl)
{
	return pl.flags & FL_CROUCHING ? ANIM_CROUCH_AIM_KNIFE : ANIM_AIM_KNIFE;
}

int
w_knife_isempty(player pl)
{
	return 0;
}

void
w_knife_hudpic(player pl, int selected, vector pos, float a)
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
			a,
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
			a,
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
	.postdraw	= __NULL__,
	.precache	= w_knife_precache,
	.pickup		= __NULL__,
	.updateammo	= w_knife_updateammo,
	.wmodel		= w_knife_wmodel,
	.pmodel		= w_knife_pmodel,
	.deathmsg	= w_knife_deathmsg,
	.aimanim	= w_knife_aimanim,
	.hudpic		= w_knife_hudpic,
	.type		= csweapon_melee_type,
	.isempty	= w_knife_isempty
};

#ifdef SERVER
void
weapon_knife(void)
{
	Weapons_InitItem(WEAPON_KNIFE);
}
#endif
