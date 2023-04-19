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

static VGUIWindow winBuyMenu;
static VGUILabel lblCategoryDescr;

class CSBuyMenuButton:VGUIButton
{
	void CSBuyMenuButton(void);

	virtual void OnMouseUp(void);
	virtual void OnMouseEntered(void);
};

void
CSBuyMenuButton::CSBuyMenuButton(void)
{
}

void
CSBuyMenuButton::OnMouseUp(void)
{
	int categorySelection = GetTag();

	switch (categorySelection) {
		case 1:
			VGUI_BuyMenu_Page(BUYPAGE_PISTOLS);
			break;
		case 2:
			VGUI_BuyMenu_Page(BUYPAGE_SHOTGUNS);
			break;
		case 3:
			VGUI_BuyMenu_Page(BUYPAGE_SMGS);
			break;
		case 4:
			VGUI_BuyMenu_Page(BUYPAGE_RIFLES);
			break;
		case 5:
			VGUI_BuyMenu_Page(BUYPAGE_MGS);
			break;
		case 6:
			sendevent("AmmoBuyPrimary", "");
			break;
		case 7:
			sendevent("AmmoBuySecondary", "");
			break;
		case 8:
			VGUI_BuyMenu_Page(BUYPAGE_EQUIPMENT);
			break;
	}

	winBuyMenu.Hide();
}

void
CSBuyMenuButton::OnMouseEntered(void)
{
	int categorySelection = GetTag();

	switch (categorySelection) {
		case 1:
			lblCategoryDescr.SetTitle(Titles_GetTextBody("Buy_pistols"));
			break;
		case 2:
			lblCategoryDescr.SetTitle(Titles_GetTextBody("Buy_shotguns"));
			break;
		case 3:
			lblCategoryDescr.SetTitle(Titles_GetTextBody("Buy_smgs"));
			break;
		case 4:
			lblCategoryDescr.SetTitle(Titles_GetTextBody("Buy_rifles"));
			break;
		case 5:
			lblCategoryDescr.SetTitle(Titles_GetTextBody("Buy_machineguns"));
			break;
		case 6:
			lblCategoryDescr.SetTitle(Titles_GetTextBody("Buy_prim_ammo"));
			break;
		case 7:
			lblCategoryDescr.SetTitle(Titles_GetTextBody("Buy_sec_ammo"));
			break;
		case 8:
			lblCategoryDescr.SetTitle(Titles_GetTextBody("Buy_equipment"));
			break;
	}
}

