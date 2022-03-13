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

#define CSRADAR_DISTANCE 1024

var string g_cs_radar;

void
Radar_Init(void)
{
	g_cs_radar = spriteframe("sprites/radar640.spr", 0, 0.0f);
}

void
Radar_Draw(void)
{
	vector radpos = g_hudmins + [16,16];

	drawpic(radpos, g_cs_radar, [128,128], [1,1,1], 0.25f, DRAWFLAG_ADDITIVE);

	for (entity a = world; (a = find(a, ::classname, "player"));) {
		vector color;
		vector own_pos = pSeat->m_vecPredictedOrigin;
		vector difference = (a.origin - own_pos);

		/* don't draw when we're exceeding the view radius */
		if (vlen(difference) > CSRADAR_DISTANCE)
			continue;

		/* this is perhaps a bit too aggressive, so fix this and uncomment */
#if 0
		/* test if we can actually see the player */
		traceline(a.origin, own_pos + pSeat->m_ePlayer.view_ofs, MOVE_NORMAL, pSeat->m_ePlayer);
		if (trace_ent != a) {
			traceline(a.origin + [0,0,a.maxs[2]], own_pos + pSeat->m_ePlayer.view_ofs, MOVE_OTHERONLY, pSeat->m_ePlayer);
			if (trace_ent != a) {
				traceline(a.origin + [0,0,a.mins[2]], own_pos + pSeat->m_ePlayer.view_ofs, MOVE_OTHERONLY, pSeat->m_ePlayer);
				if (trace_ent != a) {
					continue;
				}
			}
		}
#endif

		vector matrix;
		float ht;
		makevectors([0,input_angles[1] - 90, 0]);
		matrix[0] = dotproduct(difference, v_forward);
		matrix[1] = dotproduct(difference, v_right);
		matrix[2] = 0;

		/* we need to fit 1024 in-game units into the 64px radar image */
		vector apos = radpos + [62,62] + (matrix * (64/CSRADAR_DISTANCE));

		if (getplayerkeyfloat(a.entnum-1, "*team") == TEAM_CT)
			color = [115, 155, 205] / 255;
		else
			color = [190, 52, 57] / 255;

		drawfill(apos, [4,4], color, 1.0f, DRAWFLAG_NORMAL);

		/* do the line indicating the height of the player relative to us */
		ht = fabs(difference[2] * (64 / CSRADAR_DISTANCE));

		if (difference[2] > 0)
			drawfill(apos + [1,0], [2,ht], color, 1.0f, DRAWFLAG_NORMAL);
		else if (difference[2] < 0)
			drawfill(apos + [1,-ht], [2,ht], color, 1.0f, DRAWFLAG_NORMAL);

		//drawpic(apos, "fade_modulate", [4,4], color, 1.0f, 0);
	}
}
