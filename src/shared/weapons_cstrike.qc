/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

/* 
 * How Counter-Strike's accuracy works (from my understanding)
 * this was deducted from the decrypted CS:S script files:
 * https://gamebanana.com/gamefiles/2293
 * 
 * Each and every bullet fired contributes to the shotmultiplier value,
 * which decreases back to 0 slowly over time.
 * 
 * Meanwhile, accuracy gets calculated by taking said value and dividing it
 * by the weapon-specific divider. Each gun has a different one.
 * The higher the divider value, the more accurate the weapon is in contrast
 * to other weapons.
*/

var float autocvar_guns_recoil_strength = 1.0f;
var bool autocvar_guns_random_recoil_direction = TRUE;
var float autocvar_guns_movement_inaccuracy = 1.0f;
var float autocvar_guns_firing_inaccuracy = 1.0f;

weapontype_t
csweapon_ranged_type(player pl)
{
	return WPNTYPE_RANGED;
}

weapontype_t
csweapon_melee_type(player pl)
{
	return WPNTYPE_CLOSE;
}

float
Cstrike_CalculateMovementInaccuracy(player pl) {
	float m = 1.0f;
	float maxspeed = 250;
	float speedlimit_low = maxspeed/3;
	float speedlimit_high = maxspeed/2;
	float current_speed = vlen(pl.velocity);
	if (current_speed > speedlimit_low) {
		if (current_speed > speedlimit_high) {
			m = 2.25f;
		} else {
			m = 1.0f + (current_speed - speedlimit_low)/(speedlimit_high - speedlimit_low);
		}
	}
	if (!(pl.flags & FL_ONGROUND)) {
		m = 2.5f;
	}else if (pl.flags & FL_CROUCHING) {
		m *= 0.6f;
	}
	return bound(0.75f,m,2.5f);
}

/* called whenever a cstrike gun fires a successful shot */
void
Cstrike_ShotMultiplierAdd(player pl, float shots, float strength, float inaccuracy)
{
	int r;
	inaccuracy = bound(.95,inaccuracy*50+0.1,1.6);
	if (pl.cs_shotmultiplier < 1.6) {
		pl.cs_rec_reverse_chance = 0.95f;
		pl.cs_prev_hor_rec = 0;
		pl.cs_hor_rec_sign = 1;
		if (autocvar_guns_random_recoil_direction && pseudorandom() >= 0.5) {
			pl.cs_hor_rec_sign = -1;
		}
	}
	pl.cs_rec_reverse_chance -= 0.02f;
	if (pl.cs_rec_reverse_chance < 0.1f) {
		pl.cs_rec_reverse_chance = 0.1f;
	}
	if (autocvar_guns_random_recoil_direction == 1) {
		if (pseudorandom() > pl.cs_rec_reverse_chance) {
			pl.cs_hor_rec_sign = -pl.cs_hor_rec_sign;
			pl.cs_rec_reverse_chance = 0.92f;
		}
	} else {
		if ( pl.cs_shotmultiplier > 9) {
			pl.cs_hor_rec_sign = -1;
		}
	}
	float new_shotmultiplier
		= pl.cs_shotmultiplier
		+ 1.3
		+ shots
		+ pl.cs_shotmultiplier/12*(.85+inaccuracy/11)
		- pl.cs_shotmultiplier*pl.cs_shotmultiplier/100*(.95+inaccuracy/10);
	pl.cs_shotmultiplier = bound(0, new_shotmultiplier, 30);
	float bound_shotmultiplier = bound(0, pl.cs_shotmultiplier, 12);
	pl.cs_shottime = 0.2f;

	float movement_inaccuracy = bound(0.92,Cstrike_CalculateMovementInaccuracy(pl),1.25);
	pl.punchangle[0] = -(pl.cs_shotmultiplier)*0.35*(strength*0.9+inaccuracy/9)+0.5;
	pl.punchangle[0] -= autocvar_guns_firing_inaccuracy * (1 + 3*inaccuracy * inaccuracy)/19;
	pl.punchangle[0] *= autocvar_guns_recoil_strength;
	if (pl.cs_shotmultiplier < 5) {
		//here we add extra punchangle for low multiplier values,
		//so that tapping has more weight to it.
		float extrapunch = bound(0.6f,shots*strength,0.8f);
		pl.punchangle[0] -= extrapunch;
	}
	float hor_recoil
		= pl.cs_shotmultiplier/185*(1 + (pseudorandom() - 0.5)/3)
		+ (pseudorandom() - 0.3)*inaccuracy*inaccuracy*0.5*autocvar_guns_firing_inaccuracy;

	hor_recoil *= 1.2 * movement_inaccuracy * strength * autocvar_guns_recoil_strength;
		
	if (pl.cs_hor_rec_sign > 0) {
		pl.cs_prev_hor_rec += hor_recoil;
	} else if (pl.cs_hor_rec_sign < 0) {
		pl.cs_prev_hor_rec -= hor_recoil;
	}
	pl.punchangle[1] = pl.cs_prev_hor_rec;
	r = (float)input_sequence % 5;
	/*switch (r) {
	case 1:
		pl.punchangle[1] = -0.1;
		break;
	case 2:
		pl.punchangle[1] = 0.25;
		break;
	case 3:
		pl.punchangle[1] = -0.25;
		break;
	case 4:
		pl.punchangle[1] = 0.5;
		break;
	case 5:
		pl.punchangle[1] = 0.1;
		break;
	default:
		pl.punchangle[1] = -0.5;
		break;
	}*/
}



