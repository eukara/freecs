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

/*QUAKED info_hostage_rescue (0 0 0.8) (-16 -16 0) (16 16 16)
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.

COUNTER-STRIKE (1999) ENTITY

Hostage rescue point.

Used in the Hostage Rescue mode (cs_* maps).
Creates a volume around itself with a radius of 128 units.
If neither a info_hostage_rescue or a func_hostage_rescue is placed,
zones will be placed in Counter-Terrorist player spawn nodes automatically.
*/

class info_hostage_rescue:NSPointTrigger
{
	void(void) info_hostage_rescue;

	virtual void(void) Respawn;
	virtual void(entity) Touch;
};

void
info_hostage_rescue::info_hostage_rescue(void)
{
}

void
info_hostage_rescue::Respawn(void)
{
	SetSolid(SOLID_TRIGGER);
	SetSize([-128,-128,-128], [128,128,128]);
	SetOrigin(GetSpawnOrigin());
}

void
info_hostage_rescue::Touch(entity eToucher)
{
	if (eToucher.flags & FL_CLIENT) {
		player pl = (player)eToucher;
		pl.gflags |= GF_RESCUEZONE;
		return;
	}

	if (eToucher.classname != "hostage_entity") {
		return;
	}

	NSTalkMonster hosty = (NSTalkMonster)other;

	if (hosty.GetSolid() == SOLID_NOT) {
		return;
	}

	/* some custom maps are very smart... */
	if (!((player)hosty.m_eFollowing))
		return;

	Radio_BroadcastMessage(RADIO_RESCUED);
	CSBot_HostageRescueNotify();
	g_cs_hostagesrescued++;

	Money_AddMoney((player)hosty.m_eFollowing, 1000);

	/* In Hostage Rescue, all Counter-Terrorists receive an $850
	 * bonus for every hostage they rescue, even if they lose the round. */
	Money_QueTeamReward(TEAM_CT, 850);
	hosty.Disappear();
}
