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
	PLAYER_BASEFRAME,
	PLAYER_FRAME,
	PLAYER_AMMO1,
	PLAYER_AMMO2,
	PLAYER_AMMO3,
	PLAYER_CSSHOT,
	PLAYER_CSSHOTTIME
};

enumflags
{
	AMMO1_USP45,
	AMMO1_GLOCK18,
	AMMO1_DEAGLE,
	AMMO1_P228,
	AMMO1_ELITES,
	AMMO1_FIVESEVEN,
	AMMO1_M3,
	AMMO1_XM1014,
	AMMO1_MP5,
	AMMO1_P90,
	AMMO1_UMP45,
	AMMO1_MAC10,
	AMMO1_TMP,
	AMMO1_AK47,
	AMMO1_SG552,
	AMMO1_M4A1,
	AMMO1_AUG,
	AMMO1_SCOUT,
	AMMO1_AWP,
	AMMO1_G3SG1,
	AMMO1_SG550,
	AMMO1_PARA,
};

enumflags
{
	AMMO2_50AE,
	AMMO2_762MM,
	AMMO2_556MM,
	AMMO2_556MMBOX,
	AMMO2_338MAG,
	AMMO2_9MM,
	AMMO2_BUCKSHOT,
	AMMO2_45ACP,
	AMMO2_357SIG,
	AMMO2_57MM,
	AMMO2_HEGRENADE,
	AMMO2_FBGRENADE,
	AMMO2_SMOKEGRENADE,
};

enumflags
{
	AMMO3_MODE_USP45,
	AMMO3_MODE_M4A1,
	AMMO3_MODE_GLOCK18,
};

noref int input_sequence;
class player:base_player
{
	int ingame;

	int ammo_50ae;
	int  ammo_50ae_net;
	int ammo_762mm;
	int  ammo_762mm_net;
	int ammo_556mm;
	int  ammo_556mm_net;
	int ammo_556mmbox;
	int  ammo_556mmbox_net;
	int ammo_338mag;
	int  ammo_338mag_net;
	int ammo_9mm;
	int  ammo_9mm_net;
	int ammo_buckshot;
	int  ammo_buckshot_net;
	int ammo_45acp;
	int  ammo_45acp_net;
	int ammo_357sig;
	int  ammo_357sig_net;
	int ammo_57mm;
	int  ammo_57mm_net;
	int ammo_hegrenade;
	int  ammo_hegrenade_net;
	int ammo_fbgrenade;
	int  ammo_fbgrenade_net;
	int ammo_smokegrenade;
	int  ammo_smokegrenade_net;

	/* Weapon specific */
	int usp45_mag;
	int usp45_mag_net;
	int glock18_mag;
	int glock18_mag_net;
	int deagle_mag;
	int deagle_mag_net;
	int p228_mag;
	int p228_mag_net;
	int elites_mag;
	int elites_mag_net;
	int fiveseven_mag;
	int fiveseven_mag_net;
	int m3_mag;
	int m3_mag_net;
	int xm1014_mag;
	int xm1014_mag_net;
	int mp5_mag;
	int mp5_mag_net;
	int p90_mag;
	int p90_mag_net;
	int ump45_mag;
	int ump45_mag_net;
	int mac10_mag;
	int mac10_mag_net;
	int tmp_mag;
	int tmp_mag_net;
	int ak47_mag;
	int ak47_mag_net;
	int sg552_mag;
	int sg552_mag_net;
	int m4a1_mag;
	int m4a1_mag_net;
	int aug_mag;
	int aug_mag_net;
	int scout_mag;
	int scout_mag_net;
	int awp_mag;
	int awp_mag_net;
	int g3sg1_mag;
	int g3sg1_mag_net;
	int sg550_mag;
	int sg550_mag_net;
	int para_mag;
	int para_mag_net;

	int mode_usp45;
	int mode_usp45_net;
	int mode_m4a1;
	int mode_m4a1_net;
	int mode_glock18;
	int mode_glock18_net;

	int mode_temp;
	int mode_temp_net;

	int cs_shotmultiplier;
	int cs_shotmultiplier_net;
	float cs_shottime;
	float cs_shottime_net;

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

