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

int
CSMultiplayerRules::MaxItemPerSlot(int slot)
{
	/* grenades */
	if (slot == 3) {
		return 3;
	}
	return 1;
}

void
CSMultiplayerRules::PlayerDisconnect(base_player pl)
{
	if (health > 0)
		PlayerDeath(pl);
}

void
CSMultiplayerRules::PlayerDeath(base_player pl)
{
	/* obituary networking */
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_OBITUARY);
	if (g_dmg_eAttacker.netname)
		WriteString(MSG_MULTICAST, g_dmg_eAttacker.netname);
	else
		WriteString(MSG_MULTICAST, g_dmg_eAttacker.classname);
	WriteString(MSG_MULTICAST, pl.netname);
	WriteByte(MSG_MULTICAST, g_dmg_iWeapon);
	WriteByte(MSG_MULTICAST, 0);
	msg_entity = world;
	multicast([0,0,0], MULTICAST_ALL);

	/* death-counter */
	pl.deaths++;
	forceinfokey(pl, "*deaths", ftos(pl.deaths));

	/* update score-counter */
	if (g_dmg_eTarget.flags & FL_CLIENT || g_dmg_eTarget.flags & FL_MONSTER)
	if (g_dmg_eAttacker.flags & FL_CLIENT) {
		if (g_dmg_eTarget == g_dmg_eAttacker || g_dmg_eTarget.team == g_dmg_eAttacker.team)
			g_dmg_eAttacker.frags--;
		else
			g_dmg_eAttacker.frags++;
	}

	Weapon_DropCurrentWeapon(pl);

	/* if we're the bomb carrier, make sure we drop the bomb. */
	if (pl.g_items & ITEM_C4BOMB) {
		pl.activeweapon = WEAPON_C4BOMB;
		Weapon_DropCurrentWeapon(pl);
	}

	/* clear all ammo and inventory... */
	PlayerClearWeaponry(pl);

	pl.movetype = MOVETYPE_NONE;
	pl.solid = SOLID_NOT;
	pl.takedamage = DAMAGE_NO;
	pl.gflags &= ~GF_FLASHLIGHT;
	pl.armor = 0;
	pl.health = 0;

	entity corpse = spawn();
	setorigin(corpse, pl.origin + [0,0,32]);
	setmodel(corpse, pl.model);
	setsize(corpse, VEC_HULL_MIN, VEC_HULL_MAX);
	corpse.movetype = MOVETYPE_TOSS;
	corpse.solid = SOLID_TRIGGER;
	corpse.modelindex = pl.modelindex;
	corpse.frame = ANIM_DEATH1;
	corpse.angles = pl.angles;
	corpse.velocity = pl.velocity;
	corpse.classname = "remove_me";

	/* gamerule stuff */
	PlayerMakeSpectator(pl);
	pl.classname = "player";
	forceinfokey(pl, "*dead", "1"); 
	forceinfokey(pl, "*team", ftos(pl.team));
	CountPlayers();

	/* In Assassination, all Terrorists receive a $2500
	 *  reward if they won by killing the VIP. */
	if (self.team == TEAM_VIP) {
		RoundOver(TEAM_T, 2500, FALSE);
		return;
	}
	DeathCheck(pl);
}

void
CSMultiplayerRules::PlayerPreFrame(base_player pl)
{
	player pp = (player)pl;

	if (pl.health <= 0)
		return;

	if (g_cs_gamestate == GAME_FREEZE || pp.progress > 0.0f) {
		pl.flags |= FL_FROZEN;
	}
}

