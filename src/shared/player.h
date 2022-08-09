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

/* all potential SendFlags bits we can possibly send */
enumflags
{
	PLAYER_TOPFRAME = PLAYER_CUSTOMFIELDSTART,
	PLAYER_BOTTOMFRAME,
	PLAYER_AMMO1,
	PLAYER_AMMO2,
	PLAYER_AMMO3,
	PLAYER_CSTIMERS
};

class player:NSClientPlayer
{
	int ingame;

	PREDICTED_INT(usp45_mag);
	PREDICTED_INT(glock18_mag);
	PREDICTED_INT(deagle_mag);
	PREDICTED_INT(p228_mag);
	PREDICTED_INT(elites_mag);
	PREDICTED_INT(fiveseven_mag);
	PREDICTED_INT(m3_mag);
	PREDICTED_INT(xm1014_mag);
	PREDICTED_INT(mp5_mag);
	PREDICTED_INT(p90_mag);
	PREDICTED_INT(ump45_mag);
	PREDICTED_INT(mac10_mag);
	PREDICTED_INT(tmp_mag);
	PREDICTED_INT(ak47_mag);
	PREDICTED_INT(sg552_mag);
	PREDICTED_INT(m4a1_mag);
	PREDICTED_INT(aug_mag);
	PREDICTED_INT(scout_mag);
	PREDICTED_INT(awp_mag);
	PREDICTED_INT(g3sg1_mag);
	PREDICTED_INT(sg550_mag);
	PREDICTED_INT(para_mag);

	PREDICTED_INT(ammo_50ae);
	PREDICTED_INT(ammo_762mm);
	PREDICTED_INT(ammo_556mm);
	PREDICTED_INT(ammo_556mmbox);
	PREDICTED_INT(ammo_338mag);
	PREDICTED_INT(ammo_9mm);
	PREDICTED_INT(ammo_buckshot);
	PREDICTED_INT(ammo_45acp);
	PREDICTED_INT(ammo_357sig);
	PREDICTED_INT(ammo_57mm);
	PREDICTED_INT(ammo_hegrenade);
	PREDICTED_INT(ammo_fbgrenade);
	PREDICTED_INT(ammo_smokegrenade);

	PREDICTED_INT(mode_usp45);
	PREDICTED_INT(mode_m4a1);
	PREDICTED_INT(mode_glock18);
	PREDICTED_INT(mode_temp);

	PREDICTED_INT(cs_shotmultiplier);
	PREDICTED_FLOAT(cs_shottime);

	PREDICTED_FLOAT(anim_top);
	PREDICTED_FLOAT(anim_top_time);
	PREDICTED_FLOAT(anim_top_delay);
	PREDICTED_FLOAT(anim_bottom);
	PREDICTED_FLOAT(anim_bottom_time);

	virtual float(void) Physics_MaxSpeed;
	virtual void(float) Physics_Fall;
	virtual void(void) Physics_Jump;

	virtual void(void) Physics_InputPostMove;

#ifdef CLIENT
	int playertype;

	int cs_cross_mindist;
	int cs_cross_deltadist;
	float cs_crosshairdistance;

	virtual void(void) draw;
	virtual float() predraw;
	virtual void(void) postdraw;
	virtual void(float, float) ReceiveEntity;
	virtual void(void) PredictPreFrame;
	virtual void(void) PredictPostFrame;
#else
	virtual void(void) EvaluateEntity;
	virtual float(entity, float) SendEntity;

	int charmodel;
	int money;
	float progress;
#endif
};

