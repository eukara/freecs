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

class item_c4:CBaseEntity
{
#ifdef SERVER
	entity m_eUser;
	float m_flBeepTime;
	float m_flExplodeTime;
	float m_flDefusalState;
#endif

#ifdef CLIENT
	float m_flAlpha;
#endif

#ifdef SERVER
	void(void) item_c4;
	virtual float(entity, float) SendEntity;
	virtual void(void) ClearProgress;
	virtual void(void) OnPlayerUse;
	virtual void(void) Logic;
#endif

#ifdef CLIENT
	void(void) item_c4;
	virtual void(void) DrawLED;
	virtual float(void) predraw;
#endif
};

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
	return TRUE;
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
		sound(this, CHAN_ITEM, "weapons/c4_disarm.wav", 1.0, ATTN_NONE);
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
		} else {

			/* defusal kit always cuts the time in half */
			if (pl.g_items & ITEM_DEFUSAL)
				m_flDefusalState += (frametime * 2);
			else
				m_flDefusalState += frametime;

			/* tracked stat */
			pl.progress = m_flDefusalState;
			pl.flags |= FL_FROZEN;
		}
	}

	if (m_flDefusalState > 10.0f) {
		ClearProgress();
		sound(this, CHAN_VOICE, "weapons/c4_disarmed.wav", 1.0, ATTN_NORM);
		rules.RoundOver(TEAM_CT, 3600, TRUE);
		Radio_BroadcastMessage(RADIO_BOMBDEF);
		m_flBeepTime = 0.0f;
		m_flDefusalState = 0;
		remove(this);
		return;
	}

	/* if our time has passed, explode */
	if (m_flExplodeTime < time) {
		ClearProgress();

		/* In Bomb Defusal, all Terrorists receive $3500
		 * if they won by detonating the bomb. */
		rules.RoundOver(TEAM_T, 3500, FALSE);
		Damage_Radius(origin, this.owner, 500, g_cstrike_bombradius, FALSE, WEAPON_C4BOMB);
		Sound_Play(this, CHAN_VOICE, "weapon_c4bomb.explode");

		for (entity e = world; (e = find(e, ::classname, "func_bomb_target"));) {
			CBaseTrigger trigger = (CBaseTrigger)e;
			if (trigger.Trigger != __NULL__) {
				trigger.Trigger(this, TRIG_TOGGLE);
			}
		}

		m_flBeepTime = 0.0f;
		m_flDefusalState = 0;
		remove(this);
		return;
	}

	if (m_flBeepTime > time) {
		return;
	}
	m_flBeepTime = time + 1.5;

	if (m_flExplodeTime - time < 2) {
		sound(this, CHAN_VOICE, "weapons/c4_beep5.wav", 1.0, ATTN_NONE);
	} else if (m_flExplodeTime - time < 5) {
		sound(this, CHAN_VOICE, "weapons/c4_beep5.wav", 1.0, ATTN_NORM);
	} else if (m_flExplodeTime - time < 10) {
		sound(this, CHAN_VOICE, "weapons/c4_beep4.wav", 1.0, ATTN_NORM);
	} else if (m_flExplodeTime - time < 20) {
		sound(this, CHAN_VOICE, "weapons/c4_beep3.wav", 1.0, ATTN_NORM);
	} else if (m_flExplodeTime - time < 30) {
		sound(this, CHAN_VOICE, "weapons/c4_beep2.wav", 1.0, ATTN_NORM);
	} else {
		sound(this, CHAN_VOICE, "weapons/c4_beep1.wav", 1.0, ATTN_NORM);
	}
}

void
item_c4::item_c4(void)
{
	/* throw this in with the other temporary round entities */
	classname = "remove_me";

	SetMovetype(MOVETYPE_NONE);
	SetSolid(SOLID_BBOX);
	SetModel("models/w_c4.mdl");
	SetSize([-6,-6,0], [6,6,6]);

	customphysics = Logic;
	PlayerUse = OnPlayerUse;
	m_flExplodeTime = time + 45.0f;

	Sound_Play(this, CHAN_WEAPON, "weapon_c4bomb.plant");
}

void
C4Bomb_Plant(base_player planter)
{
	item_c4 bomb = spawn(item_c4);
	bomb.owner = planter;

	/* place directly below */
	traceline(planter.origin, planter.origin + [0,0,-64], FALSE, planter);
	setorigin(bomb, trace_endpos);
	bomb.SendFlags = -1;

	Radio_BroadcastMessage(RADIO_BOMBPL);
	g_cs_bombplanted = TRUE;
}
#endif

#ifdef CLIENT
void
item_c4::DrawLED(void)
{
	vector vecPlayer;

	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &g_seats[s];
	vecPlayer = pSeat->m_vecPredictedOrigin;

	m_flAlpha -= frametime;

	if (m_flAlpha <= 0.0f)
		m_flAlpha = 1.0f;

	if (m_flAlpha > 0) {
		vector forg;
		vector fsize;
		float falpha;
		
		/* Scale the glow somewhat with the players distance */
		fsize = [16,16];
		fsize *= bound(1, vlen(vecPlayer - origin) / 256, 4);

		/* Fade out when the player is starting to move away */
		falpha = 1 - bound(0, vlen(vecPlayer - origin) / 1024, 1);
		falpha *= m_flAlpha;

		/* Nudge this slightly towards the camera */
		makevectors(vectoangles(origin - vecPlayer));
		forg = (origin + [0,0,8]) + (v_forward * -16);

		/* Project it, always facing the player */
		makevectors(view_angles);
		R_BeginPolygon(g_c4bombled_spr, 1, 0);
		R_PolygonVertex(forg + v_right * fsize[0] - v_up * fsize[1],
			[1,1], [1,1,1], falpha);
		R_PolygonVertex(forg - v_right * fsize[0] - v_up * fsize[1],
			[0,1], [1,1,1], falpha);
		R_PolygonVertex(forg - v_right * fsize[0] + v_up * fsize[1],
			[0,0], [1,1,1], falpha);
		R_PolygonVertex(forg + v_right * fsize[0] + v_up * fsize[1],
			[1,0], [1,1,1], falpha);
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
item_c4::item_c4(void)
{
	solid = SOLID_BBOX;
	movetype = MOVETYPE_NONE;
	drawmask = MASK_ENGINE;
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
}
#endif