void
VGUI_BuyMenu(void)
{
	static int initialized;
	static CSBuyMenuButton btnPistols;
	static CSBuyMenuButton btnShotguns;
	static CSBuyMenuButton btnSMGs;
	static CSBuyMenuButton btnRifles;
	static CSBuyMenuButton btnMachineguns;
	static CSBuyMenuButton btnPrimAmmo;
	static CSBuyMenuButton btnSecAmmo;
	static CSBuyMenuButton btnEquipment;
	static VGUIButton btnCancel;
	static VGUILabel lblSelectTeam;
	static VGUIFrame frmBuyInfo;

	static void VGUI_BuyMenu_Cancel(void) {
		winBuyMenu.Hide();
	}

	if (!initialized) {
		vector btnpos = [40,80];

		initialized = TRUE;
		winBuyMenu = spawn(VGUIWindow);
		winBuyMenu.SetSize('640 480');
		winBuyMenu.SetStyleMask(VGUIWindowBorderless | VGUIWindowFullscreen);

		lblSelectTeam = spawn(VGUILabel);
		lblSelectTeam.SetTitle(Titles_GetTextBody("Title_select_category_of_purchase"));
		lblSelectTeam.SetTextSize(19);
		lblSelectTeam.SetPos([40, 38]);
		lblSelectTeam.SetSize('400 24');

		frmBuyInfo = spawn(VGUIFrame);
		frmBuyInfo.SetPos('176 80');
		frmBuyInfo.SetSize('200 100');

		lblCategoryDescr = spawn(VGUILabel);
		lblCategoryDescr.SetTitle("");
		lblCategoryDescr.SetPos('185 90');
		lblCategoryDescr.SetSize('375 250');

		btnPistols = spawn(CSBuyMenuButton);
		btnPistols.SetTitle(Titles_GetTextBody("Pistols"));
		btnPistols.SetPos('40 80');
		btnPistols.SetSize('124 24');
		btnPistols.SetKeyEquivalent("1");
		btnPistols.SetTag(1);

		btnShotguns = spawn(CSBuyMenuButton);
		btnShotguns.SetTitle(Titles_GetTextBody("Shotguns"));
		btnShotguns.SetPos('40 112');
		btnShotguns.SetSize('124 24');
		btnShotguns.SetKeyEquivalent("2");
		btnShotguns.SetTag(2);

		btnSMGs = spawn(CSBuyMenuButton);
		btnSMGs.SetTitle(Titles_GetTextBody("SMGs"));
		btnSMGs.SetPos('40 144');
		btnSMGs.SetSize('124 24');
		btnSMGs.SetKeyEquivalent("3");
		btnSMGs.SetTag(3);

		btnRifles = spawn(CSBuyMenuButton);
		btnRifles.SetTitle(Titles_GetTextBody("Rifles"));
		btnRifles.SetPos('40 175');
		btnRifles.SetSize('124 24');
		btnRifles.SetKeyEquivalent("4");
		btnRifles.SetTag(4);

		btnMachineguns = spawn(CSBuyMenuButton);
		btnMachineguns.SetTitle(Titles_GetTextBody("MachineGuns"));
		btnMachineguns.SetPos('40 208');
		btnMachineguns.SetSize('124 24');
		btnMachineguns.SetKeyEquivalent("5");
		btnMachineguns.SetTag(5);

		btnPrimAmmo = spawn(CSBuyMenuButton);
		btnPrimAmmo.SetTitle(Titles_GetTextBody("Prim_Ammo"));
		btnPrimAmmo.SetPos('40 240');
		btnPrimAmmo.SetSize('124 24');
		btnPrimAmmo.SetKeyEquivalent("6");
		btnPrimAmmo.SetTag(6);

		btnSecAmmo = spawn(CSBuyMenuButton);
		btnSecAmmo.SetTitle(Titles_GetTextBody("Sec_Ammo"));
		btnSecAmmo.SetPos('40 272');
		btnSecAmmo.SetSize('124 24');
		btnSecAmmo.SetKeyEquivalent("7");
		btnSecAmmo.SetTag(7);

		btnEquipment = spawn(CSBuyMenuButton);
		btnEquipment.SetTitle(Titles_GetTextBody("Equipment"));
		btnEquipment.SetPos('40 304');
		btnEquipment.SetSize('124 24');
		btnEquipment.SetTag(8);
		btnEquipment.SetKeyEquivalent("8");

		btnCancel = spawn(CSBuyMenuButton);
		btnCancel.SetTitle(Titles_GetTextBody("Menu_Cancel"));
		btnCancel.SetPos('40 368');
		btnCancel.SetSize('124 24');
		btnCancel.SetKeyEquivalent("0");
		btnCancel.SetFunc(VGUI_BuyMenu_Cancel);

		g_uiDesktop.Add(winBuyMenu);
		winBuyMenu.Add(lblSelectTeam);
		winBuyMenu.Add(frmBuyInfo);
		winBuyMenu.Add(lblCategoryDescr);
		winBuyMenu.Add(btnPistols);
		winBuyMenu.Add(btnShotguns);
		winBuyMenu.Add(btnSMGs);
		winBuyMenu.Add(btnRifles);
		winBuyMenu.Add(btnMachineguns);
		winBuyMenu.Add(btnPrimAmmo);
		winBuyMenu.Add(btnSecAmmo);
		winBuyMenu.Add(btnEquipment);
		winBuyMenu.Add(btnCancel);
	}

	winBuyMenu.Show();
	winBuyMenu.SetPos((video_res / 2) - (winBuyMenu.GetSize() / 2));
}