void
CSMultiplayerRules::FrameStart(void)
{
	if ((g_cs_alive_t + g_cs_alive_ct) == 0) {
		int iInGamePlayers = 0;
		for (entity eFind = world; (eFind = find(eFind, ::classname, "player"));) {
			iInGamePlayers++;
		}
		
		if ((iInGamePlayers > 0) && (g_cs_gamestate != GAME_COMMENCING && g_cs_gamestate != GAME_END)) {
			TimerBegin(2, GAME_COMMENCING);
		} else if (iInGamePlayers == 0) {
			g_cs_gamestate = GAME_INACTIVE;
			g_cs_gametime = 0;
			g_cs_roundswon_t = 0;
			g_cs_roundswon_ct = 0;
			g_cs_roundsplayed = 0;
		} else {
			TimerUpdate(); // Timer that happens once players have started joining
		}
	} else {
		TimerUpdate(); // Normal gameplay timer
	}
}

void
CSMultiplayerRules::CreateRescueZones(void)
{
	int zones = 0;

	/* not in hostage rescue mode */
	if (g_cs_hostagestotal <= 0) {
		return;
	}

	/* count the already existing rescue zones. */
	for (entity e = world; (e = find(e, ::classname, "func_hostage_rescue"));) {
		zones++;
	}

	/* we don't need to create any additional rescue zones. */
	if (zones > 0)
		return;

	/* since no buyzones are available, let's create one around every CT spawn */
	for (entity e = world; (e = find(e, ::classname, "info_player_start"));) {
		info_hostage_rescue newzone = spawn(info_hostage_rescue);
		setorigin(newzone, e.origin);
	}
}

void
CSMultiplayerRules::CreateCTBuyzones(void)
{
	int zones = 0;

	/* count the already existing CT zones. */
	for (entity e = world; (e = find(e, ::classname, "func_buyzone"));) {
		if (e.team == TEAM_CT) {
			zones++;
		}
	}

	/* we don't need to create any additional CT zones. */
	if (zones > 0)
		return;

	/* since no buyzones are available, let's create one around every CT spawn */
	for (entity e = world; (e = find(e, ::classname, "info_player_start"));) {
		info_buyzone newzone = spawn(info_buyzone);
		setorigin(newzone, e.origin);
		newzone.team = TEAM_CT;
	}
}

void
CSMultiplayerRules::CreateTBuyzones(void)
{
	int zones = 0;

	/* count the already existing T zones. */
	for (entity e = world; (e = find(e, ::classname, "func_buyzone"));) {
		if (e.team == TEAM_T) {
			zones++;
		}
	}

	/* we don't need to create any additional T zones. */
	if (zones > 0)
		return;

	/* since no buyzones are available, let's create one around every T spawn */
	for (entity e = world; (e = find(e, ::classname, "info_player_deathmatch"));) {
		info_buyzone newzone = spawn(info_buyzone);
		setorigin(newzone, e.origin);
		newzone.team = TEAM_T;
	}
}

void
CSMultiplayerRules::InitPostEnts(void)
{
	/* let's check if we need to create buyzones */
	switch (g_cstrike_buying) {
	case BUY_CT:
		CreateCTBuyzones();
		break;
	case BUY_T:
		CreateTBuyzones();
		break;
	case BUY_NEITHER:
		break;
	default:
		CreateCTBuyzones();
		CreateTBuyzones();
	}

	CreateRescueZones();
}

void
CSMultiplayerRules::TimerBegin(float tleft, int mode)
{
	if (mode == GAME_FREEZE) {
		g_cs_gamestate = GAME_FREEZE;
	} else if (mode == GAME_ACTIVE) {
		g_cs_gamestate = GAME_ACTIVE;
	} else if (mode == GAME_END) {
		g_cs_gamestate = GAME_END;
	} else if (mode == GAME_COMMENCING) {
		g_cs_gamestate = GAME_COMMENCING;
	} else if (mode == GAME_OVER) {
		g_cs_gamestate = GAME_OVER;
	}

	g_cs_gametime = tleft;
}