/* generate an accuracy value that we'll pass onto TraceAttack */
float
Cstrike_CalculateAccuracy(player pl, float divisor, float movement_penalty=1)
{
	float inacc = 0;
	float m = Cstrike_CalculateMovementInaccuracy(pl);
	if (m > 1) {
		m *= movement_penalty;
	}
	if (divisor == -1) {
		/* snipers shoot way less accurate overall. */
		return (pl.viewzoom < 1.0f) ? (0.0f) : (0.05 * m);
	} else {
		inacc = pl.cs_shotmultiplier*(1.25 + pl.cs_shotmultiplier*pl.cs_shotmultiplier*0.3) * autocvar_guns_firing_inaccuracy;
		inacc = inacc / divisor / 3100;
		inacc = inacc * m;
		if (m > 1) {
			inacc += m * 0.0025*movement_penalty * autocvar_guns_movement_inaccuracy;
		} else {
			inacc += m * 0.0025;
		}
		return inacc;
	}
}


void
Cstrike_BulletRecoil_ApplyPre(player pl, float strength) {
	strength *= autocvar_guns_recoil_strength;
	pl.v_angle += strength*pl.punchangle*(2 - pl.cs_shotmultiplier/100*0.2);
}
void
Cstrike_BulletRecoil_ApplyPost(player pl, float strength) {
	strength *= autocvar_guns_recoil_strength;
	pl.v_angle -= strength*pl.punchangle*(2 - pl.cs_shotmultiplier/100*0.2);
}


/* called whenever cstrike guns aren't firing */
void
Cstrike_ShotMultiplierUpdate(player pl)
{
	if ((pl.cs_shotmultiplier > 0) && (pl.cs_shottime <= 0.0f)) {
		pl.cs_shottime = pl.w_attack_next + 0.01;
		pl.cs_shotmultiplier--;
	}

	pl.cs_shottime = max(0, pl.cs_shottime - input_timelength);
}

void
Cstrike_ShotReset(player pl)
{
	pl.cs_shottime = 0.0f;
	pl.cs_shotmultiplier = 0;
}

void
w_cstrike_weaponrelease(void)
{
	player pl = (player)self;
	pl.punchangle[1] *= 0.95;
	Cstrike_ShotMultiplierUpdate(pl);
}

void
w_cstrke_switched(player pl)
{
	Cstrike_ShotReset(pl);
}
