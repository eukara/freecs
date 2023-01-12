/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

class CSGameRules:CGameRules
{
	virtual void PlayerConnect(NSClientPlayer);
	virtual void PlayerDisconnect(NSClientPlayer);
	virtual void PlayerKill(NSClientPlayer);
	virtual void PlayerPostFrame(NSClientPlayer);
	virtual void PlayerDeath(NSClientPlayer);
	virtual void PlayerPain(NSClientPlayer);

/* level transitions */
	virtual void LevelChangeParms(NSClientPlayer);
	virtual void LevelDecodeParms(NSClientPlayer);
	virtual void LevelNewParms(void);

	virtual bool BuyingPossible(NSClientPlayer);

	virtual bool ImpulseCommand(NSClient, float);
}; 

class CSSingleplayerRules:CSGameRules
{
	/* client */
	virtual void(NSClientPlayer) PlayerSpawn;
	virtual void(NSClientPlayer) PlayerDeath;
};

class CSMultiplayerRules:CSGameRules
{
	entity m_eLastTSpawn;
	entity m_eLastCTSpawn;

	void() CSMultiplayerRules;

	virtual void(void) InitPostEnts;
	virtual void(void) FrameStart;
	virtual void(NSClientPlayer) PlayerDisconnect;
	virtual void(NSClientPlayer) PlayerSpawn;
	virtual void(NSClientPlayer) PlayerPreFrame;
	virtual void(NSClientPlayer) PlayerDeath;
	virtual int(int) MaxItemPerSlot;
	virtual bool(NSClientPlayer, string) ConsoleCommand;

	/* CS specific */
	virtual void(void) CreateRescueZones;
	virtual void(void) CreateCTBuyzones;
	virtual void(void) CreateTBuyzones;
	virtual void(float, int) TimerBegin;
	virtual void(void) TimerUpdate;

	virtual bool(NSClientPlayer) BuyingPossible;
	virtual void(int, int, int) RoundOver;
	virtual void(int) RestartRound;
	virtual void(NSClientPlayer) DeathCheck;
	virtual void(NSClientPlayer) MakeBomber;
	virtual void(NSClientPlayer) MakeVIP;
	virtual void(void) CountPlayers;
	virtual void(void) SwitchTeams;
	virtual void(void) TimeOut;
	virtual bool(void) IsTeamplay;

	virtual void(NSClientPlayer) PlayerClearWeaponry;
	virtual void(NSClientPlayer, int) PlayerMakePlayable;
	virtual void(NSClientPlayer) PlayerMakeSpectator;
	virtual void(NSClientPlayer, int) PlayerRespawn;
	virtual entity(float) PlayerFindSpawn;
};

void CSEv_JoinAuto(void);
