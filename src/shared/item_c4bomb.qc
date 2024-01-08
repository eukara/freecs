/*
 * Copyright (c) 2016-2021 Marco Cawthorne <marco@icculus.org>
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

class item_c4:NSRenderableEntity
{
#ifdef SERVER
	entity m_eUser;
	float m_flBeepTime;
	float m_flExplodeTime;
	float m_flDefusalState;
#endif

#ifdef SERVER
	void item_c4(void);

	virtual void Spawned(void);
	virtual float SendEntity(entity, float);
	virtual void ClearProgress(void);
	virtual void OnPlayerUse(void);
	virtual void Logic(void);
	virtual void OnRemoveEntity(void);
#endif

#ifdef CLIENT
	void item_c4(void);
	virtual void DrawLED(void);
	virtual float predraw(void);
#endif
};

void
item_c4::item_c4(void)
{
#ifdef SERVER
	m_eUser = __NULL__;
	m_flBeepTime = 0.0f;
	m_flExplodeTime = 0.0f;
	m_flDefusalState = 0.0f;
#endif
}

#ifdef SERVER
float
item_c4::SendEntity(entity pvsent, float flags)
{
	WriteByte(MSG_ENTITY, ENT_C4BOMB);
	WriteCoord(MSG_ENTITY, origin[0]);
	WriteCoord(MSG_ENTITY, origin[1]);
	WriteCoord(MSG_ENTITY, origin[2]);
	WriteCoord(MSG_ENTITY, angles[0]);
	WriteCoord(MSG_ENTITY, angles[1]);
	WriteCoord(MSG_ENTITY, angles[2]);
	WriteShort(MSG_ENTITY, modelindex);
	return (1);
}

void
item_c4::ClearProgress(void)
{
	if (m_eUser != world) {
		player pl = (player)m_eUser;
		pl.progress = 0.0f;
		pl.flags &= ~FL_FROZEN;
	}
}

void
item_c4::OnPlayerUse(void)
{
	player pl = (player)eActivator;

	/* obvious check */
	if (pl.team != TEAM_CT) {
		return;
	}

	/* don't allow anyone else to hijack. */
	if (m_eUser == world) {
		m_eUser = eActivator;
		StartSoundDef("weapon_c4bomb.disarm", CHAN_ITEM, true);
	}
}

void
item_c4::Logic(void)
{
	CSMultiplayerRules rules = (CSMultiplayerRules)g_grMode;

	/* check if we're being used */
	if (m_eUser != world) {
		player pl = (player)m_eUser;

		/* we need to check if the user has changed every frame. */
		if (!m_eUser.button5) {
			ClearProgress();

			/* clear user */
			m_eUser = world;
			m_flDefusalState = 0.0f;
			g_cs_bombbeingdefused = FALSE;
		} else {

			/* defusal kit always cuts the time in half */
			if (pl.g_items & ITEM_DEFUSAL)
				m_flDefusalState += (frametime * 2);
			else
				m_flDefusalState += frametime;

			/* tracked stat */
			pl.progress = m_flDefusalState;
			pl.flags |= FL_FROZEN;

			g_cs_bombbeingdefused = TRUE;
		}
	}

	if (m_flDefusalState > 10.0f) {
		StartSoundDef("weapon_c4bomb.disarmed", CHAN_VOICE, true);
		rules.RoundOver(TEAM_CT, 3600, TRUE);
		Radio_BroadcastMessage(RADIO_BOMBDEF);
		Destroy();
		return;
	}

	/* if our time has passed, explode */
	if (m_flExplodeTime < time) {
		float bestDist = 9999.0f;
		NSEntity bestTarget = __NULL__;

		/* In Bomb Defusal, all Terrorists receive $3500
		 * if they won by detonating the bomb. */
		rules.RoundOver(TEAM_T, 3500, FALSE);
		Damage_Radius(origin, this.real_owner, 500, g_cstrike_bombradius, false, WEAPON_C4BOMB);
		StartSoundDef("weapon_c4bomb.explode", CHAN_VOICE, true);

		for (entity e = world; (e = find(e, ::classname, "func_bomb_target"));) {
			float dist = vlen(origin - e.origin);

			if (dist < bestDist) {
				bestDist = dist;
				bestTarget = e;
			}
		}

		/* Found it. */
		if (bestTarget) {
			bestTarget.UseTargets(this, TRIG_TOGGLE, 0.0f);
		}

		Destroy();
		return;
	}

	if (m_flBeepTime > time) {
		return;
	}
	m_flBeepTime = time + 1.5;

	if (m_flExplodeTime - time < 5) {
		StartSoundDef("weapon_c4bomb.beep5", CHAN_VOICE, true);
	} else if (m_flExplodeTime - time < 10) {
		StartSoundDef("weapon_c4bomb.beep4", CHAN_VOICE, true);
	} else if (m_flExplodeTime - time < 20) {
		StartSoundDef("weapon_c4bomb.beep3", CHAN_VOICE, true);
	} else if (m_flExplodeTime - time < 30) {
		StartSoundDef("weapon_c4bomb.beep2", CHAN_VOICE, true);
	} else {
		StartSoundDef("weapon_c4bomb.beep1", CHAN_VOICE, true);
	}
}

