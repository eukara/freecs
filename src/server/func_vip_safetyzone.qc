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

/*!QUAKED func_vip_safetyzone (0 .5 .8) ?
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.

COUNTER-STRIKE (1999) ENTITY

VIP safety zone.

Used in the assassination mode (as_* maps).
*/

class func_vip_safetyzone:NSBrushTrigger
{
	void func_vip_safetyzone(void);

	virtual void Respawn(void);
	virtual void Touch(entity);

};

void
func_vip_safetyzone::func_vip_safetyzone(void)
{
	g_cs_vipzones++;
}

void
func_vip_safetyzone::Respawn(void)
{
	InitBrushTrigger();
}

void
func_vip_safetyzone::Touch(entity eToucher)
{
	CSMultiplayerRules rule = (CSMultiplayerRules)g_grMode;

	player pl = (player)eToucher;

	if (pl.classname != "player")
		return;
	if (pl.team != TEAM_VIP)
		return;

	/* CTs win the round */
	rule.RoundOver(TEAM_CT, 3500, FALSE);
	/* VIP receives money to spend */
	Money_AddMoney(pl, 2500);

	/* mark player as spectator for the end of this 'round' */
	pl.MakeTempSpectator();
	pl.gflags &= ~GF_FLASHLIGHT;
}