void
CSMultiplayerRules::TimerUpdate(void)
{
	if (cvar("sv_playerslots") == 1) {
		g_cs_gametime = -1;
		return;
	}

	if (g_cs_hostagestotal > 0) {
		if (g_cs_hostagesrescued >= g_cs_hostagestotal) {
			RoundOver(TEAM_CT, 0, FALSE);
			return;
		}
	}

	// This map has been played enough we think
	if (g_cs_gamestate != GAME_OVER) {
		if (cvar("mp_timelimit") > 0) {
			if (time >= (cvar("mp_timelimit") * 60)) {
				IntermissionStart();
				g_cs_gamestate = GAME_OVER;
			}
		}
	}

	// Okay, this means that timelimit is not the only deciding factor
	if (autocvar_mp_winlimit > 0 && g_cs_gamestate != GAME_OVER) {
		// It really doesn't matter who won. Do some logging perhaps?
		if (g_cs_roundswon_ct == autocvar_mp_winlimit) {
			IntermissionStart();
		} else if (g_cs_roundswon_t == autocvar_mp_winlimit) {
			IntermissionStart();
		}
	}

	if (g_cs_gamestate == GAME_INACTIVE) {
		return;
	}

	if (g_cs_gametime > 0) {
		g_cs_gametime -= frametime;
	} else {
		g_cs_gametime = 0;
	}

	if (g_cs_gamestate == GAME_COMMENCING || g_cs_gamestate == GAME_END) {
		if (g_cs_gametime <= 0) {
			if (g_cs_roundswon_t == 0 && g_cs_roundswon_ct == 0) {
				Money_ResetTeamReward();
				Money_ResetRoundReward();
				RestartRound(TRUE);
			} else {
				if (autocvar_mp_halftime == TRUE && (autocvar_mp_winlimit / 2 == g_cs_roundsplayed)) {
					Money_ResetTeamReward();
					SwitchTeams();
					RestartRound(TRUE);
				} else {
					RestartRound(FALSE);
				}
			}
		}
		return;
	}

	if ((g_cs_gamestate == GAME_ACTIVE) || (g_cs_gamestate == GAME_FREEZE)) {
		if (g_cs_gametime <= 0) {
			if (g_cs_gamestate == GAME_ACTIVE) {
				/* 1.5 will make the T's lose if time runs out no matter what */
				if (autocvar_fcs_fix_bombtimer == TRUE) {
					if (g_cs_bombzones > 0 && g_cs_bombplanted == TRUE) {
						return;
					}
				}
				TimeOut();
				TimerBegin(5, GAME_END); // Round is over, 5 seconds til a new round starts
			} else {
				TimerBegin(autocvar_mp_roundtime * 60, GAME_ACTIVE); // Unfreeze
				Radio_StartMessage();
			}
		}
	}
}

/*
=================
BuyingPossible

Checks if it is possible for players to buy anything
=================
*/
int
CSMultiplayerRules::BuyingPossible(base_player pl)
{
	if (pl.health <= 0) {
		return FALSE;
	}
	
	if (g_cs_gamestate == GAME_ACTIVE) {
		if (((autocvar_mp_roundtime * 60) - g_cs_gametime) > autocvar_mp_buytime) {
			centerprint(pl, sprintf("%d seconds have passed...\nYou can't buy anything now!", autocvar_mp_buytime));
			return FALSE;
		}
	}
	
	if (pl.team == TEAM_VIP) {
		centerprint(pl, "You are the VIP...\nYou can't buy anything!\n");
		return FALSE;
	}
	
	if (g_cstrike_buying == BUY_NEITHER) {
		centerprint(pl, "Sorry, you aren't meant\nto be buying anything.\n");
		return FALSE;
	}
	
	if (g_cstrike_buying != BUY_BOTH) {
		if (g_cstrike_buying == BUY_CT && pl.team == TEAM_T) {
			centerprint(pl, "Terrorists aren't allowed to\nbuy anything on this map!\n");
			return FALSE;
		} else if (g_cstrike_buying == BUY_T && pl.team == TEAM_CT) {
			centerprint(pl, "CTs aren't allowed to buy\nanything on this map!\n");
			return FALSE;
		}
	}
	
	if (!(pl.gflags & GF_BUYZONE)) {
		centerprint(pl, "Sorry, you aren't in a buyzone.\n");
		return FALSE;
	}
	
	return TRUE;
}

