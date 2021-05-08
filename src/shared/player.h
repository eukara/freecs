/*
 * Copyright (c) 2016-2021 Marco Hladik <marco@icculus.org>
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

enumflags
{
	PLAYER_KEEPALIVE,
	PLAYER_MODELINDEX,
	PLAYER_ORIGIN,
	PLAYER_ORIGIN_Z,
	PLAYER_ANGLES_X,
	PLAYER_ANGLES_Y,
	PLAYER_ANGLES_Z,
	PLAYER_VELOCITY,
	PLAYER_VELOCITY_Z,
	PLAYER_FLAGS,
	PLAYER_WEAPON,
	PLAYER_ITEMS,
	PLAYER_HEALTH,
	PLAYER_ARMOR,
	PLAYER_MOVETYPE,
	PLAYER_VIEWOFS,
	PLAYER_TOPFRAME,
	PLAYER_BOTTOMFRAME,
	PLAYER_AMMO1,
	PLAYER_AMMO2,
	PLAYER_AMMO3,
	PLAYER_CSSHOT,
	PLAYER_CSSHOTTIME
};

noref int input_sequence;
class player:base_player
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

#ifdef CLIENT
	/* External model */
	entity p_model;
	int playertype;
	int p_hand_bone;
	int p_model_bone;
	float lastweapon;

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


