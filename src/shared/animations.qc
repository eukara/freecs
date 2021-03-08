/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

void Animation_Print(string sWow) {
#ifdef CLIENT
	print(sprintf("[DEBUG] %s", sWow));
#else 
	bprint(PRINT_HIGH, sprintf("SSQC: %s", sWow) );
#endif	
}

/*
=================
Animation_PlayerUpdate

Called every frame to update the animation sequences
depending on what the player is doing
=================
*/
void Animation_PlayerUpdate(void) {
	self.basebone = cvar("spinebone"); // gettagindex(self, "Bip01 Spine");

	if (self.baseframe_time < time) {
		base_player pl = (base_player)self;
		self.baseframe = Weapons_GetAim(pl.activeweapon);
		self.baseframe_old = self.frame;
	}

	/* in order to appear jumping, we want to not be on ground, 
	 * but also make sure we're not just going down a ramp */
	if (!(self.flags & FL_ONGROUND) && (self.velocity[2] > 0 || self.frame == ANIM_JUMP)) {
		self.frame = ANIM_JUMP;
	} else if (vlen(self.velocity) == 0) {
		if (self.flags & FL_CROUCHING) {
			self.frame = ANIM_IDLE_CROUCH;
		} else {
			self.frame = ANIM_IDLE;
		}
	} else if (vlen(self.velocity) < 150) {
		if (self.flags & FL_CROUCHING) {
			self.frame = ANIM_RUN_CROUCH;
		} else {
			self.frame = ANIM_WALK;
		}
	} else if (vlen(self.velocity) > 150) {
		if (self.flags & FL_CROUCHING) {
			self.frame = ANIM_RUN_CROUCH;
		} else {
			self.frame = ANIM_RUN;
		}
	}

	// Lerp it down!
	if (self.lerpfrac > 0) {
		self.lerpfrac -= frametime * 5;
		if (self.lerpfrac < 0) {
			self.lerpfrac = 0;
		}
	}

	if (self.baselerpfrac > 0) {
		self.baselerpfrac -= frametime * 5;
		if (self.baselerpfrac < 0) {
			self.baselerpfrac = 0;
		}
	}

	if (self.frame != self.frame_last) {
		//Animation_Print(sprintf("New Frame: %d, Last Frame: %d\n", self.frame, self.frame_last));
		
		// Move everything over to frame 2
		self.frame2time = self.frame1time;
		self.frame2 = self.frame_last;
		
		// Set frame_last to avoid this being called again
		self.frame_last = self.frame;
		
		self.lerpfrac = 1.0f;
		self.frame1time = 0.0f;
	}
	
	if (self.baseframe != self.baseframe_last) {
		//Animation_Print(sprintf("New Baseframe: %d, Last Baseframe: %d\n", self.baseframe, self.baseframe_last));
		
		// Move everything over to frame 2
		self.baseframe2time = self.baseframe1time;
		self.baseframe2 = self.baseframe_last;
		
		// Set frame_last to avoid this being called again
		self.baseframe_last = self.baseframe;
		
		self.baselerpfrac = 1.0f;
		self.baseframe1time = 0.0f;
	}

	// Force the code above to update if we switched positions
	if (self.fWasCrouching != (self.flags & FL_CROUCHING)) {
		self.baseframe_old = 0;
		self.baseframe_time = 0;
		self.fWasCrouching = (self.flags & FL_CROUCHING);
	}

#ifdef SERVER
	// On the CSQC it's done in Player.c
	self.subblendfrac = 
	self.subblend2frac = self.v_angle[0] / 90;
#endif

	self.angles[0] = self.angles[2] = 0;
}

/*
=================
Animation_PlayerTop

Changes the animation sequence for the upper body part
=================
*/
void Animation_PlayerTop(float fFrame) {
	self.baseframe = fFrame;
	self.baseframe_old = fFrame;
}

void Animation_PlayerTopTemp(float fFrame, float fTime) {
	self.baseframe = fFrame;
	self.baseframe_time = time + fTime;
#ifdef SERVER
	self.SendFlags |= PLAYER_FRAME;
#endif
}
