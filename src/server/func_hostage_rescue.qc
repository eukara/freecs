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

/*QUAKED func_hostage_rescue (0 .5 .8) ?
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.

COUNTER-STRIKE (1999) ENTITY

Hostage rescue zone.

Used in the Hostage Rescue mode (cs_* maps).
If neither a func_hostage_rescue or a info_hostage_rescue is placed,
zones will be placed in Counter-Terrorist player spawn nodes automatically.
*/

class func_hostage_rescue:CBaseTrigger
{
	void(void) func_hostage_rescue;

	virtual void(void) touch;
	virtual void(void) Respawn;
};

void
func_hostage_rescue::touch(void)
{
	if (other.flags & FL_CLIENT) {
		player pl = (player)other;
		pl.gflags |= GF_RESCUEZONE;
		return;
	}
	
	if (other.classname != "hostage_entity") {
		return;
	}

	CBaseNPC hosty = (CBaseNPC)other;

	if (hosty.solid == SOLID_NOT) {
		return;
	}

	if (!((player)hosty.m_eFollowing))
		return;

	Radio_BroadcastMessage(RADIO_RESCUED);
	g_cs_hostagesrescued++;

	Money_AddMoney((player)hosty.m_eFollowing, 1000);

	/* In Hostage Rescue, all Counter-Terrorists receive an $850
	 * bonus for every hostage that was rescued, even if they lose the round. */
	Money_QueTeamReward(TEAM_CT, 850);

	CBaseEntity targa = (CBaseEntity)other;
	targa.Hide();
}

void
func_hostage_rescue::Respawn(void)
{
	InitBrushTrigger();
}

void
func_hostage_rescue::func_hostage_rescue(void)
{
	CBaseTrigger::CBaseTrigger();
	InitBrushTrigger();
}
