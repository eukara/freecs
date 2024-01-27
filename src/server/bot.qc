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

/** @brief Get the absolute center pos of a entity */
vector getEntityCenterPos(entity e) {
	vector newVec;
	newVec[0] = e.absmin[0] + (0.5 * (e.absmax[0] - e.absmin[0]));
	newVec[1] = e.absmin[1] + (0.5 * (e.absmax[1] - e.absmin[1]));
	newVec[2] = e.absmin[2] + (0.5 * (e.absmax[2] - e.absmin[2]));
	return newVec;
}

class csbot:NSBot
{
	void(void) csbot;

	/* some objectives */
	virtual void(void) RunToConfront;
	virtual void(void) RunToBomb;
	virtual void(int)  RunToBombsite;
	virtual void(void) RunToRandomBombsite;
	virtual void(int)  RunToEscapeZone;
	virtual void(void) RunToRandomEscapeZone;
	virtual void(int)  RunToVIPSafetyZone;
	virtual void(void) RunToRandomVIPSafetyZone;
	virtual void(void) RunToHostages;
	virtual void(vector, int) Roam;

	virtual void(void) CreateObjective;
	virtual void(void) PostFrame;
	virtual void(void) WeaponThink;

	/* helpers */
	virtual entity(string, int) GetEntityByNameAndIndex;
	virtual entity(int) GetBombsiteByIndex;
	virtual entity(int) GetEscapeZoneByIndex;
	virtual entity(int) GetVIPSafetyZoneByIndex;
	virtual void(vector, float) AimLerp;

	int m_actionIsPlanting;
	int m_actionIsDefusing;

	/* Workaround:
	* gflags is not yet set when CSBot_BuyStart_Shop() or CreateObjective()
	* are called, so we back it up on PostFrame() and use that instead.
	* Known issues it solves:
	* - Check if the bot is in a Bomb Zone (gflags & GF_BOMBZONE)
	* - Check if the bot is in a Buy Zone (gflags & GF_BUYZONE) */
	int m_gflagsBackup;
};

void
csbot::RunToConfront(void)
{
	entity t;
	if (team == TEAM_T) {
		t = Route_SelectRandom("info_player_start");
	} else {
		t = Route_SelectRandom("info_player_deathmatch");
	}

	ChatSayTeam("Going to run to the Enemy Spawn!");

	if (t)
		RouteToPosition(t.origin);
}
/* go to the planted bomb */
void
csbot::RunToBomb(void)
{
	entity e = world;
	e = find(e, ::model, "models/w_c4.mdl");

	if (e) {
		RouteToPosition(e.origin);
		ChatSayTeam("Going to run to the Bomb!");
	}
}

/* go to given bombsite */
void
csbot::RunToBombsite(int bombsiteIndex)
{
	entity e = GetBombsiteByIndex(bombsiteIndex);
	RouteToPosition(getEntityCenterPos(e));
	ChatSayTeam(strcat("Going to run to Bomb Site ", itos(bombsiteIndex), "!"));
}

/* go to random bombsite */
void
csbot::RunToRandomBombsite(void)
{
	RunToBombsite(random(0, g_cs_bombzones));
}

/* go to given escape zone */
void
csbot::RunToEscapeZone(int index)
{
	entity e = GetEscapeZoneByIndex(index);
	RouteToPosition(getEntityCenterPos(e));
	ChatSayTeam(strcat("Going to run to Escape Zone ", itos(index), "!"));
}

/* go to a random escape zone */
void
csbot::RunToRandomEscapeZone(void)
{
	RunToEscapeZone(random(0, g_cs_escapezones));
}

/* go to given VIP Safety Zone */
void
csbot::RunToVIPSafetyZone(int index)
{
	entity e = GetVIPSafetyZoneByIndex(index);
	RouteToPosition(getEntityCenterPos(e));
	ChatSayTeam(strcat("Going to run to VIP Safety Zone ", itos(index), "!"));
}

/* go to a random VIP Safety Zone */
void
csbot::RunToRandomVIPSafetyZone(void)
{
	RunToVIPSafetyZone(random(0, g_cs_vipzones));
}

void
csbot::RunToHostages(void)
{
	entity e = world;

	e = find(e, ::classname, "hostage_entity");

	RouteToPosition(e.origin);
	ChatSayTeam("Going to run to the hostages!");
}

