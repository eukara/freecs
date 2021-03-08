/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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

void
Money_AddMoney(base_player pp, int iMoneyValue)
{
	player pl = (player)pp;
	dprint(sprintf("^2Money_AddMoney^7: giving %s $%i\n", pl.netname, iMoneyValue));
	pl.money += (float)iMoneyValue;

	if (pl.money > autocvar_fcs_maxmoney) {
		pl.money = autocvar_fcs_maxmoney;
	}

	/* Because people do tend to kill hostages... */
	if (pl.money < 0) {
		pl.money = 0;
	}
}

void
Money_QueTeamReward(int t, int iMoneyValue)
{
	if (t == TEAM_T) {
		g_cs_moneyreward_t += iMoneyValue;
	} else {
		g_cs_moneyreward_ct += iMoneyValue;
	}
}

void
Money_GiveTeamReward(base_player pl)
{
	if (pl.team == TEAM_T) {
		Money_AddMoney(pl, g_cs_moneyreward_t);
	} else {
		Money_AddMoney(pl, g_cs_moneyreward_ct);
	}
}

void
Money_ResetTeamReward(void)
{
	g_cs_moneyreward_t = 0;
	g_cs_moneyreward_ct = 0;
}

int
Money_GetLosses(int team)
{
	if (team == TEAM_T) {
		return g_cs_roundslost_t;
	} else {
		return g_cs_roundslost_ct;
	}
}

int
Money_HasBonus(int team)
{
	if (team == TEAM_T) {
		return g_cs_bonus_t;
	} else {
		return g_cs_bonus_ct;
	}
}

void
Money_HandleRoundReward(int winner)
{
	int loser = -1;

	if (winner == TEAM_CT) {
		g_cs_winstreak_ct++;
		g_cs_winstreak_t = 0;
		g_cs_roundslost_t++;
		g_cs_roundslost_ct = 0;
		loser = TEAM_T;

		if (g_cs_winstreak_ct >= 2) {
			g_cs_bonus_ct = TRUE;
		}
	} else {
		g_cs_winstreak_t++;
		g_cs_winstreak_ct = 0;
		g_cs_roundslost_ct++;
		g_cs_roundslost_t = 0;
		loser = TEAM_CT;

		if (g_cs_winstreak_t >= 2) {
			g_cs_bonus_t = TRUE;
		}
	}

	/*  After the condition of a team winning two consecutive rounds is
	 *  satisfied then the loss bonus money changes to above where their
	 *  first loss means they receive $1500 and not $1400. */
	if (Money_HasBonus(loser)) {
		switch (Money_GetLosses(loser)) {
		case 1:
			Money_QueTeamReward(loser, 1500);
			break;
		case 2:
			Money_QueTeamReward(loser, 2000);
			break;
		case 3:
			Money_QueTeamReward(loser, 2500);
			break;
		default:
			Money_QueTeamReward(loser, 3000);
			break;
		}
	} else {
		switch (Money_GetLosses(loser)) {
		case 1:
			Money_QueTeamReward(loser, 1400);
			break;
		case 2:
			Money_QueTeamReward(loser, 1900);
			break;
		case 3:
			Money_QueTeamReward(loser, 2400);
			break;
		case 4:
			Money_QueTeamReward(loser, 2900);
			break;
		default:
			Money_QueTeamReward(loser, 3400);
			break;
		}
	}
}

void
Money_ResetRoundReward(void)
{
	g_cs_roundslost_ct =
	g_cs_roundslost_t =
	g_cs_winstreak_ct =
	g_cs_winstreak_t =
	g_cs_bonus_ct =
	g_cs_bonus_t = 0;
}
