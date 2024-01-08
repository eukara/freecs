/*
 * Copyright (c) 2023 Marco Cawthorne <marco@icculus.org>
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

#define SPEC_SEP_COL [0.204,0.196,0.114]
#define SPEC_FG_COL [0.561,0.561,0.212]

class
CSSpectateHUD:VGUIWidget
{
	void CSSpectateHUD(void);

	virtual void Draw(void);
};
CSSpectateHUD g_specHUD;

void
CSSpectateHUD::CSSpectateHUD(void)
{

}

void
CSSpectateHUD::Draw(void)
{
	vector vecPos = g_vec_null;
	float flSep;
	string strText;
	int iMinutes, iSeconds;
	NSClientSpectator spec = (NSClientSpectator)pSeat->m_ePlayer;

	/* parts on top and bottom */
	drawfill(m_vecOrigin, [m_vecSize[0], 32], [0,0,0], 0.75f, DRAWFLAG_NORMAL);
	drawfill(m_vecOrigin + [0, m_vecSize[1]-32], [m_vecSize[0], 32], [0,0,0], 0.75f, DRAWFLAG_NORMAL);

	/* tracking player box */
	drawrect(g_hudmins + [(g_hudres[0] / 2) - 111, g_hudres[1]-26], [222,20], 1.0f, SPEC_SEP_COL, 1.0f, DRAWFLAG_NORMAL);
	strText = strcat(HUD_GetChatColorHEX(getplayerkeyfloat(spec.spec_ent - 1, "*team")), getplayerkeyvalue(spec.spec_ent - 1, "name"));
	vecPos[0] = g_hudmins[0] + (g_hudres[0] / 2) - (stringwidth(strText, TRUE, [12,12]) / 2);
	vecPos[1] = g_hudres[1]-21;
	drawstring(vecPos, strText, [12,12], [1,1,1], 1.0f, DRAWFLAG_NORMAL);

	/* tracking mode box */
	drawrect(g_hudmins + [(g_hudres[0] / 2) + 128, g_hudres[1]-26], [172,20], 1.0f, SPEC_SEP_COL, 1.0f, DRAWFLAG_NORMAL);
	strText = g_specmodes[spec.spec_mode];
	vecPos[0] = (g_hudmins[0] + (g_hudres[0] / 2) + 214) - (stringwidth(strText, TRUE, [12,12]) / 2);
	vecPos[1] = g_hudres[1]-21;
	drawstring(vecPos, strText, [12,12], SPEC_FG_COL, 1.0f, DRAWFLAG_NORMAL);

#if 0
	if (spec.spec_mode == SPECMODE_FIRSTPERSON) {
		entity oself = self;
		self = findfloat(world, ::entnum, spec.spec_ent);
		if (self)
			Cstrike_DrawCrosshair();
		self = oself;
	}
#endif

	/* money */
	strText = sprintf("$ %i", getstati(STAT_MONEY));
	flSep = stringwidth(strText, TRUE, [12,12]);

	if (flSep < 42)
		flSep = 42;

	flSep = g_hudmins[0] + (g_hudres[0] - flSep) - 10;

	vecPos[0] = flSep + 8;
	vecPos[1] = g_hudmins[1] + 3;
	drawstring(vecPos, strText, [12,12], SPEC_FG_COL, 1.0f, DRAWFLAG_NORMAL);

	/* score/money separator */
	drawfill([flSep,1], [4,30], SPEC_SEP_COL, 1.0f, DRAWFLAG_NORMAL);

	/* team scores */
	drawfont = Font_GetID(FONT_CON);
	strText = sprintf("Terrorist Forces: %s", serverkey("teamscore_1"));
	vecPos[0] = flSep - stringwidth(strText, TRUE, [12,12]) - 2;
	vecPos[1] = g_hudmins[1] + 3;
	drawstring(vecPos, strText, [12,12], SPEC_FG_COL, 1.0f, DRAWFLAG_NORMAL);

	strText = sprintf("CT Forces: %s", serverkey("teamscore_2"));
	vecPos[0] = flSep - stringwidth(strText, TRUE, [12,12]) - 2;
	vecPos[1] = g_hudmins[1] + 16;
	drawstring(vecPos, strText, [12,12], SPEC_FG_COL, 1.0f, DRAWFLAG_NORMAL);

	/* time display */
	drawpic([flSep + 8, 15], "gfx/vgui/640_timer", [14, 14], [1,1,1], 1.0f, DRAWFLAG_NORMAL);
	iMinutes = getstatf(STAT_GAMETIME) / 60;
	iSeconds = getstatf(STAT_GAMETIME) - 60 * iMinutes;
	strText = sprintf("%i:%02i", iMinutes, iSeconds);
	vecPos[0] = flSep + 8 + 17;
	vecPos[1] = g_hudmins[1] + 17;
	drawstring(vecPos, strText, [12,12], SPEC_FG_COL, 1.0f, DRAWFLAG_NORMAL);
}
