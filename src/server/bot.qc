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

class csbot:bot
{
	void(void) csbot;

	/* some objectives */
	virtual void(void) RunToConfront;
	virtual void(void) RunToBomb;
	virtual void(void) RunToBombsite;
	virtual void(void) RunToEscapeZone;
	virtual void(void) RunToVIPSafetyZone;
	virtual void(void) RunToHostages;

	virtual void(void) CreateObjective;
	virtual void(void) PostFrame;
	virtual void(void) WeaponThink;

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
	e = find(e, ::model, "models/w_c4bomb.mdl");

	if (e) {
		RouteToPosition(e.origin);
		ChatSayTeam("Going to run to the Bomb!");
	}
}

/* go to a random bombsite */
void
csbot::RunToBombsite(void)
{
	entity e = world;
	vector vecTarget;

	/* FIXME: make this random and error checked */
	while (e == world)
		e = find(e, ::classname, "func_bomb_target");

	vecTarget[0] = e.absmin[0] + (0.5 * (e.absmax[0] - e.absmin[0]));
	vecTarget[1] = e.absmin[1] + (0.5 * (e.absmax[1] - e.absmin[1]));
	vecTarget[2] = e.absmin[2] + (0.5 * (e.absmax[2] - e.absmin[2]));

	RouteToPosition(vecTarget);
	ChatSayTeam("Going to run to a Bomb Site!");
}

/* go to a random escape zone */
void
csbot::RunToEscapeZone(void)
{
	entity e = world;
	vector vecTarget;

	/* FIXME: make this random and error checked */
	while (e == world)
		e = find(e, ::classname, "func_escapezone");

	vecTarget[0] = e.absmin[0] + (0.5 * (e.absmax[0] - e.absmin[0]));
	vecTarget[1] = e.absmin[1] + (0.5 * (e.absmax[1] - e.absmin[1]));
	vecTarget[2] = e.absmin[2] + (0.5 * (e.absmax[2] - e.absmin[2]));

	RouteToPosition(vecTarget);
	ChatSayTeam("Going to run to an Escape Zone!");
}

/* go to a random escape zone */
void
csbot::RunToVIPSafetyZone(void)
{
	entity e = world;
	vector vecTarget;

	/* FIXME: make this random and error checked */
	while (e == world)
		e = find(e, ::classname, "func_vip_safetyzone");

	vecTarget[0] = e.absmin[0] + (0.5 * (e.absmax[0] - e.absmin[0]));
	vecTarget[1] = e.absmin[1] + (0.5 * (e.absmax[1] - e.absmin[1]));
	vecTarget[2] = e.absmin[2] + (0.5 * (e.absmax[2] - e.absmin[2]));

	RouteToPosition(vecTarget);
	ChatSayTeam("Going to run to a VIP Safety Zone!");
}

void
csbot::RunToHostages(void)
{
	entity e = world;

	e = find(e, ::classname, "hostage_entity");

	RouteToPosition(e.origin);
	ChatSayTeam("Going to run to the hostages!");
}

void
csbot::CreateObjective(void)
{

	if (g_cs_bombzones > 0 && g_cs_bombplanted)
		RunToBombsite();

	if (g_cs_escapezones && team == TEAM_T) {
		RunToEscapeZone();
		return;
	}

	if (random() < 0.5 && g_cs_escapezones > 0 && team == TEAM_CT) {
		RunToEscapeZone();
		return;
	}


	if (g_cs_vipzones > 0 && team == TEAM_CT) {
		RunToVIPSafetyZone();
		return;
	}

	if (random() < 0.5 && g_cs_vipzones > 0 && team == TEAM_T) {
		RunToVIPSafetyZone();
		return;
	}


	if (random() < 0.5) {
		if (g_cs_hostagestotal > 0)
			RunToHostages();
		if (g_cs_bombzones > 0)
			RunToBombsite();
	} else {
		RunToConfront();
	}
}

void
csbot::PostFrame(void)
{
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

void
csbot::csbot(void)
{
	bot::bot();
	targetname = "_csbot_";
	team = infokeyf(this, "*team");
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
				
			targ.RunToBombsite();
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
				
				targ.RunToBombsite();
			}
		}
	} */
}
