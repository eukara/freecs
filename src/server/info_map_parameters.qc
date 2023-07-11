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

/*!QUAKED info_map_parameters (0 0 0.8) (-16 -16 0) (16 16 16)
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

typedef enum
{
	BUY_BOTH,
	BUY_CT,
	BUY_T,
	BUY_NEITHER
} imp_buyrules_t;

class
info_map_parameters:NSEntity
{
	float m_flBombRadius;
	imp_buyrules_t m_buyRules;
	
	void(void) info_map_parameters;

	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;
};

void
info_map_parameters::info_map_parameters(void)
{
	m_flBombRadius = 500;
	m_buyRules = BUY_BOTH;
}

void
info_map_parameters::Respawn(void)
{
	g_cstrike_buying = m_buyRules;
	g_cstrike_bombradius = m_flBombRadius;
}

void
info_map_parameters::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "buying":
		m_buyRules = stoi(strValue);
		break;
	case "bombradius":
		m_flBombRadius = stof(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
		break;
	}
}