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

/* pre-calculated sprite definitions */
float spr_health[4] = {
	48 / 256, // pos x
	25 / 256, // pos u
	24 / 256, // size x
	24 / 256 // size y
};

float spr_suit1[4] = {
	0 / 256, // pos x
	25 / 256, // pos u
	24 / 256, // size x
	24 / 256 // size y
};

float spr_suit2[4] = {
	24 / 256, // pos x
	25 / 256, // pos u
	24 / 256, // size x
	24 / 256 // size y
};

float spr_suit3[4] = {
	0 / 256, // pos x
	124 / 256, // pos u
	24 / 256, // size x
	24 / 256 // size y
};

float spr_suit4[4] = {
	24 / 256, // pos x
	124 / 256, // pos u
	24 / 256, // size x
	24 / 256 // size y
};

float spr_flash1[4] = {
	160 / 256, // pos x
	24 / 256, // pos u
	32 / 256, // size x
	32 / 256 // size y
};

float spr_flash2[4] = {
	112 / 256, // pos x
	24 / 256, // pos u
	48 / 256, // size x
	32 / 256 // size y
};

string
HUD_GetChatColorHEX(float fTeam)
{
	if (fTeam == TEAM_CT) {
		return "^x7AC";
	} else if (fTeam == TEAM_T) {
		return "^xC33";
	} else {
		return "^xCCC";
	}
}
