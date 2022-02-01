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

.float baseframe1time;
.float baseframe2time;
.float baseframe2;
.float baseframe_last;
.float baseframe_old;
.float baseframe_time;
.float baselerpfrac;
.float frame2;
.float frame2time;
.float frame_last;
.float fWasCrouching;
.float lerpfrac;
.float subblend2frac;
.float subblendfrac;
.float basesubblend2frac;
.float basesubblendfrac;

void Animation_Print(string sWow) {
#ifdef CLIENT
	print(sprintf("[DEBUG] %s", sWow));
#else 
	bprint(PRINT_HIGH, sprintf("SSQC: %s", sWow) );
#endif	
}

void
Animation_TimerUpdate(player pl, float ftime)
{
	makevectors([0, pl.angles[1], 0]);

	/* top animation is always just being incremented */
	pl.anim_top_time += ftime;
	pl.anim_top_delay -= ftime;

	/* we may be walking backwards, thus decrement bottom */
	if (dotproduct(pl.velocity, v_forward) < 0) {
		pl.anim_bottom_time -= ftime;
	} else {
		pl.anim_bottom_time += ftime;
	}
}

/*
=================
Animation_PlayerUpdate

Called every frame to update the animation sequences
depending on what the player is doing
=================
*/
void
Animation_PlayerUpdate(player pl)
{
	pl.basebone = 39;

	if (pl.anim_top_delay <= 0.0f) {
		pl.anim_top = Weapons_GetAim(pl.activeweapon);
	}

	if (vlen(pl.velocity) == 0) {
		if (pl.flags & FL_CROUCHING) {
			pl.anim_bottom = ANIM_IDLE_CROUCH;
		} else {
			pl.anim_bottom = ANIM_IDLE;
		}
	} else if (vlen(pl.velocity) < 150) {
		if (pl.flags & FL_CROUCHING) {
			pl.anim_bottom = ANIM_RUN_CROUCH;
		} else {
			pl.anim_bottom = ANIM_WALK;
		}
	} else if (vlen(pl.velocity) > 150) {
		if (pl.flags & FL_CROUCHING) {
			pl.anim_bottom = ANIM_RUN_CROUCH;
		} else {
			pl.anim_bottom = ANIM_RUN;
		}
	}

	pl.baseframe = pl.anim_top;
	pl.baseframe1time = pl.anim_top_time;
	pl.frame = pl.anim_bottom;
	pl.frame1time = pl.anim_bottom_time;

	/* hack, we can't play the animations in reverse the normal way */
	if (pl.frame1time < 0.0f) {
		pl.frame1time = 10.0f;
	}

	/* only test against non-vertical velocity, or else we'll spin */
	vector hvel = pl.velocity;
	hvel[2] = 0;

	/* get the movement direction */
	makevectors([0, pl.v_angle[1], 0]);
	float fCorrect = dotproduct(hvel, v_right) * 0.25f;

	/* twist torso according to movement direction */
	pl.subblendfrac = -fCorrect * 0.05f;

	/* correct angles so we're facing forward */
	pl.angles[1] = pl.v_angle[1] - fCorrect;

	/* pitch torso up/down */
	pl.subblend2frac = pl.v_angle[0] / 90;


	//pl.basesubblendfrac = 
	pl.angles[0] = pl.angles[2] = 0;

	//pl.subblend2frac = sin(cltime);
}

void
Animation_PlayerTop(player pl, float topanim, float timer)
{
	pl.anim_top = topanim;
	pl.anim_top_time = 0.0f;
	pl.anim_top_delay = timer;
}

void
Animation_PlayerBottom(player pl, float botanim, float timer)
{
	pl.anim_bottom = botanim;
}