void
CSMultiplayerRules::MakeBomber(base_player pl)
{
	Weapons_AddItem(pl, WEAPON_C4BOMB, -1);
	centerprint(pl, "You have the bomb!\nFind the target zone or DROP\nthe bomb for another Terrorist.");
}

void
CSMultiplayerRules::MakeVIP(base_player pl)
{
	pl.team = TEAM_VIP;
	PlayerRespawn(pl, pl.team);
	centerprint(pl, "You are the VIP\nMake your way to the safety zones!");
	forceinfokey(pl, "*dead", "2");
}

/*
=================
RestartRound

Loop through all ents and handle them
=================
*/
void
CSMultiplayerRules::RestartRound(int iWipe)
{
	// Spawn/Respawn everyone at their team position and give them $$$
	for (entity eFind = world; (eFind = find(eFind, ::classname, "player"));) {
		player pl = (player)eFind;

		if (pl.health > 0 && iWipe == FALSE) {
			PlayerRespawn(pl, pl.team);
		} else {
			PlayerMakeSpectator(pl);
			PlayerMakePlayable(pl, pl.charmodel);
		}

		if (iWipe == FALSE) {
			Money_GiveTeamReward(pl);
		} else {
			pl.money = 0;
			Money_AddMoney(pl, autocvar_mp_startmoney);
		}
	}

	/* clear the corpses/items/bombs */
	for (entity eFind = world; (eFind = find(eFind, ::classname, "remove_me"));) {
		remove(eFind);
	}

	// Select a random Terrorist for the bomb, if needed
	if (g_cs_bombzones > 0) {
		int iRandomT = floor(random(1, (float)g_cs_alive_t + 1)); 
		int iPickT = 0;
		
		for (entity eFind = world; (eFind = find(eFind, ::classname, "player"));) { 
			if (eFind.team == TEAM_T) {
				iPickT++;
				
				if (iPickT == iRandomT) {
					MakeBomber((player)eFind);
				}
			}
		}
	} 

	// If there is a VIP, select a random CT to be it
	if (g_cs_vipzones > 0) {
		int iRandomCT = floor(random(1, (float)g_cs_alive_ct + 1));
		int iPickCT = 0;

		for (entity eFind = world; (eFind = find(eFind, ::classname, "player"));) { 
			if (eFind.team == TEAM_CT) {
				iPickCT++;
				if (iPickCT == iRandomCT) {
					MakeVIP((player)eFind);
				}
			}
		}
	}

	// Respawn all the entities
	for (entity a = world; (a = findfloat(a, ::identity, 1));) {
		CBaseEntity caw = (CBaseEntity)a;
		if (caw.classname != "player")
			caw.Respawn();
	}

	TimerBegin(autocvar_mp_freezetime, GAME_FREEZE);
	Money_ResetTeamReward();
}

