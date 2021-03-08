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

#define CS_CROSS_COLOR [0,1,0]
#define CS_CROSS_ALPHA 1.0f

void
Cstrike_DrawCrosshair(void)
{
	player pl = (player)self;
	int cross_dist;
	int line_length;

	/* these are defined in the weapon-code files */
	float distance = pl.cs_cross_mindist; 
	float delta = pl.cs_cross_deltadist;

	if (!(pl.flags & FL_ONGROUND)) {
		distance = distance * 2.0f;
	} else if (pl.flags & FL_CROUCHING) { /* crouching... */
		distance = distance * 0.5f;
	} else if (vlen(pl.velocity) > 120) { /* running, not walking */
		distance = distance * 1.5f;
	}

	/* amount of shots that we've shot does affect our accuracy */
	if (pl.cs_shotmultiplier > pl.cs_shotmultiplier_net) {
		pl.cs_crosshairdistance = min(15, pl.cs_crosshairdistance + delta);
	} else if (pl.cs_crosshairdistance > distance) {
		pl.cs_crosshairdistance -= (pl.cs_crosshairdistance * clframetime);
	}

	pl.cs_shotmultiplier_net = pl.cs_shotmultiplier;
	
	if (pl.cs_crosshairdistance < distance) {
		 pl.cs_crosshairdistance = distance;
	}

	cross_dist = ceil(pl.cs_crosshairdistance);
	line_length = max(1, ((cross_dist - distance) / 2) + 5);

	/* line setup */
	vector vert1, vert2, hori1, hori2;
	vert1 = vert2 = hori1 = hori2 = g_hudmins + (g_hudres / 2);

	/* vertical Lines */
	vert1[1] -= (cross_dist + line_length);
	vert2[1] += cross_dist + 1;

	/* horizontal Lines */
	hori1[0] -= (cross_dist + line_length);
	hori2[0] += cross_dist + 1;

	drawfill(vert1, [1, line_length], CS_CROSS_COLOR, CS_CROSS_ALPHA, DRAWFLAG_ADDITIVE);
	drawfill(vert2, [1, line_length], CS_CROSS_COLOR, CS_CROSS_ALPHA, DRAWFLAG_ADDITIVE);
	drawfill(hori1, [line_length, 1], CS_CROSS_COLOR, CS_CROSS_ALPHA, DRAWFLAG_ADDITIVE);
	drawfill(hori2, [line_length, 1], CS_CROSS_COLOR, CS_CROSS_ALPHA, DRAWFLAG_ADDITIVE);
}

/* AUG zoom uses this. so does the spectator cam */
void
Cstrike_DrawSimpleCrosshair(void)
{
	static vector cross_pos;
	cross_pos = g_hudmins + (g_hudres / 2) + [-12,-12];
	drawsubpic(cross_pos, [24,24], g_cs_cross, [0.1875,0], [0.1875, 0.1875], [1,1,1], 1, DRAWFLAG_NORMAL);
}

/*
=================
HUD_DrawScope

Tries to draw a scope whenever viewzoom < 1.0f
=================
*/
void
Cstrike_DrawScope(void)
{
	vector scope_pos;
	static float scope_offset;
	static float scope_scale;

	static void Cstrike_ScopePic(vector pos, vector sz, string img) {
		drawpic((pos * scope_scale) + [scope_offset, 0], img, sz * scope_scale, [1,1,1], 1.0f);
	}

	// Draw the scope in the middle, seperately from the border
	scope_pos = g_hudmins + (g_hudres / 2) + [-128,-128];
	drawpic(scope_pos, g_cs_scope0, [256,256], [1,1,1], 1.0f, DRAWFLAG_NORMAL);

	// Border scale to fit the screen
	scope_scale = g_hudres[1] / 480;
	scope_offset = g_hudmins[0] + (g_hudres[0] / 2) - ((640 * scope_scale) / 2);

	// Type 1 Border... more coming soon?
	Cstrike_ScopePic([0,0], [192,112], g_cs_scope1);
	Cstrike_ScopePic([192,0], [256,112], g_cs_scope2);
	Cstrike_ScopePic([448,0], [192,112], g_cs_scope3);
	Cstrike_ScopePic([0,112], [192,256], g_cs_scope4);
	Cstrike_ScopePic([448,112], [192,256], g_cs_scope5);
	Cstrike_ScopePic([0,368], [192,112], g_cs_scope6);
	Cstrike_ScopePic([192,368], [256,112], g_cs_scope7);
	Cstrike_ScopePic([448,368], [192,112], g_cs_scope8);

	// Rect borders left and right
	if (scope_offset > 0) {
		drawfill([0,0], [scope_offset, g_hudres[1]], [0,0,0], 1.0f);
		drawfill([(640 * scope_scale) + scope_offset, 0], [scope_offset, g_hudres[1]], [0,0,0], 1.0f);
	}
}