/** @brief Let the bot roam within a maximum distance from a given origin. */
void csbot::Roam(vector roamOrigin, int maxDistance) {
	/* Get random point whitin a radius from the given origin */
	int angle = random(0, 360); /* random angle. */
	int distance = random(0, maxDistance); /* random distance */
	float radian = angle * 3.145238095238 / 180;
	vector randLoc = roamOrigin;
	randLoc.x += sin(radian) * distance;
	randLoc.y += cos(radian) * distance;

	/* Find closest waypoint to our random location. */
	float flBestDist = COST_INFINITE;
	int iBestNodeIndex = -1;
	for (int i = 0; i < g_iNodes; i++) {
		float fDist = vlen(g_pNodes[i].origin - randLoc) - g_pNodes[i].radius;

		if (fDist > (float)maxDistance) {
			/* Distance is greater then our maxDistance */
			continue;
		}

		if (fDist < flBestDist) {
			flBestDist = fDist;
			iBestNodeIndex = i;
		}
	}

	if (iBestNodeIndex == -1) {
		/* TODO No waypoint in range found */
		print("WARNING!: Roaming failed, could not find waypoint in range.\n");
		return;
	}

	/* Go to the random waypoint. */
	RouteToPosition(g_pNodes[iBestNodeIndex].origin);
}

void
csbot::CreateObjective(void)
{
	/* Bomb defuse map */
	if (g_cs_bombzones > 0) {
		/* Bomb is planted */
		if (g_cs_bombplanted) {
			entity eBomb = find(world, ::model, "models/w_c4.mdl");
			if (eBomb == world) {
				/* No bomb model found, but it is/was planted */

				/* RoundOver: Bomb is defused */
				if (g_cs_gamestate == GAME_END) {
					RunToRandomBombsite();
					return;
				}

				/* Error */
				print("WARNING! g_cs_bombplanted == TRUE, but bomb model "
					  "cannot be found in the world.\n");
				return;
			}

			if (team == TEAM_CT) {
				if (g_cs_bombbeingdefused && m_actionIsDefusing == FALSE) {
					/* Bomb is being defused but not by this bot */
					/* Go and roam the defuser */
					Roam(eBomb.origin, 300);
					return;
				}

				if (m_actionIsDefusing) {
					if (!g_cs_bombbeingdefused) {
						/* Defusing complete or somehow failed. */
						m_actionIsDefusing = FALSE;
					} else {
						/* Continue defusing. */
						input_buttons |= (INPUT_BUTTON5 | INPUT_BUTTON8);
						input_movevalues = [0,0,0];
						button5 = input_buttons & INPUT_BUTTON5; // don't release button5
					}
				}
				else {
					int distToBomb = floor(vlen(eBomb.origin - origin));
					if (distToBomb > 60) {
						/* To far away from the bomb to defuse it, run to it! */
						RunToBomb();
					} else {
						/* Aim at the bomb. */
						input_buttons |= INPUT_BUTTON8; // duck
						if ((flags & FL_ONUSABLE)) {
							// Aimed at the bomb, ready to defuse!
							ChatSayTeam("Defusing!");
							input_buttons |= INPUT_BUTTON5;
							input_movevalues = [0,0,0];
							button5 = input_buttons & INPUT_BUTTON5; // don't release button5
							m_actionIsDefusing = TRUE;
						} else {
							// Do the real aiming
							float flLerp = bound(0.0f, frametime * 45, 1.0f);  // aim speed
							AimLerp(eBomb.origin + [0, 0, -6], flLerp);
						}
					}
				}
			}
			/* team == TEAM_T */
			else {
				/* Let T bots roam around the planted bomb */
				Roam(eBomb.origin, 500);
			}
			return;
		}
		/* Bomb is NOT planted */
		else {
			if (team == TEAM_T) {
				/* T-bot: plant bomb */
				if ((g_items & ITEM_C4BOMB)) {
					/* We carry the bomb */
					if (m_gflagsBackup & GF_BOMBZONE) {
						/* We are at a bombsite and ready to plant the bomb */
						if (activeweapon != WEAPON_C4BOMB) {
							activeweapon = WEAPON_C4BOMB;
							Weapons_Draw((player)self);
						}

						if (!m_actionIsPlanting) {
							ChatSayTeam("Going to plant the bomb!");
							m_actionIsPlanting = TRUE;
						}

						/* Workaround */
						gflags = m_gflagsBackup;

						/* Duck and plant bomb. */
						input_buttons = (INPUT_BUTTON0 | INPUT_BUTTON8);
						input_movevalues = [0,0,0];
					}
					else {
						/* Go to a bombsite first */
						RunToRandomBombsite();
					}
					return;
				}
				else {
					/* T-bot: check if the bomb has been dropped */
					entity e = find(world, ::model, "models/w_backpack.mdl");
					if (e != world) {
						/* The bomb backpack has been dropped */
						/* Go fetch dropped bomb! */
						ChatSayTeam("Arrr! Bomb on the ground, going to fetch it!");
						RouteToPosition(getEntityCenterPos(e));
						return;
					}
				}
			}
		}
	}

	if (g_cs_escapezones && team == TEAM_T) {
		RunToRandomEscapeZone();
		return;
	}

	if (random() < 0.5 && g_cs_escapezones > 0 && team == TEAM_CT) {
		RunToRandomEscapeZone();
		return;
	}

	if (g_cs_vipzones > 0 && team == TEAM_CT) {
		RunToRandomVIPSafetyZone();
		return;
	}

	if (random() < 0.5 && g_cs_vipzones > 0 && team == TEAM_T) {
		RunToRandomVIPSafetyZone();
		return;
	}

	if (random() < 0.5) {
		if (g_cs_hostagestotal > 0)
			RunToHostages();
		if (g_cs_bombzones > 0)
			RunToRandomBombsite();
	} else {
		RunToConfront();
	}
}