#ifdef CLIENT
void Weapons_AmmoUpdate(entity);
/*
=================
player::ReceiveEntity
=================
*/
void
player::ReceiveEntity(float new, float fl)
{
	base_player::ReceiveEntity(new, fl);

	/* animation */
	if (fl & PLAYER_TOPFRAME) {
		anim_top = readbyte();
		anim_top_time = readfloat();
		anim_top_delay = readfloat();
	}
	if (fl & PLAYER_BOTTOMFRAME) {
		anim_bottom = readbyte();
		anim_bottom_time = readfloat();
	}

	if (fl & PLAYER_AMMO1) {
		usp45_mag = readbyte();
		glock18_mag = readbyte();
		deagle_mag = readbyte();
		p228_mag = readbyte();
		elites_mag = readbyte();
		fiveseven_mag = readbyte();
		m3_mag = readbyte();
		xm1014_mag = readbyte();
		mp5_mag = readbyte();
		p90_mag = readbyte();
		ump45_mag = readbyte();
		mac10_mag = readbyte();
		tmp_mag = readbyte();
		ak47_mag = readbyte();
		sg552_mag = readbyte();
		m4a1_mag = readbyte();
		aug_mag = readbyte();
		scout_mag = readbyte();
		awp_mag = readbyte();
		g3sg1_mag = readbyte();
		sg550_mag = readbyte();
		para_mag = readbyte();
	}

	if (fl & PLAYER_AMMO2) {
		ammo_50ae = readbyte();
		ammo_762mm = readbyte();
		ammo_556mm = readbyte();
		ammo_556mmbox = readbyte();
		ammo_338mag = readbyte();
		ammo_9mm = readbyte();
		ammo_buckshot = readbyte();
		ammo_45acp = readbyte();
		ammo_357sig = readbyte();
		ammo_57mm = readbyte();
		ammo_hegrenade = readbyte();
		ammo_fbgrenade = readbyte();
		ammo_smokegrenade = readbyte();
	}

	if (fl & PLAYER_AMMO3) {
		mode_usp45 = readbyte();
		mode_m4a1 = readbyte();
		mode_glock18 = readbyte();
		mode_temp = readbyte();
	}

	if (fl & PLAYER_CSSHOT) {
		cs_shotmultiplier = readbyte();
	}
	if (fl & PLAYER_CSSHOTTIME) {
		cs_shottime = readfloat();
	}

	if (fl & PLAYER_AMMO1 || fl & PLAYER_AMMO2 || fl & PLAYER_AMMO3)
		Weapons_AmmoUpdate(this);

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
	base_player::PredictPreFrame();

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
	base_player::PredictPostFrame();

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
	base_player::EvaluateEntity();

	/* animation */
	if (anim_bottom_net != anim_bottom || anim_bottom_time != anim_bottom_time_net)
		SendFlags |= PLAYER_BOTTOMFRAME;
	if (anim_top_net != anim_top || anim_top_time != anim_top_time_net || anim_top_delay != anim_top_delay_net)
		SendFlags |= PLAYER_TOPFRAME;

	/* ammo 1 type updates */
	if (ATTR_CHANGED(glock18_mag))
		SendFlags |= PLAYER_AMMO1;
	else if (ATTR_CHANGED(usp45_mag))
		SendFlags |= PLAYER_AMMO1;
	else if (ATTR_CHANGED(glock18_mag))
		SendFlags |= PLAYER_AMMO1;
	else if (ATTR_CHANGED(deagle_mag))
		SendFlags |= PLAYER_AMMO1;
	else if (ATTR_CHANGED(p228_mag))
		SendFlags |= PLAYER_AMMO1;
	else if (ATTR_CHANGED(elites_mag))
		SendFlags |= PLAYER_AMMO1;
	else if (ATTR_CHANGED(fiveseven_mag))
		SendFlags |= PLAYER_AMMO1;
	else if (ATTR_CHANGED(m3_mag))
		SendFlags |= PLAYER_AMMO1;
	else if (ATTR_CHANGED(xm1014_mag))
		SendFlags |= PLAYER_AMMO1;
	else if (ATTR_CHANGED(mp5_mag))
		SendFlags |= PLAYER_AMMO1;
	else if (ATTR_CHANGED(p90_mag))
		SendFlags |= PLAYER_AMMO1;
	else if (ATTR_CHANGED(ump45_mag))
		SendFlags |= PLAYER_AMMO1;
	else if (ATTR_CHANGED(mac10_mag))
		SendFlags |= PLAYER_AMMO1;
	else if (ATTR_CHANGED(tmp_mag))
		SendFlags |= PLAYER_AMMO1;
	else if (ATTR_CHANGED(ak47_mag))
		SendFlags |= PLAYER_AMMO1;
	else if (ATTR_CHANGED(sg552_mag))
		SendFlags |= PLAYER_AMMO1;
	else if (ATTR_CHANGED(m4a1_mag))
		SendFlags |= PLAYER_AMMO1;
	else if (ATTR_CHANGED(aug_mag))
		SendFlags |= PLAYER_AMMO1;
	else if (ATTR_CHANGED(scout_mag))
		SendFlags |= PLAYER_AMMO1;
	else if (ATTR_CHANGED(awp_mag))
		SendFlags |= PLAYER_AMMO1;
	else if (ATTR_CHANGED(g3sg1_mag))
		SendFlags |= PLAYER_AMMO1;
	else if (ATTR_CHANGED(sg550_mag))
		SendFlags |= PLAYER_AMMO1;
	else if (ATTR_CHANGED(para_mag))
		SendFlags |= PLAYER_AMMO1;

	if (ATTR_CHANGED(ammo_50ae))
		SendFlags |= PLAYER_AMMO2;
	else if (ATTR_CHANGED(ammo_762mm))
		SendFlags |= PLAYER_AMMO2;
	else if (ATTR_CHANGED(ammo_556mm))
		SendFlags |= PLAYER_AMMO2;
	else if (ATTR_CHANGED(ammo_556mmbox))
		SendFlags |= PLAYER_AMMO2;
	else if (ATTR_CHANGED(ammo_338mag))
		SendFlags |= PLAYER_AMMO2;
	else if (ATTR_CHANGED(ammo_9mm))
		SendFlags |= PLAYER_AMMO2;
	else if (ATTR_CHANGED(ammo_buckshot))
		SendFlags |= PLAYER_AMMO2;
	else if (ATTR_CHANGED(ammo_45acp))
		SendFlags |= PLAYER_AMMO2;
	else if (ATTR_CHANGED(ammo_357sig))
		SendFlags |= PLAYER_AMMO2;
	else if (ATTR_CHANGED(ammo_57mm))
		SendFlags |= PLAYER_AMMO2;
	else if (ATTR_CHANGED(ammo_hegrenade))
		SendFlags |= PLAYER_AMMO2;
	else if (ATTR_CHANGED(ammo_fbgrenade))
		SendFlags |= PLAYER_AMMO2;
	else if (ATTR_CHANGED(ammo_smokegrenade))
		SendFlags |= PLAYER_AMMO2;

	if (ATTR_CHANGED(mode_usp45))
		SendFlags |= PLAYER_AMMO3;
	else if (ATTR_CHANGED(mode_m4a1))
		SendFlags |= PLAYER_AMMO3;
	else if (ATTR_CHANGED(mode_glock18))
		SendFlags |= PLAYER_AMMO3;
	else if (ATTR_CHANGED(mode_temp))
		SendFlags |= PLAYER_AMMO3;

	if (ATTR_CHANGED(cs_shotmultiplier))
		SendFlags |= PLAYER_CSSHOT;
	if (ATTR_CHANGED(cs_shottime))
		SendFlags |= PLAYER_CSSHOTTIME;

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

	if (g_cs_gamestate != GAME_FREEZE) {
		if (progress <= 0.0f) {
			flags &= ~FL_FROZEN;
			SendFlags |= PLAYER_FLAGS;
		}
	} 
}

