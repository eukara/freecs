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
	virtual void PlayerKill(NSClientPlayer);
	virtual void PlayerPreFrame(NSClientPlayer);
	virtual void PlayerDeath(NSClientPlayer);
	virtual void PlayerPain(NSClientPlayer);

/* level transitions */
	virtual void LevelChangeParms(NSClientPlayer);
	virtual void LevelDecodeParms(NSClientPlayer);
	virtual void LevelNewParms(void);

	virtual bool BuyingPossible(NSClientPlayer);
	virtual bool ShowHints(void);

	virtual bool ImpulseCommand(NSClient, float);
}; 

class CSSingleplayerRules:CSGameRules
{
	virtual string Title(void);

	/* client */
	virtual void PlayerSpawn(NSClientPlayer);
	virtual void PlayerDeath(NSClientPlayer);
};

class CSDeathmatchRules:CSGameRules
{
	int m_iIntermission;
	int m_iIntermissionTime;
	string m_strTeamList;

	void(void) CSDeathmatchRules;

	virtual string Title(void);
	virtual void(void) FrameStart;
	virtual void(void) CheckRules;
	virtual bool(void) MonstersSpawn;

	/* client */
	virtual void(NSClientPlayer) PlayerSpawn;
	virtual void(NSClientPlayer) PlayerDeath;
	virtual bool(NSClientPlayer, string) ConsoleCommand;
	virtual bool(void) IsMultiplayer;
	virtual bool(void) IsTeamplay;
	virtual void(void) InitPostEnts;
	virtual bool PlayerRequestRespawn(NSClientPlayer);
	virtual bool ShowHints(void);
};

class CSMultiplayerRules:CSGameRules
{
	entity m_eLastTSpawn;
	entity m_eLastCTSpawn;

	int m_iEscapedTerrorists;
	int m_iSwapTeamRoundCounter;

	void CSMultiplayerRules(void);

	virtual string Title(void);
	virtual void InitPostEnts(void);
	virtual void FrameStart(void);
	virtual void PlayerDisconnect(NSClientPlayer);
	virtual void PlayerSpawn(NSClientPlayer);
	virtual void PlayerPreFrame(NSClientPlayer);
	virtual void PlayerDeath(NSClientPlayer);
	virtual int MaxItemPerSlot(int);
	virtual bool ConsoleCommand(NSClientPlayer, string);

	/* CS specific */
	virtual void CreateRescueZones(void);
	virtual void CreateCTBuyzones(void);
	virtual void CreateTBuyzones(void);
	virtual void TimerBegin(float, int);
	virtual void TimerUpdate(void);

	virtual bool BuyingPossible(NSClientPlayer);
	virtual void RoundOver(int, int, int);
	virtual void RestartRound(int);
	virtual void DeathCheck(NSClientPlayer);
	virtual void MakeBomber(NSClientPlayer);
	virtual void MakeVIP(NSClientPlayer);
	virtual void CountPlayers(void);
	virtual void SwitchTeams(void);
	virtual void TimeOut(void);
	virtual bool IsTeamplay(void);

	virtual void PlayerClearWeaponry(NSClientPlayer);
	virtual void PlayerMakePlayable(NSClientPlayer, int);
	virtual void PlayerMakeSpectator(NSClientPlayer);
	virtual void PlayerRespawn(NSClientPlayer, int);
	virtual entity PlayerFindSpawn(float);
	virtual void PlayerReset(NSClientPlayer);

};

void CSEv_JoinAuto(void);

CSGameRules g_csMode;