void
player::Physics_InputPostMove(void)
{
	super::Physics_InputPostMove();

#ifdef SERVER
	if (g_cs_gamestate == GAME_FREEZE) {
#else
	if (getstati(STAT_GAMESTATE) == GAME_FREEZE) {
#endif
		flags |= FL_FROZEN;
	}
}


#ifdef CLIENT
void Weapons_AmmoUpdate(entity);
void HUD_AmmoNotify_Check(player pl);
/*
=================
player::ReceiveEntity
=================
*/
void
player::ReceiveEntity(float flIsNew, float flChanged)
{
	NSClientPlayer::ReceiveEntity(flIsNew, flChanged);

	/* animation */
	READENTITY_BYTE(anim_top, PLAYER_TOPFRAME)
	READENTITY_FLOAT(anim_top_time, PLAYER_TOPFRAME)
	READENTITY_FLOAT(anim_top_delay, PLAYER_TOPFRAME)
	READENTITY_BYTE(anim_bottom, PLAYER_BOTTOMFRAME)
	READENTITY_FLOAT(anim_bottom_time, PLAYER_BOTTOMFRAME)
	READENTITY_BYTE(usp45_mag, PLAYER_AMMO1)
	READENTITY_BYTE(glock18_mag, PLAYER_AMMO1)
	READENTITY_BYTE(deagle_mag, PLAYER_AMMO1)
	READENTITY_BYTE(p228_mag, PLAYER_AMMO1)
	READENTITY_BYTE(elites_mag, PLAYER_AMMO1)
	READENTITY_BYTE(fiveseven_mag, PLAYER_AMMO1)
	READENTITY_BYTE(m3_mag, PLAYER_AMMO1)
	READENTITY_BYTE(xm1014_mag, PLAYER_AMMO1)
	READENTITY_BYTE(mp5_mag, PLAYER_AMMO1)
	READENTITY_BYTE(p90_mag, PLAYER_AMMO1)
	READENTITY_BYTE(ump45_mag, PLAYER_AMMO1)
	READENTITY_BYTE(mac10_mag, PLAYER_AMMO1)
	READENTITY_BYTE(tmp_mag, PLAYER_AMMO1)
	READENTITY_BYTE(ak47_mag, PLAYER_AMMO1)
	READENTITY_BYTE(sg552_mag, PLAYER_AMMO1)
	READENTITY_BYTE(m4a1_mag, PLAYER_AMMO1)
	READENTITY_BYTE(aug_mag, PLAYER_AMMO1)
	READENTITY_BYTE(scout_mag, PLAYER_AMMO1)
	READENTITY_BYTE(awp_mag, PLAYER_AMMO1)
	READENTITY_BYTE(g3sg1_mag, PLAYER_AMMO1)
	READENTITY_BYTE(sg550_mag, PLAYER_AMMO1)
	READENTITY_BYTE(para_mag, PLAYER_AMMO1)
	READENTITY_BYTE(ammo_50ae, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_762mm, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_556mm, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_556mmbox, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_338mag, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_9mm, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_buckshot, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_45acp, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_357sig, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_57mm, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_hegrenade, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_fbgrenade, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_smokegrenade, PLAYER_AMMO2)
	READENTITY_BYTE(mode_usp45, PLAYER_AMMO3)
	READENTITY_BYTE(mode_m4a1, PLAYER_AMMO3)
	READENTITY_BYTE(mode_glock18, PLAYER_AMMO3)
	READENTITY_BYTE(mode_temp, PLAYER_AMMO3)
	READENTITY_BYTE(cs_shotmultiplier, PLAYER_CSTIMERS)
	READENTITY_FLOAT(cs_shottime, PLAYER_CSTIMERS)

	if (flChanged & PLAYER_AMMO1 || flChanged & PLAYER_AMMO2 || flChanged & PLAYER_AMMO3) {
		Weapons_AmmoUpdate(this);
		HUD_AmmoNotify_Check(this);
	}

	setorigin(this, origin);
}

/*
=================
player::PredictPostFrame

Save the last valid server values away in the _net variants of each field
so we can roll them back later.
=================
*/
void
player::PredictPreFrame(void)
{
	NSClientPlayer::PredictPreFrame();

	SAVE_STATE(usp45_mag);
	SAVE_STATE(glock18_mag);
	SAVE_STATE(deagle_mag);
	SAVE_STATE(p228_mag);
	SAVE_STATE(elites_mag);
	SAVE_STATE(fiveseven_mag);
	SAVE_STATE(m3_mag);
	SAVE_STATE(xm1014_mag);
	SAVE_STATE(mp5_mag);
	SAVE_STATE(p90_mag);
	SAVE_STATE(ump45_mag);
	SAVE_STATE(mac10_mag);
	SAVE_STATE(tmp_mag);
	SAVE_STATE(ak47_mag);
	SAVE_STATE(sg552_mag);
	SAVE_STATE(m4a1_mag);
	SAVE_STATE(aug_mag);
	SAVE_STATE(scout_mag);
	SAVE_STATE(awp_mag);
	SAVE_STATE(g3sg1_mag);
	SAVE_STATE(sg550_mag);
	SAVE_STATE(para_mag);
	SAVE_STATE(ammo_50ae);
	SAVE_STATE(ammo_762mm);
	SAVE_STATE(ammo_556mm);
	SAVE_STATE(ammo_556mmbox);
	SAVE_STATE(ammo_338mag);
	SAVE_STATE(ammo_9mm);
	SAVE_STATE(ammo_buckshot);
	SAVE_STATE(ammo_45acp);
	SAVE_STATE(ammo_357sig);
	SAVE_STATE(ammo_57mm);
	SAVE_STATE(ammo_hegrenade);
	SAVE_STATE(ammo_fbgrenade);
	SAVE_STATE(ammo_smokegrenade);
	SAVE_STATE(mode_usp45);
	SAVE_STATE(mode_m4a1);
	SAVE_STATE(mode_glock18);
	SAVE_STATE(mode_temp);
	SAVE_STATE(cs_shotmultiplier);
	SAVE_STATE(cs_shottime);
	SAVE_STATE(anim_top);
	SAVE_STATE(anim_top_time);
	SAVE_STATE(anim_top_delay);
	SAVE_STATE(anim_bottom);
	SAVE_STATE(anim_bottom_time);
}

/*
=================
player::PredictPostFrame

Where we roll back our values to the ones last sent/verified by the server.
=================
*/
void
player::PredictPostFrame(void)
{
	NSClientPlayer::PredictPostFrame();

	ROLL_BACK(usp45_mag);
	ROLL_BACK(glock18_mag);
	ROLL_BACK(deagle_mag);
	ROLL_BACK(p228_mag);
	ROLL_BACK(elites_mag);
	ROLL_BACK(fiveseven_mag);
	ROLL_BACK(m3_mag);
	ROLL_BACK(xm1014_mag);
	ROLL_BACK(mp5_mag);
	ROLL_BACK(p90_mag);
	ROLL_BACK(ump45_mag);
	ROLL_BACK(mac10_mag);
	ROLL_BACK(tmp_mag);
	ROLL_BACK(ak47_mag);
	ROLL_BACK(sg552_mag);
	ROLL_BACK(m4a1_mag);
	ROLL_BACK(aug_mag);
	ROLL_BACK(scout_mag);
	ROLL_BACK(awp_mag);
	ROLL_BACK(g3sg1_mag);
	ROLL_BACK(sg550_mag);
	ROLL_BACK(para_mag);
	ROLL_BACK(ammo_50ae);
	ROLL_BACK(ammo_762mm);
	ROLL_BACK(ammo_556mm);
	ROLL_BACK(ammo_556mmbox);
	ROLL_BACK(ammo_338mag);
	ROLL_BACK(ammo_9mm);
	ROLL_BACK(ammo_buckshot);
	ROLL_BACK(ammo_45acp);
	ROLL_BACK(ammo_357sig);
	ROLL_BACK(ammo_57mm);
	ROLL_BACK(ammo_hegrenade);
	ROLL_BACK(ammo_fbgrenade);
	ROLL_BACK(ammo_smokegrenade);
	ROLL_BACK(mode_usp45);
	ROLL_BACK(mode_m4a1);
	ROLL_BACK(mode_glock18);
	ROLL_BACK(mode_temp);
	ROLL_BACK(cs_shotmultiplier);
	ROLL_BACK(cs_shottime);
	ROLL_BACK(anim_top);
	ROLL_BACK(anim_top_time);
	ROLL_BACK(anim_top_delay);
	ROLL_BACK(anim_bottom);
	ROLL_BACK(anim_bottom_time);
}

#else
void
player::EvaluateEntity(void)
{
	NSClientPlayer::EvaluateEntity();

	EVALUATE_FIELD(anim_top, PLAYER_TOPFRAME)
	EVALUATE_FIELD(anim_top_time, PLAYER_TOPFRAME)
	EVALUATE_FIELD(anim_top_delay, PLAYER_TOPFRAME)
	EVALUATE_FIELD(anim_bottom, PLAYER_BOTTOMFRAME)
	EVALUATE_FIELD(anim_bottom_time, PLAYER_BOTTOMFRAME)
	EVALUATE_FIELD(usp45_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(glock18_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(deagle_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(p228_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(elites_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(fiveseven_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(m3_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(xm1014_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(mp5_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(p90_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(ump45_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(mac10_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(tmp_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(ak47_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(sg552_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(m4a1_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(aug_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(scout_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(awp_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(g3sg1_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(sg550_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(para_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(ammo_50ae, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_762mm, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_556mm, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_556mmbox, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_338mag, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_9mm, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_buckshot, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_45acp, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_357sig, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_57mm, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_hegrenade, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_fbgrenade, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_smokegrenade, PLAYER_AMMO2)
	EVALUATE_FIELD(mode_usp45, PLAYER_AMMO3)
	EVALUATE_FIELD(mode_m4a1, PLAYER_AMMO3)
	EVALUATE_FIELD(mode_glock18, PLAYER_AMMO3)
	EVALUATE_FIELD(mode_temp, PLAYER_AMMO3)
	EVALUATE_FIELD(cs_shotmultiplier, PLAYER_CSTIMERS)
	EVALUATE_FIELD(cs_shottime, PLAYER_CSTIMERS)
}

/*
=================
player::SendEntity
=================
*/
float
player::SendEntity(entity ePEnt, float flChanged)
{
	/* don't broadcast invisible players */
	if (IsFakeSpectator() && ePEnt != this)
		return (0);
	if (!GetModelindex() && ePEnt != this)
		return (0);

	flChanged = OptimiseChangedFlags(ePEnt, flChanged);

	WriteByte(MSG_ENTITY, ENT_PLAYER);
	WriteFloat(MSG_ENTITY, flChanged);

	NSClientPlayer::SendEntity(ePEnt, flChanged);

	SENDENTITY_BYTE(anim_top, PLAYER_TOPFRAME)
	SENDENTITY_FLOAT(anim_top_time, PLAYER_TOPFRAME)
	SENDENTITY_FLOAT(anim_top_delay, PLAYER_TOPFRAME)
	SENDENTITY_BYTE(anim_bottom, PLAYER_BOTTOMFRAME)
	SENDENTITY_FLOAT(anim_bottom_time, PLAYER_BOTTOMFRAME)
	SENDENTITY_BYTE(usp45_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(glock18_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(deagle_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(p228_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(elites_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(fiveseven_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(m3_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(xm1014_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(mp5_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(p90_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(ump45_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(mac10_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(tmp_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(ak47_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(sg552_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(m4a1_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(aug_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(scout_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(awp_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(g3sg1_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(sg550_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(para_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(ammo_50ae, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_762mm, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_556mm, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_556mmbox, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_338mag, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_9mm, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_buckshot, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_45acp, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_357sig, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_57mm, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_hegrenade, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_fbgrenade, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_smokegrenade, PLAYER_AMMO2)
	SENDENTITY_BYTE(mode_usp45, PLAYER_AMMO3)
	SENDENTITY_BYTE(mode_m4a1, PLAYER_AMMO3)
	SENDENTITY_BYTE(mode_glock18, PLAYER_AMMO3)
	SENDENTITY_BYTE(mode_temp, PLAYER_AMMO3)
	SENDENTITY_BYTE(cs_shotmultiplier, PLAYER_CSTIMERS)
	SENDENTITY_FLOAT(cs_shottime, PLAYER_CSTIMERS)

	return (1);
}
#endif
