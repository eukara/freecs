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

static string g_classDescrPhoenix;
static string g_classDescrLeet;
static string g_classDescrArctic;
static string g_classDescrGuerilla;
string g_classDescrAuto;

static void
CSClassT_Init(void)
{
	g_classDescrPhoenix = textfile_to_string("classes/terror.txt");
	g_classDescrLeet = textfile_to_string("classes/leet.txt");
	g_classDescrArctic = textfile_to_string("classes/arctic.txt");
	g_classDescrGuerilla = textfile_to_string("classes/guerilla.txt");

	if (g_classDescrAuto)
	g_classDescrAuto = textfile_to_string("classes/autoselect.txt");
}

static VGUIWindow winClassSelection;
static VGUIPic imgClassPreview;
static VGUILabel lblClassTitle;
static VGUILabel lblClassDescription;
static VGUILabel lblClassCounter;

class CSClassButtonT:VGUIButton
{
	void CSClassButtonT(void);

	virtual void OnMouseUp(void);
	virtual void OnMouseEntered(void);
};

void
CSClassButtonT::CSClassButtonT(void)
{
}

void
CSClassButtonT::OnMouseUp(void)
{
	int classSelection = GetTag();

	/* auto-select, aka random really */
	if (classSelection == 5)
		classSelection = floor(random(1, 5));

	sendevent("JoinTeam", "f", (float)classSelection);
	winClassSelection.Hide();
}

void
CSClassButtonT::OnMouseEntered(void)
{
	int classSelection = GetTag();

	switch (classSelection) {
		case 1:
			lblClassTitle.SetTitle(Titles_GetTextBody("Phoenix_Connexion"));
			imgClassPreview.SetImage("gfx/vgui/640_terror");
			lblClassDescription.SetTitle(g_classDescrPhoenix);
			break;
		case 2:
			lblClassTitle.SetTitle(Titles_GetTextBody("L337_Krew"));
			imgClassPreview.SetImage("gfx/vgui/640_leet");
			lblClassDescription.SetTitle(g_classDescrLeet);
			break;
		case 3:
			lblClassTitle.SetTitle(Titles_GetTextBody("Arctic_Avengers"));
			imgClassPreview.SetImage("gfx/vgui/640_arctic");
			lblClassDescription.SetTitle(g_classDescrArctic);
			break;
		case 4:
			lblClassTitle.SetTitle(Titles_GetTextBody("Guerilla_Warfare"));
			imgClassPreview.SetImage("gfx/vgui/640_guerilla");
			lblClassDescription.SetTitle(g_classDescrGuerilla);
			break;
		case 5:
			lblClassTitle.SetTitle(Titles_GetTextBody("Auto_Select"));
			imgClassPreview.SetImage("gfx/vgui/640_t_random");
			lblClassDescription.SetTitle(g_classDescrAuto);
			break;
	}
}

void
VGUI_ChooseClassT(void)
{
	static int initialized;
	static VGUILabel lblSelectClass;
	static VGUIFrame frmClassInfo;
	static CSClassButtonT btnPhoenix;
	static CSClassButtonT btnLeet;
	static CSClassButtonT btnArctic;
	static CSClassButtonT btnGuerilla;
	static CSClassButtonT btnAuto;

	if (!initialized) {
		vector btnpos = [40,80];
		initialized = TRUE;

		CSClassT_Init();

		winClassSelection = spawn(VGUIWindow);
		winClassSelection.SetSize([640, 480]);
		winClassSelection.SetStyleMask(VGUIWindowBorderless | VGUIWindowFullscreen);

		lblSelectClass = spawn(VGUILabel);
		lblSelectClass.SetTitle(Titles_GetTextBody("Title_terrorist_model_selection"));
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

		g_uiDesktop.Add(winClassSelection);
		winClassSelection.Add(lblSelectClass);
		winClassSelection.Add(frmClassInfo);
		winClassSelection.Add(imgClassPreview);
		winClassSelection.Add(lblClassTitle);
		winClassSelection.Add(lblClassCounter);
		winClassSelection.Add(lblClassDescription);

		btnPhoenix = spawn(CSClassButtonT);
			btnPhoenix.SetTitle(Titles_GetTextBody("Phoenix_Connexion"));
			btnPhoenix.SetSize([124, 24]);
			btnPhoenix.SetPos([40, 80]);
			btnPhoenix.SetTag(1);
			btnPhoenix.SetKeyEquivalent("1");
		btnLeet = spawn(CSClassButtonT);
			btnLeet.SetTitle(Titles_GetTextBody("L337_Krew"));
			btnLeet.SetSize([124, 24]);
			btnLeet.SetPos([40, 112]);
			btnLeet.SetTag(2);
			btnLeet.SetKeyEquivalent("2");
		btnArctic = spawn(CSClassButtonT);
			btnArctic.SetTitle(Titles_GetTextBody("Arctic_Avengers"));
			btnArctic.SetSize([124, 24]);
			btnArctic.SetPos([40, 144]);
			btnArctic.SetTag(3);
			btnArctic.SetKeyEquivalent("3");
		btnGuerilla = spawn(CSClassButtonT);
			btnGuerilla.SetTitle(Titles_GetTextBody("Guerilla_Warfare"));
			btnGuerilla.SetSize([124, 24]);
			btnGuerilla.SetPos([40, 176]);
			btnGuerilla.SetTag(4);
			btnGuerilla.SetKeyEquivalent("4");
		btnAuto = spawn(CSClassButtonT);
			btnAuto.SetTitle(Titles_GetTextBody("Auto_Select"));
			btnAuto.SetSize([124, 24]);
			btnAuto.SetPos([40, 240]);
			btnAuto.SetTag(5);
			btnAuto.SetKeyEquivalent("5");

		winClassSelection.Add(btnPhoenix);
		winClassSelection.Add(btnLeet);
		winClassSelection.Add(btnArctic);
		winClassSelection.Add(btnGuerilla);
		winClassSelection.Add(btnAuto);
	}

	winClassSelection.Show();
	winClassSelection.SetPos((video_res / 2) - (winClassSelection.GetSize() / 2));
}