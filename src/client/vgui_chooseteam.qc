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

static CUIWindow winChooseTeam;
static CUIWindow winCTTeam;
static CUIWindow winTTeam;

void 
T_Skin1(void)
{
	sendevent("GamePlayerSpawn", "f", 1);
	winTTeam.Hide();
}
void 
T_Skin2(void)
{
	sendevent("GamePlayerSpawn", "f", 2);
	winTTeam.Hide();
}
void 
T_Skin3(void)
{
	sendevent("GamePlayerSpawn", "f", 3);
	winTTeam.Hide();
}
void 
T_Skin4(void)
{
	sendevent("GamePlayerSpawn", "f", 4);
	winTTeam.Hide();
}

void 
CT_Skin1(void)
{
	sendevent("GamePlayerSpawn", "f", 5);
	winCTTeam.Hide();
}
void 
CT_Skin2(void)
{
	sendevent("GamePlayerSpawn", "f", 6);
	winCTTeam.Hide();
}
void 
CT_Skin3(void)
{
	sendevent("GamePlayerSpawn", "f", 7);
	winCTTeam.Hide();
}
void 
CT_Skin4(void)
{
	sendevent("GamePlayerSpawn", "f", 8);
	winCTTeam.Hide();
}
void 
VGUI_GoSpectator(void)
{
	sendevent("GamePlayerSpawn", "f", 0);
	winChooseTeam.Hide();
}

void
VGUI_ChooseTeam_CT(void)
{
	static int initialized;
	static CUIButton btnSkin1;
	static CUIButton btnSkin2;
	static CUIButton btnSkin3;
	static CUIButton btnSkin4;

	if (!initialized) {
		initialized = TRUE;
		winCTTeam = spawn(CUIWindow);
		winCTTeam.SetTitle("Choose Skin");
		winCTTeam.SetSize([420,320]);

		btnSkin1 = spawn(CUIButton);
		btnSkin1.SetTitle("Skin 1");
		btnSkin1.SetPos([8,132]);
		btnSkin1.SetFunc(CT_Skin1);

		btnSkin2 = spawn(CUIButton);
		btnSkin2.SetTitle("Skin 2");
		btnSkin2.SetPos([8,132+30]);
		btnSkin2.SetFunc(CT_Skin2);

		btnSkin3 = spawn(CUIButton);
		btnSkin3.SetTitle("Skin 3");
		btnSkin3.SetPos([8,132+30+30]);
		btnSkin3.SetFunc(CT_Skin3);

		btnSkin4 = spawn(CUIButton);
		btnSkin4.SetTitle("Skin 4");
		btnSkin4.SetPos([8,132+30+30+30]);
		btnSkin4.SetFunc(CT_Skin4);

		g_uiDesktop.Add(winCTTeam);
		winCTTeam.Add(btnSkin1);
		winCTTeam.Add(btnSkin2);
		winCTTeam.Add(btnSkin3);
		winCTTeam.Add(btnSkin4);
	}

	winChooseTeam.Hide();
	winCTTeam.Show();
	winCTTeam.SetPos((video_res / 2) - (winCTTeam.GetSize() / 2));
}

void
VGUI_ChooseTeam_T(void)
{
	static int initialized;
	static CUIButton btnSkin1;
	static CUIButton btnSkin2;
	static CUIButton btnSkin3;
	static CUIButton btnSkin4;

	if (!initialized) {
		initialized = TRUE;
		winTTeam = spawn(CUIWindow);
		winTTeam.SetTitle("Choose Skin");
		winTTeam.SetSize([420,320]);

		btnSkin1 = spawn(CUIButton);
		btnSkin1.SetTitle("Skin 1");
		btnSkin1.SetPos([8,132]);
		btnSkin1.SetFunc(T_Skin1);

		btnSkin2 = spawn(CUIButton);
		btnSkin2.SetTitle("Skin 2");
		btnSkin2.SetPos([8,132+30]);
		btnSkin2.SetFunc(T_Skin2);

		btnSkin3 = spawn(CUIButton);
		btnSkin3.SetTitle("Skin 3");
		btnSkin3.SetPos([8,132+30+30]);
		btnSkin3.SetFunc(T_Skin3);

		btnSkin4 = spawn(CUIButton);
		btnSkin4.SetTitle("Skin 4");
		btnSkin4.SetPos([8,132+30+30+30]);
		btnSkin4.SetFunc(T_Skin4);

		g_uiDesktop.Add(winTTeam);
		winTTeam.Add(btnSkin1);
		winTTeam.Add(btnSkin2);
		winTTeam.Add(btnSkin3);
		winTTeam.Add(btnSkin4);
	}

	winChooseTeam.Hide();
	winTTeam.Show();
	winTTeam.SetPos((video_res / 2) - (winTTeam.GetSize() / 2));
}

void
VGUI_ChooseTeam(void)
{
	static int initialized;
	static CUIButton btnGoCT;
	static CUIButton btnGoT;
	static CUIButton btnGoSpectator;

	if (!initialized) {
		initialized = TRUE;
		winChooseTeam = spawn(CUIWindow);
		winChooseTeam.SetTitle("Choose Team");
		winChooseTeam.SetSize('420 320');

		btnGoCT = spawn(CUIButton);
		btnGoCT.SetTitle("Counter-Terrorists");
		btnGoCT.SetPos('8 132');
		btnGoCT.SetFunc(VGUI_ChooseTeam_CT);

		btnGoT = spawn(CUIButton);
		btnGoT.SetTitle("Terrorists");
		btnGoT.SetPos('8 162');
		btnGoT.SetFunc(VGUI_ChooseTeam_T);

		btnGoSpectator = spawn(CUIButton);
		btnGoSpectator.SetTitle("Spectator");
		btnGoSpectator.SetPos('8 192');
		btnGoSpectator.SetFunc(VGUI_GoSpectator);

		g_uiDesktop.Add(winChooseTeam);
		winChooseTeam.Add(btnGoCT);
		winChooseTeam.Add(btnGoT);
		winChooseTeam.Add(btnGoSpectator);
	}

	winChooseTeam.Show();
	winChooseTeam.SetPos((video_res / 2) - (winChooseTeam.GetSize() / 2));
}
