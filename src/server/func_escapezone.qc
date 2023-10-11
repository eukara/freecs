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

/*!QUAKED func_escapezone (0 .5 .8) ?
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.

COUNTER-STRIKE (1999) ENTITY

Terrorist escape zone.

Used in the Escape mode (es_* maps).
*/

class
func_escapezone:NSBrushTrigger
{
	void func_escapezone(void);

	virtual void Respawn(void);
	virtual void Touch(entity);
};

void
func_escapezone::func_escapezone(void)
{
	g_cs_escapezones++;
}

void
func_escapezone::Respawn(void)
{
	InitBrushTrigger();
}


void
func_escapezone::Touch(entity eToucher)
{
	CSMultiplayerRules rule = (CSMultiplayerRules)g_grMode;
	int to_escape = 0;

	rule.CountPlayers();
	to_escape = g_cs_total_t;

	/* only 3 Ts need to escape, max */
	if (to_escape > 3)
		to_escape = 3;

	player pl = (player)eToucher;

	/* don't matter when rules are not active */
	if (g_cs_gamestate != GAME_ACTIVE)
		return;

	/* disallow the wrong players */
	if (pl.classname != "player")
		return;
	if (pl.team != TEAM_T)
		return;

	rule.m_iEscapedTerrorists++;

	/* balancing tweak: for every escaped T, each and every CT will lose funds */
	if (autocvar_fcs_escapepenalty != 0) {
		for (entity eFind = world; (eFind = find(eFind, ::classname, "player"));) { 
			player ct = (player)eFind;

			if (ct.team == TEAM_CT) {
				Money_AddMoney(ct, autocvar_fcs_escapepenalty);
			}
		}
	}

	/* mark player as spectator for the end of this 'round' */
	pl.MakeTempSpectator();
	pl.gflags &= ~GF_FLASHLIGHT;

	/* threshold has been met to trigger the end of the round */
	if (rule.m_iEscapedTerrorists >= to_escape) {
		/* reset */
		rule.m_iEscapedTerrorists = 0;

		/* Ts win the round */
		rule.RoundOver(TEAM_T, 3600, FALSE);
	}
}
