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

static string g_classDescrSeal;
static string g_classDescrGSG9;
static string g_classDescrSAS;
static string g_classDescrGIGN;

static void
CSClassCT_Init(void)
{
	g_classDescrSeal = textfile_to_string("classes/urban.txt");
	g_classDescrGSG9 = textfile_to_string("classes/gsg9.txt");
	g_classDescrSAS = textfile_to_string("classes/sas.txt");
	g_classDescrGIGN = textfile_to_string("classes/gign.txt");
}

static VGUIWindow winClassSelectionCT;
static VGUIPic imgClassPreview;
static VGUILabel lblClassTitle;
static VGUILabel lblClassDescription;
static VGUILabel lblClassCounter;

class CSClassButtonCT:VGUIButton
{
	void CSClassButtonCT(void);

	virtual void OnMouseUp(void);
	virtual void OnMouseEntered(void);
};

void
CSClassButtonCT::CSClassButtonCT(void)
{
}

void
CSClassButtonCT::OnMouseUp(void)
{
	int classSelection = GetTag();
	sendevent("JoinTeam", "f", (float)classSelection + 4);
	winClassSelectionCT.Hide();
}

void
CSClassButtonCT::OnMouseEntered(void)
{
	int classSelection = GetTag();

	switch (classSelection) {
		case 1:
			lblClassTitle.SetTitle(Titles_GetTextBody("Title_seal_team"));
			imgClassPreview.SetImage("gfx/vgui/640_urban");
			lblClassDescription.SetTitle(g_classDescrSeal);
			break;
		case 2:
			lblClassTitle.SetTitle(Titles_GetTextBody("Title_gsg9"));
			imgClassPreview.SetImage("gfx/vgui/640_gsg9");
			lblClassDescription.SetTitle(g_classDescrGSG9);
			break;
		case 3:
			lblClassTitle.SetTitle(Titles_GetTextBody("Title_sas"));
			imgClassPreview.SetImage("gfx/vgui/640_sas");
			lblClassDescription.SetTitle(g_classDescrSAS);
			break;
		case 4:
			lblClassTitle.SetTitle(Titles_GetTextBody("Title_gign"));
			imgClassPreview.SetImage("gfx/vgui/640_gign");
			lblClassDescription.SetTitle(g_classDescrGIGN);
			break;
	}
}

void
VGUI_ChooseClassCT(void)
{
	static int initialized;
	static VGUILabel lblSelectClass;
	static VGUIFrame frmClassInfo;
	static CSClassButtonCT btnSeal;
	static CSClassButtonCT btnGSG9;
	static CSClassButtonCT btnSAS;
	static CSClassButtonCT btnGIGN;

	if (!initialized) {
		vector btnpos = [40,80];
		initialized = TRUE;

		CSClassCT_Init();

		winClassSelectionCT = spawn(VGUIWindow);
		winClassSelectionCT.SetSize([640, 480]);
		winClassSelectionCT.SetStyleMask(VGUIWindowBorderless | VGUIWindowFullscreen);

		lblSelectClass = spawn(VGUILabel);
		lblSelectClass.SetTitle(Titles_GetTextBody("Title_ct_model_selection"));
		lblSelectClass.SetTextSize(19);
		lblSelectClass.SetPos([40, 38]);
		lblSelectClass.SetSize([400, 24]);

		frmClassInfo = spawn(VGUIFrame);
		frmClassInfo.SetPos([176, 80]);
		frmClassInfo.SetSize([424, 312]);

		imgClassPreview = spawn(VGUIPic);
		imgClassPreview.SetPos([190, 90]);

		lblClassTitle = spawn(VGUILabel);
		lblClassTitle.SetPos([338, 90]);
		lblClassTitle.SetTextSize(19);
		lblClassTitle.SetSize([320, 24]);

		lblClassCounter = spawn(VGUILabel);
		lblClassCounter.SetPos([338, 90 + 32]);
		lblClassCounter.SetSize([320, 18]);

		lblClassDescription = spawn(VGUILabel);
		lblClassDescription.SetPos([338, 90 + 32 + 32]);
		lblClassDescription.SetSize([250, 240]);

		g_uiDesktop.Add(winClassSelectionCT);
		winClassSelectionCT.Add(lblSelectClass);
		winClassSelectionCT.Add(frmClassInfo);
		winClassSelectionCT.Add(imgClassPreview);
		winClassSelectionCT.Add(lblClassTitle);
		winClassSelectionCT.Add(lblClassCounter);
		winClassSelectionCT.Add(lblClassDescription);

		btnSeal = spawn(CSClassButtonCT);
			btnSeal.SetTitle(Titles_GetTextBody("Seal_Team_6"));
			btnSeal.SetSize([124, 24]);
			btnSeal.SetPos([40, 80]);
			btnSeal.SetTag(1);
			btnSeal.SetKeyEquivalent("1");
		btnGSG9 = spawn(CSClassButtonCT);
			btnGSG9.SetTitle(Titles_GetTextBody("GSG_9"));
			btnGSG9.SetSize([124, 24]);
			btnGSG9.SetPos([40, 112]);
			btnGSG9.SetTag(2);
			btnGSG9.SetKeyEquivalent("2");
		btnSAS = spawn(CSClassButtonCT);
			btnSAS.SetTitle(Titles_GetTextBody("SAS"));
			btnSAS.SetSize([124, 24]);
			btnSAS.SetPos([40, 144]);
			btnSAS.SetTag(3);
			btnSAS.SetKeyEquivalent("3");
		btnGIGN = spawn(CSClassButtonCT);
			btnGIGN.SetTitle(Titles_GetTextBody("GIGN"));
			btnGIGN.SetSize([124, 24]);
			btnGIGN.SetPos([40, 176]);
			btnGIGN.SetTag(4);
			btnGIGN.SetKeyEquivalent("4");

		winClassSelectionCT.Add(btnSeal);
		winClassSelectionCT.Add(btnGSG9);
		winClassSelectionCT.Add(btnSAS);
		winClassSelectionCT.Add(btnGIGN);
	}

	winClassSelectionCT.Show();
	winClassSelectionCT.SetPos((video_res / 2) - (winClassSelectionCT.GetSize() / 2));
}