void
item_c4::OnRemoveEntity(void)
{
	ClearProgress();
	m_flBeepTime = 0.0f;
	m_flDefusalState = 0;
	g_cs_bombbeingdefused = FALSE;
	g_cs_bombplanted = false;
}

void
item_c4::Spawned(void)
{
	super::Spawned();

	/* throw this in with the other temporary round entities */
	classname = "remove_me";

	SetMovetype(MOVETYPE_NONE);
	SetSolid(SOLID_BBOX);
	SetModel("models/w_c4.mdl");
	SetSize([-6,-6,0], [6,6,6]);

	customphysics = Logic;
	PlayerUse = OnPlayerUse;
	m_flExplodeTime = time + 45.0f;
	StartSoundDef("weapon_c4bomb.plant", CHAN_WEAPON, true);
}

void
C4Bomb_Plant(NSClientPlayer planter)
{
	item_c4 bomb = spawn(item_c4);
	bomb.Spawned();
	bomb.real_owner = planter;

	/* place directly below */
	traceline(planter.origin, planter.origin + [0,0,-64], FALSE, planter);
	setorigin(bomb, trace_endpos);
	bomb.SendFlags = -1;

	/* push the player out if we're on top */
	setorigin_safe(planter, planter.origin);

	Radio_BroadcastMessage(RADIO_BOMBPL);
	CSBot_BombPlantedNotify();
	g_cs_bombplanted = TRUE;
}
#endif

#ifdef CLIENT
void
item_c4::DrawLED(void)
{
	vector cameraPos = g_view.GetCameraOrigin();
	float ledAlpha = 1.0 - (time - floor(time));

	if (ledAlpha > 0.0f) {
		vector ledPos = GetOrigin() + [0,0,8];
		vector ledSize = [16,16];
		
		/* Scale the glow somewhat with the players distance */
		ledSize *= bound(1, vlen(cameraPos - origin) / 256, 4);

		/* Nudge this slightly towards the camera */
		makevectors(vectoangles(ledPos - cameraPos));
		ledPos += (v_forward * -16);

		/* Project it, always facing the player */
		makevectors(g_view.GetCameraAngle());
		R_BeginPolygon(g_c4bombled_spr, 1, 0);
		R_PolygonVertex(ledPos + v_right * ledSize[0] - v_up * ledSize[1],
			[1,1], [1,1,1] * ledAlpha, 1.0f);
		R_PolygonVertex(ledPos - v_right * ledSize[0] - v_up * ledSize[1],
			[0,1], [1,1,1] * ledAlpha, 1.0f);
		R_PolygonVertex(ledPos - v_right * ledSize[0] + v_up * ledSize[1],
			[0,0], [1,1,1] * ledAlpha, 1.0f);
		R_PolygonVertex(ledPos + v_right * ledSize[0] + v_up * ledSize[1],
			[1,0], [1,1,1] * ledAlpha, 1.0f);
		R_EndPolygon();
	}
}

float
item_c4::predraw(void)
{
	DrawLED();
	addentity(this);
	return PREDRAW_NEXT;
}

void
w_c4bomb_parse(void)
{
	item_c4 tm = (item_c4)self;
	spawnfunc_item_c4();

	g_c4bombled_spr = spriteframe("sprites/ledglow.spr", 0, 0.0f);

	tm.origin[0] = readcoord();
	tm.origin[1] = readcoord();
	tm.origin[2] = readcoord();
	tm.angles[0] = readcoord();
	tm.angles[1] = readcoord();
	tm.angles[2] = readcoord();
	tm.modelindex = readshort();
	setorigin(tm, tm.origin);
	setsize(tm, [-6,-6,0], [6,6,6]);
	tm.solid = SOLID_BBOX;
	tm.movetype = MOVETYPE_NONE;
	tm.drawmask = MASK_ENGINE;
}
#endif
