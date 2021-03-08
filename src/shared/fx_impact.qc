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
var int FX_IMPACT_BLACKBITS;
var int FX_IMPACT_SMOKE_BROWN;
var int FX_IMPACT_SMOKE_GREY;
var int FX_IMPACT_SPARK;

void
FX_Impact_Init(void)
{
	precache_sound("weapons/ric_metal-1.wav");
	precache_sound("weapons/ric_metal-2.wav");
	precache_sound("weapons/ric_conc-1.wav");
	precache_sound("weapons/ric_conc-2.wav");
	precache_sound("weapons/knife_hitwall1.wav");
	precache_sound("weapons/ric1.wav");
	precache_sound("weapons/ric2.wav");
	precache_sound("weapons/ric3.wav");
	precache_sound("weapons/ric4.wav");
	precache_sound("weapons/ric5.wav");

	FX_IMPACT_BLACKBITS = particleeffectnum("fx_impact.blackbits");
	FX_IMPACT_SMOKE_GREY = particleeffectnum("fx_impact.smoke_grey");
	FX_IMPACT_SMOKE_BROWN = particleeffectnum("fx_impact.smoke_brown");
	FX_IMPACT_SPARK = particleeffectnum("fx_impact.spark");
}
#endif

void
FX_Impact(int iType, vector vecPos, vector vNormal)
{
#ifdef SERVER
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_IMPACT);
	WriteByte(MSG_MULTICAST, (float)iType);
	WriteCoord(MSG_MULTICAST, vecPos[0]); 
	WriteCoord(MSG_MULTICAST, vecPos[1]); 
	WriteCoord(MSG_MULTICAST, vecPos[2]);
	WriteCoord(MSG_MULTICAST, vNormal[0]); 
	WriteCoord(MSG_MULTICAST, vNormal[1]); 
	WriteCoord(MSG_MULTICAST, vNormal[2]);
	msg_entity = self;
	multicast(vecPos, MULTICAST_PVS);
#else
	/* decals */
	switch (iType) {
	case IMPACT_GLASS:
		Decals_Place(vecPos, sprintf("{break%d", floor(random(1,4))));
		break;
	case IMPACT_MELEE:
		Decals_Place(vecPos, sprintf("{shot%d", floor(random(1,6))));
		break;
	default:
		Decals_Place(vecPos, sprintf("{bigshot%d", floor(random(1,6))));
		break;
	}

	switch (iType) {
		case IMPACT_MELEE:
			pointsound(vecPos, "weapons/knife_hitwall1.wav", 1, ATTN_STATIC);
			break;
		case IMPACT_EXPLOSION:
			break;
		case IMPACT_GLASS:
			pointparticles(FX_IMPACT_BLACKBITS, vecPos, vNormal, 1);
			break;
		case IMPACT_WOOD:
			pointparticles(FX_IMPACT_SPARK, vecPos, vNormal, 1);
			pointparticles(FX_IMPACT_BLACKBITS, vecPos, vNormal, 1);
			pointparticles(FX_IMPACT_SMOKE_BROWN, vecPos, vNormal, 1);
			break;
		case IMPACT_METAL:
			pointparticles(FX_IMPACT_SPARK, vecPos, vNormal, 1);
			pointparticles(FX_IMPACT_BLACKBITS, vecPos, vNormal, 1);
			break;
		case IMPACT_FLESH:
			FX_Blood(vecPos, vNormal);
			break;
		case IMPACT_DEFAULT:
		default:
			pointparticles(FX_IMPACT_SPARK, vecPos, vNormal, 1);
			pointparticles(FX_IMPACT_BLACKBITS, vecPos, vNormal, 1);
			pointparticles(FX_IMPACT_SMOKE_GREY, vecPos, vNormal, 1);
			break;
	}

	switch (iType) {
		case IMPACT_METAL:
			pointsound(vecPos, sprintf("weapons/ric_metal-%d.wav", floor((random() * 2) + 1)), 1, ATTN_STATIC);
			break;
		case IMPACT_CONCRETE:
			pointsound(vecPos, sprintf("weapons/ric_conc-%d.wav", floor((random() * 2) + 1)), 1, ATTN_STATIC);
			break;
		case IMPACT_FLESH:
			break;
		default:
			pointsound(vecPos, sprintf("weapons/ric%d.wav", floor((random() * 5) + 1)), 1, ATTN_STATIC);
			break;
	}
#endif
} 
