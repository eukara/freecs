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

/*QUAKED hostage_entity (0 1 0) (-16 -16 0) (16 16 72)
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.
"model"         "models/hostage.mdl"
"skin"          "0"

COUNTER-STRIKE (1999) ENTITY

Hostage NPC.

Used in the Hostage Rescue mode (cs_* maps).

*/

enum
{
	HOSA_WALK,
	HOSA_WALKSCARED,
	HOSA_RUN,
	HOSA_RUNSCARED,
	HOSA_RUNLOOK,
	HOSA_180LEFT,
	HOSA_180RIGHT,
	HOSA_FLINCH,
	HOSA_PAIN,
	HOSA_PAINLEFT,
	HOSA_PAINRIGHT,
	HOSA_PAINLEGLEFT,
	HOSA_PAINLEGRIGHT,
	HOSA_IDLE1,
	HOSA_IDLE2,
	HOSA_IDLE3,
	HOSA_IDLE4,
	HOSA_IDLE5,
	HOSA_IDLE6,
	HOSA_SCARED_END,
	HOSA_SCARED1,
	HOSA_SCARED2,
	HOSA_SCARED3,
	HOSA_SCARED4,
	HOSA_PANIC,
	HOSA_FEAR1,
	HOSA_FEAR2,
	HOSA_CRY,
	HOSA_SCI1,
	HOSA_SCI2,
	HOSA_SCI3,
	HOSA_DIE_SIMPLE,
	HOSA_DIE_FORWARD1,
	HOSA_DIE_FORWARD2,
	HOSA_DIE_BACKWARD,
	HOSA_DIE_HEADSHOT,
	HOSA_DIE_GUTSHOT,
	HOSA_LYING1,
	HOSA_LYING2,
	HOSA_DEADSIT,
	HOSA_DEADTABLE1,
	HOSA_DEADTABLE2,
	HOSA_DEADTABLE3
};

class hostage_entity:CBaseNPC
{
	int m_iUsedOnce;

	void(void) hostage_entity;

	virtual void(void) Respawn;
	virtual void(void) OnPlayerUse;
	virtual void(void) Pain;
	virtual void(void) Death;
	virtual int(void) AnimIdle;
	virtual int(void) AnimWalk;
	virtual int(void) AnimRun;
};

int
hostage_entity::AnimIdle(void)
{
	return HOSA_IDLE1;
}

int
hostage_entity::AnimWalk(void)
{
	return HOSA_WALK;
}

int
hostage_entity::AnimRun(void)
{
	return HOSA_RUN;
}

void
hostage_entity::OnPlayerUse(void)
{
	if (eActivator.team == TEAM_T) {
		return;
	}

	if (m_eFollowing == world)
		Sound_Speak(this, "hostage_entity.follow");

	/* CT reward, first time only */
	if (m_iUsedOnce == FALSE) {
		Money_AddMoney((player)eActivator, 150);
		m_iUsedOnce = TRUE;
	}

	CBaseNPC::OnPlayerUse();
}

void
hostage_entity::Pain(void)
{
	switch (g_dmg_iHitBody) {
	case BODY_HEAD:
	case BODY_DEFAULT:
	case BODY_CHEST:
	case BODY_STOMACH:
		AnimPlay(HOSA_PAIN);
		break;
	case BODY_ARMLEFT:
		AnimPlay(HOSA_PAINLEFT);
		break;
	case BODY_ARMRIGHT:
		AnimPlay(HOSA_PAINRIGHT);
		break;
	case BODY_LEGLEFT:
		AnimPlay(HOSA_PAINLEGLEFT);
		break;
	case BODY_LEGRIGHT:
		AnimPlay(HOSA_PAINLEGRIGHT);
		break;
	}

	/* penalties */
	if (g_dmg_eAttacker.classname != "player")
		return;

	Money_AddMoney((base_player)g_dmg_eAttacker, -(g_dmg_iDamage * 25));
}

void 
hostage_entity::Death(void)
{
	WarnAllies();

	if (style != MONSTER_DEAD) {
		SetFrame(HOSA_DIE_SIMPLE + floor(random(0, 6)));
	}

	/* now mark our state as 'dead' */
	CBaseNPC::Death();

	/* penalties */
	if (g_dmg_eAttacker.classname != "player")
		return;

	if (g_dmg_iDamage >= 100)
		Money_AddMoney((base_player)g_dmg_eAttacker, -2500);
	else
		Money_AddMoney((base_player)g_dmg_eAttacker, -500);

	Radio_BroadcastMessage(RADIO_HOSDOWN);
}

void
hostage_entity::Respawn(void)
{
	CBaseNPC::Respawn();
	m_iFlags |= MONSTER_CANFOLLOW;
	m_iUsedOnce = FALSE;
	PlayerUse = OnPlayerUse;
}

void
hostage_entity::hostage_entity(void)
{
	Sound_Precache("hostage_entity.follow");

	m_talkAnswer = "";
	m_talkAsk = "";
	m_talkAllyShot = "";
	m_talkGreet = "";
	m_talkIdle = "";
	m_talkHearing = "";
	m_talkSmelling = "";
	m_talkStare = "";
	m_talkSurvived = "";
	m_talkWounded = "";

	m_talkPlayerAsk = "";
	m_talkPlayerGreet = "";
	m_talkPlayerIdle = "";
	m_talkPlayerWounded1 = "";
	m_talkPlayerWounded2 = "";
	m_talkPlayerWounded3 = "";
	m_talkUnfollow = "";
	m_talkFollow = "";
	m_talkStopFollow = "";

	spawnflags |= MSF_MULTIPLAYER;
	model = "models/hostage.mdl";
	netname = "Hostage";
	base_health = 100;
	base_mins = [-16,-16,0];
	base_maxs = [16,16,72];
	CBaseNPC::CBaseNPC();
	g_cs_hostagestotal++;
}
