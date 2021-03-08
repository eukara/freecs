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

/*QUAKED func_buyzone (0 .5 .8) ?
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.
"team"          Limits the buyzone to be used by set team.

COUNTER-STRIKE (1999) ENTITY

Buy zone.

The buyzone is a brush volume that upon creation forces players of set team
to buy weapons in its designated area.
If this entity is not present, the game will automatically spawn buyzones
around each player spawn, unless prevented using a setting inside the
info_map_parameters entity.

Info about automatically generated buyzones:
If no func_buyzone exists, the game will create one buyzone volume with a total
width of 256 units (radius thus being 128 units) on every player spawn point.

Choices for 'team' include:
    0 = All teams
    1 = Terrorist
    2 = Counter-Terrorist
*/

class func_buyzone:CBaseTrigger
{
	void(void) func_buyzone;

	virtual void(void) touch;
	virtual void(void) Respawn;
};

void
func_buyzone::touch(void)
{
	player pl = (player)other;
	if (!(other.flags & FL_CLIENT))
		return;

	if (team == 0 || team == pl.team)
		pl.gflags |= GF_BUYZONE;
}

void
func_buyzone::Respawn(void)
{
	InitBrushTrigger();
}

void
func_buyzone::func_buyzone(void)
{
	CBaseTrigger::CBaseTrigger();
	InitBrushTrigger();
}