/*
=================
player::SendEntity
=================
*/
float
player::SendEntity(entity ePEnt, float fChanged)
{
	if (health <= 0 && ePEnt != this) {
		return FALSE;
	}

	if (clienttype(ePEnt) != CLIENTTYPE_REAL) {
		return FALSE;
	}

	if (ePEnt != self) {
		fChanged &= ~PLAYER_ITEMS;
		fChanged &= ~PLAYER_HEALTH;
		fChanged &= ~PLAYER_ARMOR;
		fChanged &= ~PLAYER_VIEWOFS;
		fChanged &= ~PLAYER_AMMO1;
		fChanged &= ~PLAYER_AMMO2;
		fChanged &= ~PLAYER_AMMO3;
	}

	WriteByte(MSG_ENTITY, ENT_PLAYER);
	WriteFloat(MSG_ENTITY, fChanged);

	base_player::SendEntity(ePEnt, fChanged);

	if (fChanged & PLAYER_TOPFRAME) {
		WriteByte(MSG_ENTITY, anim_top);
		WriteFloat(MSG_ENTITY, anim_top_time);
		WriteFloat(MSG_ENTITY, anim_top_delay);
	}
	if (fChanged & PLAYER_BOTTOMFRAME) {
		WriteByte(MSG_ENTITY, anim_bottom);
		WriteFloat(MSG_ENTITY, anim_bottom_time);
	}

	if (fChanged & PLAYER_AMMO1) {
 		WriteByte(MSG_ENTITY, usp45_mag);
 		WriteByte(MSG_ENTITY, glock18_mag);
 		WriteByte(MSG_ENTITY, deagle_mag);
 		WriteByte(MSG_ENTITY, p228_mag);
 		WriteByte(MSG_ENTITY, elites_mag);
 		WriteByte(MSG_ENTITY, fiveseven_mag);
 		WriteByte(MSG_ENTITY, m3_mag);
 		WriteByte(MSG_ENTITY, xm1014_mag);
 		WriteByte(MSG_ENTITY, mp5_mag);
 		WriteByte(MSG_ENTITY, p90_mag);
 		WriteByte(MSG_ENTITY, ump45_mag);
 		WriteByte(MSG_ENTITY, mac10_mag);
 		WriteByte(MSG_ENTITY, tmp_mag);
 		WriteByte(MSG_ENTITY, ak47_mag);
 		WriteByte(MSG_ENTITY, sg552_mag);
 		WriteByte(MSG_ENTITY, m4a1_mag);
 		WriteByte(MSG_ENTITY, aug_mag);
 		WriteByte(MSG_ENTITY, scout_mag);
 		WriteByte(MSG_ENTITY, awp_mag);
 		WriteByte(MSG_ENTITY, g3sg1_mag);
 		WriteByte(MSG_ENTITY, sg550_mag);
 		WriteByte(MSG_ENTITY, para_mag);
	}

	if (fChanged & PLAYER_AMMO2) {
 		WriteByte(MSG_ENTITY, ammo_50ae);
 		WriteByte(MSG_ENTITY, ammo_762mm);
 		WriteByte(MSG_ENTITY, ammo_556mm);
 		WriteByte(MSG_ENTITY, ammo_556mmbox);
 		WriteByte(MSG_ENTITY, ammo_338mag);
 		WriteByte(MSG_ENTITY, ammo_9mm);
 		WriteByte(MSG_ENTITY, ammo_buckshot);
 		WriteByte(MSG_ENTITY, ammo_45acp);
 		WriteByte(MSG_ENTITY, ammo_357sig);
 		WriteByte(MSG_ENTITY, ammo_57mm);
 		WriteByte(MSG_ENTITY, ammo_hegrenade);
 		WriteByte(MSG_ENTITY, ammo_fbgrenade);
 		WriteByte(MSG_ENTITY, ammo_smokegrenade);
	}

	if (fChanged & PLAYER_AMMO3) {
 		WriteByte(MSG_ENTITY, mode_usp45);
 		WriteByte(MSG_ENTITY, mode_m4a1);
 		WriteByte(MSG_ENTITY, mode_glock18);
 		WriteByte(MSG_ENTITY, mode_temp);
	}

	if (fChanged & PLAYER_CSSHOT) {
		WriteByte(MSG_ENTITY, cs_shotmultiplier);
	}
	if (fChanged & PLAYER_CSSHOTTIME) {
		WriteFloat(MSG_ENTITY, cs_shottime);
	}

	return TRUE;
}
#endif
