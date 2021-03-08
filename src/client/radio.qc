/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

string g_cstrikeRadioWAVs[43] = {
	"radio/blow.wav",
	"radio/bombdef.wav",
	"radio/bombpl.wav",
	"radio/circleback.wav",
	"radio/clear.wav",
	"radio/com_followcom.wav",
	"radio/com_getinpos.wav",
	"radio/com_go.wav",
	"radio/com_reportin.wav",
	"radio/ct_affirm.wav",
	"radio/ct_backup.wav",
	"radio/ct_coverme.wav",
	"radio/ct_enemys.wav",
	"radio/ct_fireinhole.wav",
	"radio/ct_imhit.wav",
	"radio/ct_inpos.wav",
	"radio/ct_point.wav",
	"radio/ct_reportingin.wav",
	"radio/ctwin.wav",
	"radio/enemydown.wav",
	"radio/fallback.wav",
	"radio/fireassis.wav",
	"radio/followme.wav",
	"radio/getout.wav",
	"radio/go.wav",
	"radio/hitassist.wav",
	"radio/hosdown.wav",
	"radio/letsgo.wav",
	"radio/locknload.wav",
	"radio/matedown.wav",
	"radio/meetme.wav",
	"radio/moveout.wav",
	"radio/negative.wav",
	"radio/position.wav",
	"radio/regroup.wav",
	"radio/rescued.wav",
	"radio/roger.wav",
	"radio/rounddraw.wav",
	"radio/sticktog.wav",
	"radio/stormfront.wav",
	"radio/takepoint.wav",
	"radio/terwin.wav",
	"radio/vip.wav"
};

string g_cstrikeRadioChat[43] = {
	_("RADIO_BLOW"),
	_("RADIO_BOMBDEF"),
	_("RADIO_BOMBPL"),
	_("RADIO_CIRCLEBACK"),
	_("RADIO_CLEAR"),
	_("RADIO_COM_FOLLOWCOM"),
	_("RADIO_COM_GETINPOS"),
	_("RADIO_COM_GO"),
	_("RADIO_COM_REPORTIN"),
	_("RADIO_CT_AFFIRM"),
	_("RADIO_CT_BACKUP"),
	_("RADIO_CT_COVERME"),
	_("RADIO_CT_ENEMYS"),
	_("RADIO_CT_FIREINHOLE"),
	_("RADIO_CT_IMHIT"),
	_("RADIO_CT_INPOS"),
	_("RADIO_CT_POINT"),
	_("RADIO_CT_REPORTINGIN"),
	_("RADIO_CTWIN"),
	_("RADIO_ENEMYDOWN"),
	_("RADIO_FALLBACK"),
	_("RADIO_FIREASSIS"),
	_("RADIO_FOLLOWME"),
	_("RADIO_GETOUT"),
	_("RADIO_GO"),
	_("RADIO_HITASSIST"),
	_("RADIO_HOSDOWN"),
	_("RADIO_LETSGO"),
	_("RADIO_LOCKNLOAD"),
	_("RADIO_MATEDOWN"),
	_("RADIO_MEETME"),
	_("RADIO_MOVEOUT"),
	_("RADIO_NEGATIVE"),
	_("RADIO_POSITION"),
	_("RADIO_REGROUP"),
	_("RADIO_RESCUED"),
	_("RADIO_ROGER"),
	_("RADIO_ROUNDDRAW"),
	_("RADIO_STICKTOG"),
	_("RADIO_STORMFRONT"),
	_("RADIO_TAKEPOINT"),
	_("RADIO_TERWIN"),
	_("RADIO_VIP"),
};

void
Radio_Init(void)
{
	for (int i = 0; i < g_cstrikeRadioWAVs.length; i++)
		precache_sound(g_cstrikeRadioWAVs[i]);
}

/*
=================
Radio_PlayMessage

Play a radio message that doesn't come from a player
=================
*/
void
Radio_PlayMessage(float fMessage)
{
	sound(world, CHAN_VOICE, g_cstrikeRadioWAVs[fMessage], 1, ATTN_NONE, 0, SOUNDFLAG_NOSPACIALISE);

	if (fMessage == RADIO_CTWIN || fMessage == RADIO_TERWIN || fMessage == RADIO_ROUNDDRAW) {
		CSQC_Parse_CenterPrint(sprintf("%s", g_cstrikeRadioChat[fMessage]));
	} else {
		CSQC_Parse_Print(sprintf("^2[RADIO]^xF80: %s", g_cstrikeRadioChat[fMessage]), PRINT_CHAT);
	}
}

/*
=================
Radio_PlayPlayerMessage

This radio message does come from a player
=================
*/
void
Radio_PlayPlayerMessage(float fPlayerNum, float fMessage)
{
	sound(world, CHAN_VOICE, g_cstrikeRadioWAVs[fMessage], 1, ATTN_NONE, 0, SOUNDFLAG_NOSPACIALISE);
	CSQC_Parse_Print(sprintf("^2[RADIO] %s%s^xF80: %s", HUD_GetChatColorHEX(stof(getplayerkeyvalue(fPlayerNum, "*team"))), getplayerkeyvalue(fPlayerNum, "name"), g_cstrikeRadioChat[fMessage]), PRINT_CHAT);
}
