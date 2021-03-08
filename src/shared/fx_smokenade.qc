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

#ifdef CLIENT
var int PARTICLE_SMOKEGRENADE;

void
FX_Smokenade_Init(void)
{
	PARTICLE_SMOKEGRENADE = particleeffectnum("fx_smokenade.effect");
}
#endif

void
FX_Smokenade(vector vecPos)
{
#ifdef SERVER
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_SMOKE);
	WriteCoord(MSG_MULTICAST, vecPos[0]);
	WriteCoord(MSG_MULTICAST, vecPos[1]);
	WriteCoord(MSG_MULTICAST, vecPos[2]);
	msg_entity = self;
	multicast([0,0,0], MULTICAST_ALL);
#else
	static void Effect_CreateSmoke_Think(void) {
		// HACK: This should only ever happen when rounds restart!
		// Any way this can go wrong?
		if (self.skin < getstatf(STAT_GAMETIME)) {
			remove(self);
		}
		if (self.frame <= 0) {
			remove(self);
			return;
		}

		pointparticles(PARTICLE_SMOKEGRENADE, self.origin, [0,0,0], 1);
		self.frame--;
		self.nextthink = time + 0.2f;
		self.skin = getstatf(STAT_GAMETIME);
	}
	
	entity eSmoke = spawn();
	setorigin(eSmoke, vecPos);
	eSmoke.think = Effect_CreateSmoke_Think;
	eSmoke.nextthink = time;
	eSmoke.frame = 200;
	eSmoke.skin = getstatf(STAT_GAMETIME);
#endif
} 