/** @brief Aim towards a given (vector)aimpos with a given (float)lerp speed.
 *
 * @note
 * Copied code from nuclide botlib (inside bot::RunAI), maybe make this a
 * method there, could be usefull for other stuff?
 **/
void csbot::AimLerp(vector aimpos, float flLerp) {
	vector aimdir, vecNewAngles;

	vector oldAngle = v_angle;

	/* that's the old angle */
	makevectors(v_angle);
	vecNewAngles = v_forward;

	/* aimdir = new final angle */
	aimdir = vectoangles(aimpos - origin);
	makevectors(aimdir);

	/* slowly lerp towards the final angle */
	vecNewAngles[0] = Math_Lerp(vecNewAngles[0], v_forward[0], flLerp);
	vecNewAngles[1] = Math_Lerp(vecNewAngles[1], v_forward[1], flLerp);
	vecNewAngles[2] = Math_Lerp(vecNewAngles[2], v_forward[2], flLerp);

	/* make sure we're aiming tight */
	v_angle = vectoangles(vecNewAngles);
	v_angle[0] = Math_FixDelta(v_angle[0]);
	v_angle[1] = Math_FixDelta(v_angle[1]);
	v_angle[2] = Math_FixDelta(v_angle[2]);
	angles[0] = Math_FixDelta(v_angle[0]);
	angles[1] = Math_FixDelta(v_angle[1]);
	angles[2] = Math_FixDelta(v_angle[2]);
	input_angles = v_angle;
}

void
csbot::PostFrame(void)
{
	if (team == 0) {
		CSEv_JoinAuto();
	}

	team = infokeyf(this, "*team");
	m_gflagsBackup = gflags;
};

void
csbot::WeaponThink(void)
{
	if (activeweapon == WEAPON_KNIFE)
		return;

	/* clip empty */
	if (a_ammo1 == 0) {
		/* still got ammo left, reload! */
		if (a_ammo2 != 0) {
			input_buttons &= ~INPUT_BUTTON0;
			input_buttons |= INPUT_BUTTON4;
		} else {
			Weapons_SwitchBest(this);
		}
	}
};

/** @brief Get entity by class name and index **/
entity
csbot::GetEntityByNameAndIndex(const string name, int index)
{
	int curIndex = 0;
	for (entity a = world; (a = find(a, ::classname, name));) {
		if (curIndex == index) {
			return a;
		}
		++curIndex;
	}
	print("WARNING: cstrike/server/bot.qc GetEntityByNameAndIndex: no entity '",
		  name, "' with index ", itos(index), "!\n");
	return world;
}

/** @brief Get bombsite entity by bombsite index
 *
 *  @note
 *  When there are for example 2 bombsites (g_cs_bombzones == 2) then valid
 *  indexes would be 0 and 1.
 * */
entity
csbot::GetBombsiteByIndex(int index)
{
	return GetEntityByNameAndIndex("func_bomb_target", index);
}

/** @brief Get Escape Zone entity by index **/
entity
csbot::GetEscapeZoneByIndex(int index)
{
	return GetEntityByNameAndIndex("func_escapezone", index);
}

/** @brief Get VIP Safety Zone entity by index **/
entity
csbot::GetVIPSafetyZoneByIndex(int index)
{
	return GetEntityByNameAndIndex("func_vip_safetyzone", index);
}

void
csbot::csbot(void)
{
	targetname = "_csbot_";
	team = infokeyf(this, "*team");
	m_actionIsPlanting = FALSE;
	m_actionIsDefusing = FALSE;
	m_gflagsBackup = 0;
}