/*
=================
RoundOver

This happens whenever an objective is complete or time is up
=================
*/
void
CSMultiplayerRules::RoundOver(int iTeamWon, int iMoneyReward, int fSilent)
{
	if (g_cs_gamestate != GAME_ACTIVE) {
		return;
	}

	if (iTeamWon == TEAM_T) {
		if (fSilent == FALSE) {
			Radio_BroadcastMessage(RADIO_TERWIN);
		}
		g_cs_roundswon_t++;
	} else if (iTeamWon == TEAM_CT) {
		if (fSilent == FALSE) {
			Radio_BroadcastMessage(RADIO_CTWIN);
		}
		g_cs_roundswon_ct++;

		/* In Bomb Defusal, if Terrorists were able to plant the bomb
		 * but lose the round, all Terrorists receive an $800 bonus. */
		if (g_cs_bombplanted) {
			Money_QueTeamReward(TEAM_T, 800);
		}
	} else {
		if (fSilent == FALSE) {
			Radio_BroadcastMessage(RADIO_ROUNDDRAW);
		}
	}

	Money_HandleRoundReward(iTeamWon);
	Money_QueTeamReward(iTeamWon, iMoneyReward);
	TimerBegin(5, GAME_END); // Round is over, 5 seconds til a new round starts

	g_cs_hostagesrescued = 0;
	g_cs_bombplanted = 0;
	g_cs_roundsplayed++;

	forceinfokey(world, "teamscore_1", sprintf("%i", g_cs_roundswon_t));
	forceinfokey(world, "teamscore_2", sprintf("%i", g_cs_roundswon_ct));
}

/*
=================
TimeOut

Whenever mp_roundtime was being counted down to 0
=================
*/
void
CSMultiplayerRules::TimeOut(void)
{
	if (g_cs_vipzones > 0) {
		RoundOver(TEAM_T, 3250, FALSE);
	} else if (g_cs_bombzones > 0) {
		/* In Bomb Defusal, all Counter-Terrorists receive $3250
		 *  if they won running down the time. */
		RoundOver(TEAM_CT, 3250, FALSE);
	} else if (g_cs_hostagestotal > 0) {
		// TODO: Broadcast_Print: Hostages have not been rescued!
		RoundOver(TEAM_T, 3250, FALSE);
	} else {
		RoundOver(0, 0, FALSE);
	}
}

/*
=================
SwitchTeams

Happens rarely
=================
*/
void
CSMultiplayerRules::SwitchTeams(void)
{
	int iCTW, iTW;

	for (entity eFind = world; (eFind = find(eFind, ::classname, "player"));) { 
		player pl = (player)eFind;
		if (pl.team == TEAM_CT) {
			pl.team = TEAM_T;
			pl.charmodel -= 4;
		} else if (pl.team == TEAM_T) {
			pl.team = TEAM_CT;
			pl.charmodel += 4;
		}
		forceinfokey(pl, "*team", ftos(pl.team));
	}

	iCTW = g_cs_roundswon_ct;
	iTW = g_cs_roundswon_t;

	g_cs_roundswon_t = iCTW;
	g_cs_roundswon_ct = iTW;

	iCTW = g_cs_alive_ct;
	iTW = g_cs_alive_t;

	g_cs_alive_ct = iTW;
	g_cs_alive_t = iCTW;

	forceinfokey(world, "teamscore_1", sprintf("%i", g_cs_roundswon_t));
	forceinfokey(world, "teamscore_2", sprintf("%i", g_cs_roundswon_ct));
}

void
CSMultiplayerRules::CountPlayers(void)
{
	g_cs_alive_t = 0;
	g_cs_alive_ct = 0;

	for (entity eFind = world; (eFind = find(eFind, ::classname, "player"));) {
		if (eFind.health > 0) {
			if (eFind.team == TEAM_T) {
				g_cs_alive_t++;
			} else if (eFind.team == TEAM_CT) {
				g_cs_alive_ct++;
			} else if (eFind.team == TEAM_VIP) {
				g_cs_alive_ct++;
			}
		}
	}
}

void
CSMultiplayerRules::DeathCheck(base_player pl)
{
	if ((g_cs_alive_t == 0) && (g_cs_alive_ct == 0)) {
		if (g_cs_bombplanted == TRUE) {
			RoundOver(TEAM_T, 3600, FALSE);
		} else {
			RoundOver(FALSE, 0, FALSE);
		}
	} else {
		int winner;
		if ((pl.team == TEAM_T) && (g_cs_alive_t == 0)) {
			winner = TEAM_CT;
		} else if ((pl.team == TEAM_CT) && (g_cs_alive_ct == 0)) {
			winner = TEAM_T;
		} else {
			return;
		}
		if (g_cs_bombzones > 0) {
			/* In Bomb Defusal, the winning team receives $3250
			 * if they won by eliminating the enemy team. */
			if (!g_cs_bombplanted || g_cs_alive_ct == 0) {
				RoundOver(winner, 3250, FALSE);
			}
		} else {
			/* In Hostage Rescue, the winning team receives $3600
			 * if they won by eliminating the enemy team. */
			RoundOver(winner, 3600, FALSE);
		}
	}
}

