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

/*QUAKED info_map_parameters (0 0 0.8) (-16 -16 0) (16 16 16)
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.
"buying"        Override for buy-behaviour.
"bombradius"    Overrides the default bomb radius.

COUNTER-STRIKE (1999) ENTITY

Miscellaneous mapping parameters.

Choices for 'buying':
    0 = Both teams can buy items
    1 = Only Counter-Terrorists can buy items
    2 = Only Terrorists can buy items
    3 = Neither Counter-Terrorists nor Terrorists can buy items
*/

enum
{
	BUY_BOTH,
	BUY_CT,
	BUY_T,
	BUY_NEITHER
};

class info_map_parameters
{
	void(void) info_map_parameters;
};

void
info_map_parameters::info_map_parameters(void)
{
	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "buying":
			g_cstrike_buying = stoi(argv(i+1));
			break;
		case "bombradius":
			g_cstrike_bombradius = stof(argv(i+1));
			break;
		default:
			break;
		}
	}
}
