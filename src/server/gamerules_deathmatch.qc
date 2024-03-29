/*
 * Copyright (c) 2016-2023 Marco Cawthorne <marco@icculus.org>
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

string
CSDeathmatchRules::Title(void)
{
	return "Deathmatch";
}

bool
CSDeathmatchRules::ShowHints(void)
{
	return (false);
}

bool
CSDeathmatchRules::IsMultiplayer(void)
{
	return (true);
}

bool
CSDeathmatchRules::PlayerRequestRespawn(NSClientPlayer bp)
{
	if (bp.TimeSinceDeath() > 0.5f) {
		bp.ScheduleThink(PutClientInServer, 0.0f);
		return (true);
	}

	return (false);
}

bool
CSDeathmatchRules::IsTeamplay(void)
{
	return cvar("mp_teamplay") == 1 ? true : false;
}

void
CSDeathmatchRules::InitPostEnts(void)
{
	MOTD_LoadDefault();
	
	forceinfokey(world, "scorepoints", "0");

	if (IsTeamplay() == true) {
		forceinfokey(world, "teams", "2");
		forceinfokey(world, "team_1", "Counter-Terrorist");
		forceinfokey(world, "teamscore_1", "0");
		forceinfokey(world, "team_2", "Terrorist");
		forceinfokey(world, "teamscore_2", "0");
	} else {
		forceinfokey(world, "teams", "0");
	}
}

void
CSDeathmatchRules::FrameStart(void)
{
	if (cvar("timelimit"))
	if (time >= (cvar("timelimit") * 60)) {
		IntermissionStart();
	}

	IntermissionCycle();
}

void
CSDeathmatchRules::CheckRules(void)
{
	/* last person who killed somebody has hit the limit */
	if (cvar("fraglimit"))
	if (g_dmg_eAttacker.frags >= cvar("fraglimit"))
		IntermissionStart();
}

void
CSDeathmatchRules::PlayerDeath(NSClientPlayer pl)
{
	/* obituary networking */
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_OBITUARY);
	WriteString(MSG_MULTICAST, (g_dmg_eAttacker.netname) ? g_dmg_eAttacker.netname : g_dmg_eAttacker.classname);
	WriteString(MSG_MULTICAST, pl.netname);
	WriteByte(MSG_MULTICAST, g_dmg_iWeapon);
	WriteByte(MSG_MULTICAST, 0);
	msg_entity = world;
	multicast([0,0,0], MULTICAST_ALL);

	Plugin_PlayerObituary(g_dmg_eAttacker, g_dmg_eTarget, g_dmg_iWeapon, g_dmg_iHitBody, g_dmg_iDamage);

	/* death-counter */
	pl.deaths++;
	pl.SetInfoKey("*deaths", ftos(pl.deaths));

	/* update score-counter */
	if (pl.flags & FL_CLIENT || pl.flags & FL_MONSTER)
	if (g_dmg_eAttacker.flags & FL_CLIENT) {
		if (pl == g_dmg_eAttacker)
			g_dmg_eAttacker.frags--;
		else
			g_dmg_eAttacker.frags++;
	}

#if 0
	/* explode all satchels */
	s_satchel_detonate((entity)pl);
	/* drop their posessions into a weaponbox item */
	weaponbox_spawn((player)pl);
#endif

	/* either gib, or make a corpse */
	if (pl.health < -50) {
		vector gibDir = vectoangles(pl.origin - g_dmg_eAttacker.origin);
		float gibStrength = g_dmg_iDamage * 2.0f;
		BreakModel_Entity(pl, gibDir, gibStrength);
	} else {
		FX_Corpse_Spawn((player)pl, ANIM_DEATH1);
		//FX_Corpse_Spawn((player)pl, ANIM_DIESIMPLE);
	}

	/* now let's make the real client invisible */
	pl.Death();
	pl.SetTakedamage(DAMAGE_NO);
	pl.gflags &= ~GF_FLASHLIGHT;

	Sound_Play(pl, CHAN_AUTO, "player.die");

	/* force respawn */
	pl.ScheduleThink(PutClientInServer, 4.0f);

	/* have we gone over the fraglimit? */
	CheckRules();
}