/*
=================
PlayerFindSpawn

Recursive function that gets the next spawnpoint
=================
*/
entity
CSMultiplayerRules::PlayerFindSpawn(float t)
{
	entity point = world;

	if (t == TEAM_T) {
		m_eLastTSpawn = find(m_eLastTSpawn, ::classname, "info_player_deathmatch");
		
		if (m_eLastTSpawn == world) {
			m_eLastTSpawn = find(m_eLastTSpawn, ::classname, "info_player_deathmatch");
		}
		point = m_eLastTSpawn;
	} else if (t == TEAM_CT) {
		m_eLastCTSpawn = find(m_eLastCTSpawn, ::classname, "info_player_start");
		
		if (m_eLastCTSpawn == world) {
			m_eLastCTSpawn = find(m_eLastCTSpawn, ::classname, "info_player_start");
		}
		point = m_eLastCTSpawn;
	} else if (t == TEAM_VIP) {
		point = find(world, ::classname, "info_vip_start");
	}

	if (point == world) {
		error("Error: No valid spawnpoints available.");
	}

	return point;
}

/*
=================
PlayerRespawn

Called whenever a player survived a round and needs a basic respawn.
=================
*/
void
CSMultiplayerRules::PlayerRespawn(base_player pp, int fTeam)
{
	player pl = (player)pp;

	entity eSpawn;
	forceinfokey(pl, "*spec", "0");
	eSpawn = PlayerFindSpawn(pl.team);

	pl.classname = "player";
	pl.health = pl.max_health = 100;
	forceinfokey(pl, "*dead", "0");
	CountPlayers();

	pl.takedamage = DAMAGE_YES;
	pl.solid = SOLID_SLIDEBOX;
	pl.movetype = MOVETYPE_WALK;
	pl.flags = FL_CLIENT;
	pl.iBleeds = TRUE;
	pl.viewzoom = 1.0;
	pl.g_items &= ~ITEM_C4BOMB;

	pl.SetOrigin(eSpawn.origin);
	pl.angles = eSpawn.angles;
	pl.SendFlags = UPDATE_ALL;
	Client_FixAngle(pl, pl.angles);

	switch (pl.charmodel) {
	case 1:
		pl.model = "models/player/terror/terror.mdl";
		break;
	case 2:
		pl.model = "models/player/leet/leet.mdl";
		break;
	case 3:
		pl.model = "models/player/arctic/arctic.mdl";
		break;
	case 4:
		pl.model = "models/player/guerilla/guerilla.mdl";
		break;
	case 5:
		pl.model = "models/player/urban/urban.mdl";
		break;
	case 6:
		pl.model = "models/player/gsg9/gsg9.mdl";
		break;
	case 7:
		pl.model = "models/player/sas/sas.mdl";
		break;
	case 8:
		pl.model = "models/player/gign/gign.mdl";
		break;
	default:
		pl.model = "models/player/vip/vip.mdl";
	}

	pl.SetModel(pl.model);
	pl.SetSize(VEC_HULL_MIN, VEC_HULL_MAX);

	pl.view_ofs = VEC_PLAYER_VIEWPOS;
	pl.velocity = [0,0,0];
	pl.progress = 0.0f;
	Weapons_SwitchBest(pl);

	/*Ammo_AutoFill(pl.fSlotPrimary);
	Ammo_AutoFill(pl.fSlotSecondary);*/
}