	virtual void(void) gun_offset;
	virtual void(void) draw;
	virtual float() predraw;
	virtual void(void) postdraw;
	virtual void(float) ReceiveEntity;
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
player::ReceiveEntity(float new)
{
	float fl;
	if (new == FALSE) {
		/* Go through all the physics code between the last received frame
		 * and the newest frame and keep the changes this time around instead
		 * of rolling back, because we'll apply the new server-verified values
		 * right after anyway. */
		/* FIXME: splitscreen */
		if (entnum == player_localentnum) {
			/* FIXME: splitscreen */
			pSeat = &g_seats[0];

			for (int i = sequence+1; i <= servercommandframe; i++) {
				/* ...maybe the input state is too old? */
				if (!getinputstate(i)) {
					break;
				}
				input_sequence = i;
				PMove_Run();
			}

			/* any differences in things that are read below are now
			 * officially from prediction misses. */
		}
	}

	/* seed for our prediction table */
	sequence = servercommandframe;

	fl = readfloat();

	/* HACK: we need to make this more reliable */
	if (fl == UPDATE_ALL) {
		/* we respawned */
		gravity = __NULL__;
	}

	if (fl & PLAYER_MODELINDEX)
		modelindex = readshort();

	if (fl & PLAYER_ORIGIN) {
		origin[0] = readcoord();
		origin[1] = readcoord();
	}

	if (fl & PLAYER_ORIGIN_Z)
		origin[2] = readcoord();
	if (fl & PLAYER_ANGLES_X)
		pitch = readfloat();
	if (fl & PLAYER_ANGLES_Y)
		angles[1] = readfloat();
	if (fl & PLAYER_ANGLES_Z)
		angles[2] = readfloat();

	if (fl & PLAYER_VELOCITY) {
		velocity[0] = readcoord();
		velocity[1] = readcoord();
	}

	if (fl & PLAYER_VELOCITY_Z)
		velocity[2] = readcoord();
	if (fl & PLAYER_FLAGS) {
		flags = readfloat();
		gflags = readfloat();
	}
	if (fl & PLAYER_WEAPON)
		activeweapon = readbyte();
	if (fl & PLAYER_ITEMS)
		g_items = (__variant)readfloat();
	if (fl & PLAYER_HEALTH)
		health = readbyte();
	if (fl & PLAYER_ARMOR)
		armor = readbyte();
	if (fl & PLAYER_MOVETYPE)
		movetype = readbyte();
	if (fl & PLAYER_VIEWOFS)
		view_ofs[2] = readfloat();
	if (fl & PLAYER_BASEFRAME)
		baseframe = readbyte();
	if (fl & PLAYER_FRAME) {
		frame = readbyte();
		frame1time = 0.0f;
		frame2time = 0.0f;
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
	usp45_mag_net = usp45_mag;
	glock18_mag_net = glock18_mag;
	deagle_mag_net = deagle_mag;
	p228_mag_net = p228_mag;
	elites_mag_net = elites_mag;
	fiveseven_mag_net = fiveseven_mag;
	m3_mag_net = m3_mag;
	xm1014_mag_net = xm1014_mag;
	mp5_mag_net = mp5_mag;
	p90_mag_net = p90_mag;
	ump45_mag_net = ump45_mag;
	mac10_mag_net = mac10_mag;
	tmp_mag_net = tmp_mag;
	ak47_mag_net = ak47_mag;
	sg552_mag_net = sg552_mag;
	m4a1_mag_net = m4a1_mag;
	aug_mag_net = aug_mag;
	scout_mag_net = scout_mag;
	awp_mag_net = awp_mag;
	g3sg1_mag_net = g3sg1_mag;
	sg550_mag_net = sg550_mag;
	para_mag_net = para_mag;

	ammo_50ae_net = ammo_50ae;
	ammo_762mm_net = ammo_762mm;
	ammo_556mm_net = ammo_556mm;
	ammo_556mmbox_net = ammo_556mmbox;
	ammo_338mag_net = ammo_338mag;
	ammo_9mm_net = ammo_9mm;
	ammo_buckshot_net = ammo_buckshot;
	ammo_45acp_net = ammo_45acp;
	ammo_357sig_net = ammo_357sig;
	ammo_57mm_net = ammo_57mm;
	ammo_hegrenade_net = ammo_hegrenade;
	ammo_fbgrenade_net = ammo_fbgrenade;
	ammo_smokegrenade_net = ammo_smokegrenade;

	mode_usp45_net = mode_usp45;
	mode_m4a1_net = mode_m4a1;
	mode_glock18_net = mode_glock18;
	mode_temp_net = mode_temp;

	cs_shotmultiplier_net = cs_shotmultiplier;
	cs_shottime_net = cs_shottime;
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
	usp45_mag = usp45_mag_net;
	glock18_mag = glock18_mag_net;
	deagle_mag = deagle_mag_net;
	p228_mag = p228_mag_net;
	elites_mag = elites_mag_net;
	fiveseven_mag = fiveseven_mag_net;
	m3_mag = m3_mag_net;
	xm1014_mag = xm1014_mag_net;
	mp5_mag = mp5_mag_net;
	p90_mag = p90_mag_net;
	ump45_mag = ump45_mag_net;
	mac10_mag = mac10_mag_net;
	tmp_mag = tmp_mag_net;
	ak47_mag = ak47_mag_net;
	sg552_mag = sg552_mag_net;
	m4a1_mag = m4a1_mag_net;
	aug_mag = aug_mag_net;
	scout_mag = scout_mag_net;
	awp_mag = awp_mag_net;
	g3sg1_mag = g3sg1_mag_net;
	sg550_mag = sg550_mag_net;
	para_mag = para_mag_net;

	ammo_50ae = ammo_50ae_net;
	ammo_762mm = ammo_762mm_net;
	ammo_556mm = ammo_556mm_net;
	ammo_556mmbox = ammo_556mmbox_net;
	ammo_338mag = ammo_338mag_net;
	ammo_9mm = ammo_9mm_net;
	ammo_buckshot = ammo_buckshot_net;
	ammo_45acp = ammo_45acp_net;
	ammo_357sig = ammo_357sig_net;
	ammo_57mm = ammo_57mm_net;
	ammo_hegrenade = ammo_hegrenade_net;
	ammo_fbgrenade = ammo_fbgrenade_net;
	ammo_smokegrenade = ammo_smokegrenade_net;

	mode_usp45 = mode_usp45_net;
	mode_m4a1 = mode_m4a1_net;
	mode_glock18 = mode_glock18_net;
	mode_temp = mode_temp_net;

	cs_shotmultiplier = cs_shotmultiplier_net;
	cs_shottime = cs_shottime_net;
}

#else
void
player::EvaluateEntity(void)
{
	SendFlags |= PLAYER_KEEPALIVE;

	if (old_modelindex != modelindex)
		SendFlags |= PLAYER_MODELINDEX;

	if (old_origin[0] != origin[0])
		SendFlags |= PLAYER_ORIGIN;

	if (old_origin[1] != origin[1])
		SendFlags |= PLAYER_ORIGIN;

	if (old_origin[2] != origin[2])
		SendFlags |= PLAYER_ORIGIN_Z;

	if (old_angles[0] != v_angle[0])
		SendFlags |= PLAYER_ANGLES_X;

	if (old_angles[1] != angles[1])
		SendFlags |= PLAYER_ANGLES_Y;

	if (old_angles[2] != angles[2])
		SendFlags |= PLAYER_ANGLES_Z;

	if (old_velocity[0] != velocity[0])
		SendFlags |= PLAYER_VELOCITY;

	if (old_velocity[1] != velocity[1])
		SendFlags |= PLAYER_VELOCITY;

	if (old_velocity[2] != velocity[2])
		SendFlags |= PLAYER_VELOCITY_Z;

	if (old_flags != flags)
		SendFlags |= PLAYER_FLAGS;

	if (old_gflags != gflags)
		SendFlags |= PLAYER_FLAGS;

	if (old_activeweapon != activeweapon)
		SendFlags |= PLAYER_WEAPON;

	if (old_items != g_items)
		SendFlags |= PLAYER_ITEMS;

	if (old_health != health)
		SendFlags |= PLAYER_HEALTH;

	if (old_armor != armor)
		SendFlags |= PLAYER_ARMOR;

	if (old_movetype != movetype)
		SendFlags |= PLAYER_MOVETYPE;

	if (old_viewofs != view_ofs[2])
		SendFlags |= PLAYER_VIEWOFS;

	if (old_baseframe != baseframe)
		SendFlags |= PLAYER_BASEFRAME;

	if (old_frame != frame)
		SendFlags |= PLAYER_FRAME;

	/* ammo 1 type updates */
	if (glock18_mag_net != glock18_mag)
		SendFlags |= PLAYER_AMMO1;
	if (usp45_mag_net != usp45_mag)
		SendFlags |= PLAYER_AMMO1;
	if (glock18_mag_net != glock18_mag)
		SendFlags |= PLAYER_AMMO1;
	if (deagle_mag_net != deagle_mag)
		SendFlags |= PLAYER_AMMO1;
	if (p228_mag_net != p228_mag)
		SendFlags |= PLAYER_AMMO1;
	if (elites_mag_net != elites_mag)
		SendFlags |= PLAYER_AMMO1;
	if (fiveseven_mag_net != fiveseven_mag)
		SendFlags |= PLAYER_AMMO1;
	if (m3_mag_net != m3_mag)
		SendFlags |= PLAYER_AMMO1;
	if (xm1014_mag_net != xm1014_mag)
		SendFlags |= PLAYER_AMMO1;
	if (mp5_mag_net != mp5_mag)
		SendFlags |= PLAYER_AMMO1;
	if (p90_mag_net != p90_mag)
		SendFlags |= PLAYER_AMMO1;
	if (ump45_mag_net != ump45_mag)
		SendFlags |= PLAYER_AMMO1;
	if (mac10_mag_net != mac10_mag)
		SendFlags |= PLAYER_AMMO1;
	if (tmp_mag_net != tmp_mag)
		SendFlags |= PLAYER_AMMO1;
	if (ak47_mag_net != ak47_mag)
		SendFlags |= PLAYER_AMMO1;
	if (sg552_mag_net != sg552_mag)
		SendFlags |= PLAYER_AMMO1;
	if (m4a1_mag_net != m4a1_mag)
		SendFlags |= PLAYER_AMMO1;
	if (aug_mag_net != aug_mag)
		SendFlags |= PLAYER_AMMO1;
	if (scout_mag_net != scout_mag)
		SendFlags |= PLAYER_AMMO1;
	if (awp_mag_net != awp_mag)
		SendFlags |= PLAYER_AMMO1;
	if (g3sg1_mag_net != g3sg1_mag)
		SendFlags |= PLAYER_AMMO1;
	if (sg550_mag_net != sg550_mag)
		SendFlags |= PLAYER_AMMO1;
	if (para_mag_net != para_mag)
		SendFlags |= PLAYER_AMMO1;

	if (ammo_50ae_net != ammo_50ae)
		SendFlags |= PLAYER_AMMO2;
	if (ammo_762mm_net != ammo_762mm)
		SendFlags |= PLAYER_AMMO2;
	if (ammo_556mm_net != ammo_556mm)
		SendFlags |= PLAYER_AMMO2;
	if (ammo_556mmbox_net != ammo_556mmbox)
		SendFlags |= PLAYER_AMMO2;
	if (ammo_338mag_net != ammo_338mag)
		SendFlags |= PLAYER_AMMO2;
	if (ammo_9mm_net != ammo_9mm)
		SendFlags |= PLAYER_AMMO2;
	if (ammo_buckshot_net != ammo_buckshot)
		SendFlags |= PLAYER_AMMO2;
	if (ammo_45acp_net != ammo_45acp)
		SendFlags |= PLAYER_AMMO2;
	if (ammo_357sig_net != ammo_357sig)
		SendFlags |= PLAYER_AMMO2;
	if (ammo_57mm_net != ammo_57mm)
		SendFlags |= PLAYER_AMMO2;
	if (ammo_hegrenade_net != ammo_hegrenade)
		SendFlags |= PLAYER_AMMO2;
	if (ammo_fbgrenade_net != ammo_fbgrenade)
		SendFlags |= PLAYER_AMMO2;
	if (ammo_smokegrenade_net != ammo_smokegrenade)
		SendFlags |= PLAYER_AMMO2;

	if (mode_usp45_net != mode_usp45)
		SendFlags |= PLAYER_AMMO3;
	if (mode_m4a1_net != mode_m4a1)
		SendFlags |= PLAYER_AMMO3;
	if (mode_glock18_net != mode_glock18)
		SendFlags |= PLAYER_AMMO3;
	if (mode_temp_net != mode_temp)
		SendFlags |= PLAYER_AMMO3;
	if (cs_shotmultiplier != cs_shotmultiplier_net)
		SendFlags |= PLAYER_CSSHOT;
	if (cs_shottime != cs_shottime_net)
		SendFlags |= PLAYER_CSSHOTTIME;

	old_modelindex = modelindex;
	old_origin = origin;
	old_angles = angles;
	old_angles[0] = v_angle[0];
	old_velocity = velocity;
	old_flags = flags;
	old_gflags = gflags;
	old_activeweapon = activeweapon;
	old_items = g_items;
	old_health = health;
	old_armor = armor;
	old_movetype = movetype;
	old_viewofs = view_ofs[2];
	old_baseframe = baseframe;
	old_frame = frame;

	glock18_mag_net = glock18_mag;
	usp45_mag_net = usp45_mag;
	glock18_mag_net = glock18_mag;
	deagle_mag_net = deagle_mag;
	p228_mag_net = p228_mag;
	elites_mag_net = elites_mag;
	fiveseven_mag_net = fiveseven_mag;
	m3_mag_net = m3_mag;
	xm1014_mag_net = xm1014_mag;
	mp5_mag_net = mp5_mag;
	p90_mag_net = p90_mag;
	ump45_mag_net = ump45_mag;
	mac10_mag_net = mac10_mag;
	tmp_mag_net = tmp_mag;
	ak47_mag_net = ak47_mag;
	sg552_mag_net = sg552_mag;
	m4a1_mag_net = m4a1_mag;
	aug_mag_net = aug_mag;
	scout_mag_net = scout_mag;
	awp_mag_net = awp_mag;
	g3sg1_mag_net = g3sg1_mag;
	sg550_mag_net = sg550_mag;
	para_mag_net = para_mag;

	ammo_50ae_net = ammo_50ae;
	ammo_762mm_net = ammo_762mm;
	ammo_556mm_net = ammo_556mm;
	ammo_556mmbox_net = ammo_556mmbox;
	ammo_338mag_net = ammo_338mag;
	ammo_9mm_net = ammo_9mm;
	ammo_buckshot_net = ammo_buckshot;
	ammo_45acp_net = ammo_45acp;
	ammo_357sig_net = ammo_357sig;
	ammo_57mm_net = ammo_57mm;
	ammo_hegrenade_net = ammo_hegrenade;
	ammo_fbgrenade_net = ammo_fbgrenade;
	ammo_smokegrenade_net = ammo_smokegrenade;

	mode_usp45_net = mode_usp45;
	mode_m4a1_net = mode_m4a1;
	mode_glock18_net = mode_glock18;
	mode_temp_net = mode_temp;

	cs_shotmultiplier_net = cs_shotmultiplier;
	cs_shottime_net = cs_shottime;

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

	/* really trying to get our moneys worth with 23 bits of mantissa */
	if (fChanged & PLAYER_MODELINDEX)
		WriteShort(MSG_ENTITY, modelindex);
	if (fChanged & PLAYER_ORIGIN) {
		WriteCoord(MSG_ENTITY, origin[0]);
		WriteCoord(MSG_ENTITY, origin[1]);
	}
	if (fChanged & PLAYER_ORIGIN_Z)
		WriteCoord(MSG_ENTITY, origin[2]);
	if (fChanged & PLAYER_ANGLES_X)
		WriteFloat(MSG_ENTITY, v_angle[0]);
	if (fChanged & PLAYER_ANGLES_Y)
		WriteFloat(MSG_ENTITY, angles[1]);
	if (fChanged & PLAYER_ANGLES_Z)
		WriteFloat(MSG_ENTITY, angles[2]);
	if (fChanged & PLAYER_VELOCITY) {
		WriteCoord(MSG_ENTITY, velocity[0]);
		WriteCoord(MSG_ENTITY, velocity[1]);
	}
	if (fChanged & PLAYER_VELOCITY_Z)
		WriteCoord(MSG_ENTITY, velocity[2]);
	if (fChanged & PLAYER_FLAGS) {
		WriteFloat(MSG_ENTITY, flags);
		WriteFloat(MSG_ENTITY, gflags);
	}
	if (fChanged & PLAYER_WEAPON)
		WriteByte(MSG_ENTITY, activeweapon);
	if (fChanged & PLAYER_ITEMS)
		WriteFloat(MSG_ENTITY, (__variant)g_items);
	if (fChanged & PLAYER_HEALTH)
		WriteByte(MSG_ENTITY, bound(0, health, 255));
	if (fChanged & PLAYER_ARMOR)
		WriteByte(MSG_ENTITY, armor);
	if (fChanged & PLAYER_MOVETYPE)
		WriteByte(MSG_ENTITY, movetype);
	if (fChanged & PLAYER_VIEWOFS)
		WriteFloat(MSG_ENTITY, view_ofs[2]);
	if (fChanged & PLAYER_BASEFRAME)
		WriteByte(MSG_ENTITY, baseframe);
	if (fChanged & PLAYER_FRAME)
		WriteByte(MSG_ENTITY, frame);

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