void
CSBot_BombPlantedNotify(void)
{
	for (entity a = world; (a = find(a, classname, "player"));) {
		if (clienttype(a) != CLIENTTYPE_REAL) {
			csbot targ;
			targ = (csbot)a;

			if (targ.team == TEAM_T)
				continue;
			if (targ.health <= 0)
				continue;

			targ.RunToRandomBombsite();
		}
	}
}

void
CSBot_HostageRescueNotify(void)
{
	for (entity a = world; (a = find(a, classname, "player"));) {
		if (clienttype(a) != CLIENTTYPE_REAL) {
			csbot targ;
			targ = (csbot)a;

			if (targ.team == TEAM_T)
				continue;
			if (targ.health <= 0)
				continue;

			targ.RunToHostages();
		}
	}
}

void
CSBot_BuyStart_Shop(void)
{
	int done = 0;
	int count = 0;
	player pl = (player)self;

	pl.team = infokeyf(pl, "*team");

	/* Workaround */
	pl.gflags = ((csbot)pl).m_gflagsBackup;

	count = 0;
	while (done != 1) {
		int r = floor(random(1,17));

		if (pl.team == TEAM_T) {
			if (r == WEAPON_M4A1) { continue; }
			if (r == WEAPON_AUG) { continue; }
			if (r == WEAPON_SG550) { continue; }
			if (r == WEAPON_FIVESEVEN) { continue; }
			if (r == WEAPON_TMP) { continue; }
		} else if (pl.team == TEAM_CT) {
			if (r == WEAPON_AK47) { continue; }
			if (r == WEAPON_SG552) { continue; }
			if (r == WEAPON_G3SG1) { continue; }
			if (r == WEAPON_ELITES) { continue; }
			if (r == WEAPON_MAC10) { continue; }
		}

		if (g_cstrikeWeaponPrice[r] <= pl.money) {
			CSEv_BuyWeapon_f((float)r);
			done = 1;
		}
		count++;

		/* give it enough attempts */
		if (count > 17)
			done = 1;
	}

	/* CT: Random buy bomb defuse kit when enough money left */
	if (pl.team == TEAM_CT && g_cs_bombzones > 0 &&
		g_cstrikeUtilPrice[(float)5] <= pl.money &&
		random() < 0.5)
	{
		CSEv_BuyEquipment_f((float)5);  // ITEM_DEFUSAL
	}

	/* need armor */
	if (pl.armor < 100) {
		if (pl.money >= g_cstrikeUtilPrice[1]) /* kevlar and helmet */
			CSEv_BuyEquipment_f(1);
		else if (pl.money >= g_cstrikeUtilPrice[0]) /* just kevlar */
			CSEv_BuyEquipment_f(0);
	} else if (!(pl.g_items & ITEM_HELMET)) { /* we need helmet */
		if (pl.money >= 350) /* kevlar and helmet */
			CSEv_BuyEquipment_f(1);
	}

	/* make SURE we switch to it */
	for (int i = 0; i < g_weapons.length; i++)
		if (pl.g_items & g_weapons[i].id) {
			pl.activeweapon = i;
			Weapons_Draw(pl);
			return;
		}

	/* force buy right now */
	CSEv_AmmoBuyPrimary();
	CSEv_AmmoBuySecondary();
}

void
CSBot_BuyStart(void)
{
	for (entity a = world; (a = find(a, classname, "player"));) {
		if (clienttype(a) != CLIENTTYPE_REAL) {
			if (a.health <= 0)
				continue;

			a.think = CSBot_BuyStart_Shop;
			a.nextthink = time + random(0, autocvar_mp_freezetime);
		}
	}
}

void
CSBot_RoundStart(void)
{
	/* if (g_cs_bombzones <= 0) {
		return;
	}
		for (entity a = world; (a = find(a, classname, "player"));) {
			if (clienttype(a) != CLIENTTYPE_REAL) {
				csbot targ;
				targ = (csbot)a;

				if (targ.team == TEAM_T)
					continue;
				if (targ.health <= 0)
					continue;
				
				targ.RunToRandomBombsite();
			}
		}
	} */
}

void
CSBot_RestartRound(void)
{
	// Reset some variables for all bots
	for (entity a = world; (a = find(a, classname, "player"));) {
		if (clienttype(a) != CLIENTTYPE_REAL) {
			csbot targ;
			targ = (csbot)a;

			if (targ.team == TEAM_T) {
				targ.m_actionIsPlanting = FALSE;
			}
			else {
				targ.m_actionIsDefusing = FALSE;
			}
		}
	}
}