void
CSMultiplayerRules::PlayerClearWeaponry(base_player pp)
{
	player pl = (player)pp;

	pl.g_items = 0x0;
	pl.activeweapon = 0;
	pl.ammo_50ae = 0;
	pl.ammo_762mm = 0;
	pl.ammo_556mm = 0;
	pl.ammo_556mmbox = 0;
	pl.ammo_338mag = 0;
	pl.ammo_9mm = 0;
	pl.ammo_buckshot = 0;
	pl.ammo_45acp = 0;
	pl.ammo_357sig = 0;
	pl.ammo_57mm = 0;
	pl.ammo_hegrenade = 0;
	pl.ammo_fbgrenade = 0;
	pl.ammo_smokegrenade = 0;
	pl.usp45_mag = 0;
	pl.glock18_mag = 0;
	pl.deagle_mag = 0;
	pl.p228_mag = 0;
	pl.elites_mag = 0;
	pl.fiveseven_mag = 0;
	pl.m3_mag = 0;
	pl.xm1014_mag = 0;
	pl.mp5_mag = 0;
	pl.p90_mag = 0;
	pl.ump45_mag = 0;
	pl.mac10_mag = 0;
	pl.tmp_mag = 0;
	pl.ak47_mag = 0;
	pl.sg552_mag = 0;
	pl.m4a1_mag = 0;
	pl.aug_mag = 0;
	pl.scout_mag = 0;
	pl.awp_mag = 0;
	pl.g3sg1_mag = 0;
	pl.sg550_mag = 0;
	pl.para_mag = 0;
	pl.viewzoom = 1.0f;
}

/*
=================
PlayerMakePlayable

Called whenever need a full-reinit of a player.
This may be after a player had died or when the game starts for the first time.
=================
*/
void
CSMultiplayerRules::PlayerMakePlayable(base_player pp, int chara)
{
	player pl = (player)pp;
	/* spectator */
	if (chara == 0) {
		PlayerSpawn(pl);
		return;
	}

	pl.g_items |= ITEM_SUIT;
	Weapons_AddItem(pl, WEAPON_KNIFE, -1);

	/* terrorists */
	if (chara < 5) {
		pl.team = TEAM_T;
		if (autocvar_fcs_knifeonly == FALSE) {
			Weapons_AddItem(pl, WEAPON_GLOCK18, -1);
			pl.ammo_9mm = 40;
		}
	} else {
		pl.team = TEAM_CT;

		if (autocvar_fcs_knifeonly == FALSE) {
			Weapons_AddItem(pl, WEAPON_USP45, -1);
			pl.ammo_45acp = 24;
		}
	}

	pl.ingame = TRUE;
	forceinfokey(pl, "*team", ftos(pl.team)); 
	PlayerRespawn(pl, pl.team);
}

/*
=================
PlayerMakeSpectator

Force the player to become an observer.
=================
*/
void
CSMultiplayerRules::PlayerMakeSpectator(base_player pl)
{
	pl.classname = "spectator";
	pl.health = 0;
	pl.armor = 0;
	pl.takedamage = DAMAGE_NO;
	pl.solid = SOLID_NOT;
	pl.movetype = MOVETYPE_NOCLIP;
	pl.flags = FL_CLIENT;
	pl.weapon = 0;
	pl.viewzoom = 1.0f;
	pl.model = 0;
	setsize (pl, [-16,-16,-16], [16,16,16]);
	pl.view_ofs = pl.velocity = [0,0,0];
	forceinfokey(pl, "*spec", "2");

	/* clear the inventory */
	pl.items = 0x0;
	pl.activeweapon = 0;
}

/*
=================
PlayerSpawn

Called on the client first joining the server.
=================
*/
void
CSMultiplayerRules::PlayerSpawn(base_player pl)
{
	/* immediately put us into spectating mode */
	PlayerMakeSpectator(pl);
	Spawn_ObserverCam(pl);

	/* give the initial server-joining money */
	Money_AddMoney(pl, autocvar_mp_startmoney);

	/* we don't belong to any team */
	pl.team = 0;
	forceinfokey(pl, "*team", "0"); 
}