void
CSDeathmatchRules::PlayerSpawn(NSClientPlayer pp)
{
	player pl = (player)pp;
	/* this is where the mods want to deviate */
	entity spot;

	pl.classname = "player";
	pl.SetMaxHealth(100);
	pl.SetHealth(100);
	pl.SetArmor(100);
	pl.SetTakedamage(DAMAGE_YES);
	pl.SetSolid(SOLID_SLIDEBOX);
	pl.SetMovetype(MOVETYPE_WALK);
	pl.AddFlags(FL_CLIENT);
	pl.viewzoom = 1.0;

	/* player model selection */
	if (IsTeamplay() == true) {
		int teamCount = tokenizebyseparator(m_strTeamList, ";");
		int playerTeam = (int)pl.GetTeam();

		/* not part of a team? pick one of the ones we have */
		/* TODO: this should sort us into the lowest team */
		if (playerTeam == 0) {
			playerTeam = 1i + (int)floor(random(0, (float)teamCount)); /* teams start at 1 after all */
			pl.SetTeam(random() < 0.5 ? TEAM_CT : TEAM_T);
		}

		if (playerTeam == TEAM_T)
			pl.charmodel = floor(random(1,5));
		else
			pl.charmodel = floor(random(5,9));
	} else {
		pl.charmodel = rint(random(1,9));
	}

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
	pl.ClearVelocity();
	pl.gravity = __NULL__;
	pl.SetFrame(1);
	pl.SendFlags = UPDATE_ALL;
	pl.SetInfoKey("*spec", "0");
	pl.SetInfoKey("*dead", "0");
	pl.SetInfoKey("*deaths", ftos(pl.deaths));
	pl.SetPropData("actor_human");
	pl.SetCanBleed(true);

	LevelNewParms();
	LevelDecodeParms(pl);

	pl.g_items = ITEM_KNIFE | ITEM_SUIT;
	pl.activeweapon = WEAPON_KNIFE;

	int randomGun = (int)rint(random(WEAPON_USP45, WEAPON_FIVESEVEN));
	Weapons_AddItem(pl, randomGun, -1);
	randomGun = (int)rint(random(WEAPON_M3, WEAPON_PARA));
	Weapons_AddItem(pl, randomGun, -1);
	pl.activeweapon = randomGun;

	Ammo_BuyPrimary(pl, TRUE);
	Ammo_BuySecondary(pl, TRUE);

	spot = Spawn_SelectRandom("info_player_deathmatch");
	pl.Transport(spot.origin, spot.angles);
	Weapons_RefreshAmmo(pl);
	Client_FixAngle(pl, pl.angles);
}

bool
CSDeathmatchRules::ConsoleCommand(NSClientPlayer pp, string cmd)
{
	tokenize(cmd);

	switch (argv(0)) {
#if 0
	case "bot_add":
		bot pete = (bot)Bot_AddQuick();
		Bot_RandomColormap(pete);
		searchhandle pm = search_begin("models/player/*/*.mdl", TRUE, TRUE);
		int r = floor(random(0, search_getsize(pm)));
		string mdl = substring(search_getfilename(pm, r), 0, -5);
		tokenizebyseparator(mdl, "/");
		pete.SetInfoKey("model", argv(2));
		search_end(pm);
		break;
#endif
	case "jumptest":
		makevectors(pp.v_angle);
		traceline(pp.origin + pp.view_ofs, pp.origin + pp.view_ofs + v_forward * 1024, FALSE, pp);
		pp.velocity = Route_GetJumpVelocity(pp.origin, trace_endpos, pp.gravity);
		break;
	default:
		return (false);
	}

	return (true);
}

bool
CSDeathmatchRules::MonstersSpawn(void)
{
	return (autocvar(mp_allowmonsters, 0)) ? true : false;
}

void
CSDeathmatchRules::CSDeathmatchRules(void)
{
	/* these lines do nothing but tell the server to register those cvars */
	autocvar(timelimit, 15, "Timelimit for multiplayer rounds");
	autocvar(fraglimit, 15, "Points limit for multiplayer rounds");
}