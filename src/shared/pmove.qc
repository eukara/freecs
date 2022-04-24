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

.float waterlevel;
.float watertype;

/* values courtesy of https://wiki.alliedmods.net/Cs_weapons_information */
float
player::Physics_MaxSpeed(void)
{
	float spd = serverkeyfloat("phy_maxspeed");

	switch (activeweapon)
	{
	case WEAPON_M3:
		spd *= 230/250;
		break;
	case WEAPON_XM1014:
		spd *= 240/250;
		break;
	case WEAPON_MP5:
		spd *= 250/250;
		break;
	case WEAPON_P90:
		spd *= 245/250;
		break;
	case WEAPON_UMP45:
		spd *= 250/250;
		break;
	case WEAPON_MAC10:
		spd *= 250/250;
		break;
	case WEAPON_TMP:
		spd *= 250/250;
		break;
	case WEAPON_AK47:
		spd *= 221/250;
		break;
	case WEAPON_SG552:
		spd *= 235/250;
		break;
	case WEAPON_M4A1:
		spd *= 230/250;
		break;
	case WEAPON_AUG:
		spd *= 240/250;
		break;
	case WEAPON_SCOUT:
		spd *= 260/250;
		break;
	case WEAPON_AWP:
		spd *= 210/250;
		break;
	case WEAPON_G3SG1:
		spd *= 210/250;
		break;
	case WEAPON_SG550:
		spd *= 210/250;
		break;
	case WEAPON_PARA:
		spd *= 220/250;
		break;
	case WEAPON_USP45:
		spd *= 250/250;
		break;
	case WEAPON_GLOCK18:
		spd *= 250/250;
		break;
	case WEAPON_DEAGLE:
		spd *= 250/250;
		break;
	case WEAPON_P228:
		spd *= 250/250;
		break;
	case WEAPON_ELITES:
		spd *= 250/250;
		break;
	case WEAPON_FIVESEVEN:
		spd *= 250/250;
		break;
	case WEAPON_KNIFE:
		spd *= 250/250;
		break;
	case WEAPON_HEGRENADE:
		spd *= 250/250;
		break;
	case WEAPON_FLASHBANG:
		spd *= 250/250;
		break;
	case WEAPON_SMOKEGRENADE:
		spd *= 250/250;
		break;
	case WEAPON_C4BOMB:
		spd *= 250/250;
		break;
	default:
	}

	if (flags & FL_CROUCHING) {
		spd *= 0.5f;
	}

	return spd;
}

void
player::Physics_Fall(float impactspeed)
{
	impactspeed *= 1.25f;
	if (impactspeed > 580) {
#ifdef SERVER
		float fFallDamage = (impactspeed - 580) * (100 / (1024 - 580)) * 0.75f;
		Damage_Apply(this, world, fFallDamage, 0, DMG_FALL | DMG_SKIP_ARMOR);

		if (random() < 0.5)
			sound(this, CHAN_AUTO, "player/pl_pain2.wav", 1.0, ATTN_NORM);
		else
			sound(this, CHAN_AUTO, "player/pl_pain4.wav", 1.0, ATTN_NORM);
#endif
	}
}

void
player::Physics_Jump(void)
{
	if (waterlevel >= 2) {
		if (watertype == CONTENT_WATER) {
			velocity[2] = 100;
		} else if (watertype == CONTENT_SLIME) {
			velocity[2] = 80;
		} else {
			velocity[2] = 50;
		}
	} else {
		/* slow the player down a bit to prevent bhopping like crazy */
		velocity *= 0.80f;
		velocity[2] += 260;
	}
}
