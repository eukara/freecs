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

	if (!(pl.flags & FL_ONGROUND)) {
		m = 2.5f;
	} else if (pl.flags & FL_CROUCHING) {
		m = 0.75f;
	} else if (vlen(pl.velocity) > 120) {
		m = 2.25f;
	}

	return m;
}

/* called whenever a cstrike gun fires a successful shot */
void
Cstrike_ShotMultiplierAdd(player pl, int shots, float strength)
{
	int r;

	if (pl.cs_shotmultiplier < 1.6) {
		pl.cs_prev_hor_rec = 0;
		if (pseudorandom() > 0.5) {
			pl.cs_hor_rec_sign = 1;
		} else {
			pl.cs_hor_rec_sign = -1;
		}
	}
	if (pseudorandom() > 0.83) {
		pl.cs_hor_rec_sign = -pl.cs_hor_rec_sign;
	}
	/* more than 12 is enough, you can barely hit the barn */
	float new_shotmultiplier
		= pl.cs_shotmultiplier
		+ 1.5
		+ shots
		+ pl.cs_shotmultiplier/5
		- pl.cs_shotmultiplier*pl.cs_shotmultiplier/90;
	pl.cs_shotmultiplier = bound(0, new_shotmultiplier, 30);
	float bound_shotmultiplier = bound(0, pl.cs_shotmultiplier, 12);
	pl.cs_shottime = 0.2f;

	float movement_inaccuracy = bound(0.92,Cstrike_CalculateMovementInaccuracy(pl),1.25);
	pl.punchangle[0] = -(pl.cs_shotmultiplier)*0.3*movement_inaccuracy*strength+0.5;
	float hor_recoil
		= pl.cs_shotmultiplier*0.005
		+ (pseudorandom() - 0.35)*0.75;
		
	if (pl.cs_hor_rec_sign > 0) {
		pl.cs_prev_hor_rec += hor_recoil*movement_inaccuracy*strength;
	} else if (pl.cs_hor_rec_sign < 0) {
		pl.cs_prev_hor_rec -= hor_recoil*movement_inaccuracy*strength;
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
		inacc = pl.cs_shotmultiplier*pl.cs_shotmultiplier;
		inacc = inacc / divisor / 1000;
		inacc = inacc * m;
		if (m > 1) {
			inacc += m * 0.0025*movement_penalty;
		} else {
			inacc += m * 0.0025;
		}
		return inacc;
	}
}

class CstrikeBulletRecoil {
	private:
		float m_flRandomSpread;
	public:
		void ApplyPre(player pl, float strength) {
			m_flRandomSpread = (pseudorandom() - 0.5) * 2.0;
			pl.v_angle += strength*pl.punchangle*(2 + pl.cs_shotmultiplier/100*(m_flRandomSpread-0.5));
		};
		void ApplyPost(player pl, float strength) {
			pl.v_angle -= strength*pl.punchangle*(2 + pl.cs_shotmultiplier/100*(m_flRandomSpread-0.5));
		};
};
CstrikeBulletRecoil g_CstrikeBulletRecoil;
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
w_cstrike_weaponrelease(void)
{
	player pl = (player)self;
	Cstrike_ShotMultiplierUpdate(pl);
}