float
CSMultiplayerRules::ConsoleCommand(base_player pp, string cmd)
{
	tokenize(cmd);

	switch (argv(0)) {
	case "bot_add":
		entity bot_ent = Bot_AddQuick();
		if (bot_ent) {
			bot_ent.think = CSEv_JoinAuto;
			bot_ent.nextthink = time;
		}
		break;
	default:
		return FALSE;
	}

	return TRUE;
}

void
CSMultiplayerRules::CSMultiplayerRules(void)
{
	forceinfokey(world, "teams", "2");
	forceinfokey(world, "team_1", "Terrorist");
	forceinfokey(world, "teamscore_1", "0");
	forceinfokey(world, "team_2", "Counter-Terrorist");
	forceinfokey(world, "teamscore_2", "0");
}

/*
=================
CSEv_JoinTeam_f

Event Handling, called by the Client codebase via 'sendevent'
=================
*/
void CSEv_JoinTeam_f(float flChar)
{
	CSMultiplayerRules rules = (CSMultiplayerRules)g_grMode;
	player pl = (player)self;

	if (pl.team == TEAM_VIP) {
		centerprint(pl, "You are the VIP!\nYou cannot switch roles now.\n");
		return;
	}

	// alive and are trying to switch teams, so subtract us from the Alive_Team counter.
	if (pl.health > 0) {
		rules.PlayerKill(pl);
	}

	switch (g_cs_gamestate) {
	/* spawn the players immediately when its in the freeze state */
	case GAME_FREEZE:
		pl.charmodel = (int)flChar;
		rules.PlayerMakePlayable(pl, (int)flChar);

		if ((pl.team == TEAM_T) && (g_cs_alive_t == 1)) {
			if (g_cs_bombzones > 0) {
				rules.MakeBomber(pl);
			}
		} else if ((pl.team == TEAM_CT) && (g_cs_alive_ct == 1)) {
			if (g_cs_vipzones > 0) {
				rules.MakeVIP(pl);
			}
		}

		break;
	/* otherwise, just prepare their fields for the next round */
	default:
		if (flChar == 0) {
			rules.PlayerSpawn(pl);
			return;
		}

		if (flChar < 5) {
			pl.team = TEAM_T;
		} else {
			pl.team = TEAM_CT;
		}

		rules.PlayerMakeSpectator(pl);
		pl.classname = "player";
		pl.charmodel = (int)flChar;
		pl.health = 0;
		forceinfokey(pl, "*dead", "1");
		forceinfokey(pl, "*team", ftos(pl.team)); 
		break;
	}

	pl.frags = 0;
	pl.deaths = 0;
	forceinfokey(pl, "*deaths", ftos(pl.deaths));

	rules.CountPlayers();

	/* if no players are present in the chosen team, force restart round */
	if ((pl.team == TEAM_T) && (g_cs_alive_t == 0)) {
		rules.RoundOver(FALSE, 0, FALSE);
	} else if ((pl.team == TEAM_CT) && (g_cs_alive_ct == 0)) {
		rules.RoundOver(FALSE, 0, FALSE);
	}
}

void CSEv_JoinAuto(void)
{
	int ct_count = 0;
	int t_count = 1;

	for (entity eFind = world; (eFind = find(eFind, ::classname, "player"));) {
		player pl = (player)eFind;
		if (pl.team == TEAM_T) {
			t_count++;
		}
		if (pl.team == TEAM_CT) {
			ct_count++;
		}
	}

	if (ct_count >= t_count) {
		CSEv_JoinTeam_f(floor(random(1,5)));
	} else {
		CSEv_JoinTeam_f(floor(random(5,9)));
	}
}
