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

/*!QUAKED info_buyzone (0 0 0.8) (-16 -16 0) (16 16 16)
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.

COUNTER-STRIKE (1999) ENTITY

Buy zone.
See func_buyzone for more information.
*/

class
info_buyzone:NSPointTrigger
{
	void info_buyzone(void);

	virtual void Respawn(void);
	virtual void Touch(entity);
};

void
info_buyzone::info_buyzone(void)
{
}

void
info_buyzone::Respawn(void)
{
	SetSolid(SOLID_TRIGGER);
	SetSize([-128,-128,-128], [128,128,128]);
	SetOrigin(GetSpawnOrigin());
}

void
info_buyzone::Touch(entity eToucher)
{
	player pl = (player)eToucher;

	if (!(eToucher.flags & FL_CLIENT))
		return;

	if (team == 0 || team == pl.team)
		pl.gflags |= GF_BUYZONE;
}
