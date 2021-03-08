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

/*QUAKED func_bomb_target (0 .5 .8) ?
"targetname"    Name
"target"        Target when bomb blows up.
"killtarget"    Target to kill when triggered.

COUNTER-STRIKE (1999) ENTITY

Bomb target zone.

Used in the bomb defusal mode (de_* maps).
Once the bomb explodes inside this volume, it'll trigger its targets.
*/

class func_bomb_target:CBaseTrigger
{
	void(void) func_bomb_target;

	virtual void(void) Respawn;
	virtual void(void) touch;
};

void
func_bomb_target::touch(void)
{
	player pl = (player)other;
	if (!(other.flags & FL_CLIENT)) {
		return;
	}

	if (pl.team != TEAM_T) {
		return;
	}

	pl.gflags |= GF_BOMBZONE;
}

void
func_bomb_target::Respawn(void)
{
	InitBrushTrigger();
}

void
func_bomb_target::func_bomb_target(void)
{
	g_cs_bombzones++;
}
