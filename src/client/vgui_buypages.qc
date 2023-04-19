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

static VGUIWindow winBuyMenuPage;
static VGUILabel lblBuyItemDescr;
static VGUILabel lblBuyItemTitle;
static VGUIPic imgBuyItemPic;

/* these id's are for the button tags only */
typedef enum
{
	BUYITEM_USP45,
	BUYITEM_GLOCK18,
	BUYITEM_DEAGLE,
	BUYITEM_P228,
	BUYITEM_ELITES,
	BUYITEM_FIVESEVEN,
	BUYITEM_M3,
	BUYITEM_XM1014,
	BUYITEM_AK47,
	BUYITEM_SG552,
	BUYITEM_M4A1,
	BUYITEM_AUG,
	BUYITEM_SCOUT,
	BUYITEM_AWP,
	BUYITEM_G3SG1,
	BUYITEM_SG550,
	BUYITEM_MP5,
	BUYITEM_TMP,
	BUYITEM_P90,
	BUYITEM_MAC10,
	BUYITEM_UMP45,
	BUYITEM_PARA,
	BUYITEM_KEVLAR,
	BUYITEM_HELMET,
	BUYITEM_FLASHBANG,
	BUYITEM_HENADE,
	BUYITEM_SMOKE,
	BUYITEM_DEFUSE,
	BUYITEM_NIGHTVISION
} buyItems_e;

typedef struct
{
	string eventCmd; /* the sendevent type for this buy command */
	float itemID; /* the id of the item */
	string descrPath; /* path to the description file */
	string imgPath; /* the path to the vgui image to use */
	string titleName; /* the name of the titles.txt entry */
} buyItems_t;

const buyItems_t g_buyItemList [29] = {
	{ "BuyWeapon", WEAPON_USP45, "classes/usp.txt", "gfx/vgui/640_usp", "USP45" },
	{ "BuyWeapon", WEAPON_GLOCK18, "classes/glock18.txt", "gfx/vgui/640_glock18", "Glock18" },
	{ "BuyWeapon", WEAPON_DEAGLE, "classes/deagle.txt", "gfx/vgui/640_deagle", "DesertEagle" },
	{ "BuyWeapon", WEAPON_P228, "classes/p228.txt", "gfx/vgui/640_p228", "P228" },
	{ "BuyWeapon", WEAPON_ELITES, "classes/elite.txt", "gfx/vgui/640_elite", "Beretta96G" },
	{ "BuyWeapon", WEAPON_FIVESEVEN, "classes/fiveseven.txt", "gfx/vgui/640_fiveseven", "FiveSeven" },
	{ "BuyWeapon", WEAPON_M3, "classes/m3.txt", "gfx/vgui/640_m3", "Super90" },
	{ "BuyWeapon", WEAPON_XM1014, "classes/xm1014.txt", "gfx/vgui/640_xm1014", "XM1014" },
	{ "BuyWeapon", WEAPON_AK47, "classes/ak47.txt", "gfx/vgui/640_ak47", "AK47" },
	{ "BuyWeapon", WEAPON_SG552, "classes/sg552.txt", "gfx/vgui/640_sg552", "SG552" },
	{ "BuyWeapon", WEAPON_M4A1, "classes/m4a1.txt", "gfx/vgui/640_m4a1", "M4A1" },
	{ "BuyWeapon", WEAPON_AUG, "classes/aug.txt", "gfx/vgui/640_aug", "Aug" },
	{ "BuyWeapon", WEAPON_SCOUT, "classes/scout.txt", "gfx/vgui/640_scout", "Scout" },
	{ "BuyWeapon", WEAPON_AWP, "classes/awp.txt", "gfx/vgui/640_awp", "ArcticWarfareMagnum" },
	{ "BuyWeapon", WEAPON_G3SG1, "classes/g3sg1.txt", "gfx/vgui/640_g3sg1", "G3SG1" },
	{ "BuyWeapon", WEAPON_SG550, "classes/sg550.txt", "gfx/vgui/640_sg550", "SG550" },
	{ "BuyWeapon", WEAPON_MP5, "classes/mp5.txt", "gfx/vgui/640_mp5", "mp5navy" },
	{ "BuyWeapon", WEAPON_TMP, "classes/tmp.txt", "gfx/vgui/640_tmp", "tmp" },
	{ "BuyWeapon", WEAPON_P90, "classes/p90.txt", "gfx/vgui/640_p90", "FNP90" },
	{ "BuyWeapon", WEAPON_MAC10, "classes/mac10.txt", "gfx/vgui/640_mac10", "Mac10" },
	{ "BuyWeapon", WEAPON_UMP45, "classes/ump45.txt", "gfx/vgui/640_ump45", "UMP45" },
	{ "BuyWeapon", WEAPON_PARA, "classes/m249.txt", "gfx/vgui/640_m249", "M249" },
	{ "BuyEquipment", 0, "classes/kevlar.txt", "", "Kevlar_Vest" },
	{ "BuyEquipment", 1, "classes/kevlar_helmet.txt", "", "Kevlar_Vest_Ballistic_Helmet" },
	{ "BuyEquipment", 2, "classes/flashbang.txt", "gfx/vgui/640_flashbang", "Flashbang" },
	{ "BuyEquipment", 3, "classes/hegrenade.txt", "gfx/vgui/640_hegrenade", "High_Explosive_Grenade" },
	{ "BuyEquipment", 4, "classes/smokegrenade.txt", "gfx/vgui/640_smokegrenade", "Smoke_Grenade" },
	{ "BuyEquipment", 5, "classes/defuse.txt", "", "Defusal_Kit" },
	{ "BuyEquipment", 6, "classes/nightvision.txt", "", "Nightvision_Goggles" },
};

string g_butItemDescr[29];

class CSBuyItemButton:VGUIButton
{
	void CSBuyItemButton(void);

	virtual void OnMouseUp(void);
	virtual void OnMouseEntered(void);
};

void
CSBuyItemButton::CSBuyItemButton(void)
{
}

void
CSBuyItemButton::OnMouseUp(void)
{
	int i = GetTag();

	/* this is where we buy things */
	sendevent(g_buyItemList[i].eventCmd, "f", g_buyItemList[i].itemID);
	winBuyMenuPage.Hide();
}

void
CSBuyItemButton::OnMouseEntered(void)
{
	int i = GetTag();
	lblBuyItemDescr.SetTitle(g_butItemDescr[i]);
	imgBuyItemPic.SetImage(g_buyItemList[i].imgPath);
	lblBuyItemTitle.SetTitle(Titles_GetTextBody(g_buyItemList[i].titleName));
}

enum
{
	BUYPAGE_PISTOLS,
	BUYPAGE_SHOTGUNS,
	BUYPAGE_SMGS,
	BUYPAGE_RIFLES,
	BUYPAGE_MGS,
	BUYPAGE_EQUIPMENT
};

void
VGUI_BuyMenu_Page(int buyPage)
{
	static int initialized;
	static VGUIButton btnCancel;
	static VGUIFrame frmBuyInfo;
	static VGUILabel lblBuyScreenTitle;

	static CSBuyItemButton btnBuyItem1;
	static CSBuyItemButton btnBuyItem2;
	static CSBuyItemButton btnBuyItem3;
	static CSBuyItemButton btnBuyItem4;
	static CSBuyItemButton btnBuyItem5;
	static CSBuyItemButton btnBuyItem6;
	static CSBuyItemButton btnBuyItem7;
	static CSBuyItemButton btnBuyItem8;
	static CSBuyItemButton btnBuyItem9;

	player pl = (player)pSeat->m_ePlayer;

	int inTeam = getplayerkeyfloat(pl.entnum-1, "*team");

	static void VGUI_BuyMenu_Pistols_Cancel(void) {
		winBuyMenuPage.Hide();
	}

	if (!initialized) {
		vector btnpos = [40,80];

		initialized = TRUE;
		winBuyMenuPage = spawn(VGUIWindow);
		winBuyMenuPage.SetSize([640,480]);
		winBuyMenuPage.SetStyleMask(VGUIWindowBorderless | VGUIWindowFullscreen);

		lblBuyScreenTitle = spawn(VGUILabel);
		lblBuyScreenTitle.SetTitle(Titles_GetTextBody("Title_select_category_of_purchase"));
		lblBuyScreenTitle.SetTextSize(19);
		lblBuyScreenTitle.SetPos([40, 38]);
		lblBuyScreenTitle.SetSize('400 24');

		frmBuyInfo = spawn(VGUIFrame);
		frmBuyInfo.SetPos('176 80');
		frmBuyInfo.SetSize('424 312');

		lblBuyItemDescr = spawn(VGUILabel);
		lblBuyItemDescr.SetTitle("");
		lblBuyItemDescr.SetPos('185 190');
		lblBuyItemDescr.SetSize('408 250');

		imgBuyItemPic = spawn(VGUIPic);
		imgBuyItemPic.SetPos([260, 130]);

		lblBuyItemTitle = spawn(VGUILabel);
		lblBuyItemTitle.SetPos([185, 96]);
		lblBuyItemTitle.SetTextSize(19);
		lblBuyItemTitle.SetSize([390, 24]);

		btnBuyItem1 = spawn(CSBuyItemButton);
		btnBuyItem1.SetPos('40 80');
		btnBuyItem1.SetSize('124 24');
		btnBuyItem1.SetKeyEquivalent("1");
		btnBuyItem1.SetTag(1);

		btnBuyItem2 = spawn(CSBuyItemButton);
		btnBuyItem2.SetPos('40 112');
		btnBuyItem2.SetSize('124 24');
		btnBuyItem2.SetKeyEquivalent("2");
		btnBuyItem2.SetTag(2);

		btnBuyItem3 = spawn(CSBuyItemButton);
		btnBuyItem3.SetPos('40 144');
		btnBuyItem3.SetSize('124 24');
		btnBuyItem3.SetKeyEquivalent("3");
		btnBuyItem3.SetTag(3);

		btnBuyItem4 = spawn(CSBuyItemButton);
		btnBuyItem4.SetPos('40 175');
		btnBuyItem4.SetSize('124 24');
		btnBuyItem4.SetKeyEquivalent("4");
		btnBuyItem4.SetTag(4);

		btnBuyItem5 = spawn(CSBuyItemButton);
		btnBuyItem5.SetPos('40 208');
		btnBuyItem5.SetSize('124 24');
		btnBuyItem5.SetKeyEquivalent("5");
		btnBuyItem5.SetTag(5);

		btnBuyItem6 = spawn(CSBuyItemButton);
		btnBuyItem6.SetPos('40 240');
		btnBuyItem6.SetSize('124 24');
		btnBuyItem6.SetKeyEquivalent("6");
		btnBuyItem6.SetTag(6);

		btnBuyItem7 = spawn(CSBuyItemButton);
		btnBuyItem7.SetPos('40 272');
		btnBuyItem7.SetSize('124 24');
		btnBuyItem7.SetKeyEquivalent("7");
		btnBuyItem7.SetTag(7);

		btnBuyItem8 = spawn(CSBuyItemButton);
		btnBuyItem8.SetPos('40 304');
		btnBuyItem8.SetSize('124 24');
		btnBuyItem8.SetTag(8);
		btnBuyItem8.SetKeyEquivalent("8");

		btnBuyItem9 = spawn(CSBuyItemButton);
		btnBuyItem9.SetPos('40 336');
		btnBuyItem9.SetSize('124 24');
		btnBuyItem9.SetKeyEquivalent("9");
		btnBuyItem9.SetFunc(VGUI_BuyMenu_Pistols_Cancel);

		btnCancel = spawn(VGUIButton);
		btnCancel.SetTitle(Titles_GetTextBody("Menu_Cancel"));
		btnCancel.SetPos('40 368');
		btnCancel.SetSize('124 24');
		btnCancel.SetKeyEquivalent("0");
		btnCancel.SetFunc(VGUI_BuyMenu_Pistols_Cancel);

		g_uiDesktop.Add(winBuyMenuPage);
		winBuyMenuPage.Add(lblBuyScreenTitle);
		winBuyMenuPage.Add(frmBuyInfo);
		winBuyMenuPage.Add(lblBuyItemDescr);
		winBuyMenuPage.Add(btnBuyItem1);
		winBuyMenuPage.Add(btnBuyItem2);
		winBuyMenuPage.Add(btnBuyItem3);
		winBuyMenuPage.Add(btnBuyItem4);
		winBuyMenuPage.Add(btnBuyItem5);
		winBuyMenuPage.Add(btnBuyItem6);
		winBuyMenuPage.Add(btnBuyItem7);
		winBuyMenuPage.Add(btnBuyItem8);
		winBuyMenuPage.Add(btnBuyItem9);
		winBuyMenuPage.Add(btnCancel);
		winBuyMenuPage.Add(imgBuyItemPic);
		winBuyMenuPage.Add(lblBuyItemTitle);

		/* last but not least, initialize the item descriptions */
		for (int i = 0; i < 29; i++) {
			g_butItemDescr[i] = textfile_to_string(g_buyItemList[i].descrPath);
		}
	}

	winBuyMenuPage.Show();
	winBuyMenuPage.SetPos((video_res / 2) - (winBuyMenuPage.GetSize() / 2));

	switch (buyPage) {
	case BUYPAGE_PISTOLS:
		lblBuyScreenTitle.SetTitle(Titles_GetTextBody("Title_pistol_selection"));

		if (inTeam == TEAM_CT) {
			btnBuyItem5.Hide();
			btnBuyItem6.Show();
		} else {
			btnBuyItem5.Show();
			btnBuyItem6.Hide();
		}
		btnBuyItem1.Show();
		btnBuyItem2.Show();
		btnBuyItem3.Show();
		btnBuyItem4.Show();
		btnBuyItem7.Hide();
		btnBuyItem8.Hide();
		btnBuyItem9.Hide();

		btnBuyItem1.SetTitle(Titles_GetTextBody("KM45Tactical"));
		btnBuyItem1.SetTag(BUYITEM_USP45);
		btnBuyItem2.SetTitle(Titles_GetTextBody("Sidearm9X19mm"));
		btnBuyItem2.SetTag(BUYITEM_GLOCK18);
		btnBuyItem3.SetTitle(Titles_GetTextBody("NightHawk"));
		btnBuyItem3.SetTag(BUYITEM_DEAGLE);
		btnBuyItem4.SetTitle(Titles_GetTextBody("P228Compact"));
		btnBuyItem4.SetTag(BUYITEM_P228);
		btnBuyItem5.SetTitle(Titles_GetTextBody("Dual40"));
		btnBuyItem5.SetTag(BUYITEM_ELITES);
		btnBuyItem6.SetTitle(Titles_GetTextBody("ESFiveSeven"));
		btnBuyItem6.SetTag(BUYITEM_FIVESEVEN);
		break;
	case BUYPAGE_SHOTGUNS:
		lblBuyScreenTitle.SetTitle(Titles_GetTextBody("Title_shotgun_selection"));

		btnBuyItem1.Show();
		btnBuyItem2.Show();
		btnBuyItem3.Hide();
		btnBuyItem4.Hide();
		btnBuyItem5.Hide();
		btnBuyItem6.Hide();
		btnBuyItem7.Hide();
		btnBuyItem8.Hide();
		btnBuyItem9.Hide();

		btnBuyItem1.SetTitle(Titles_GetTextBody("Leone12"));
		btnBuyItem1.SetTag(BUYITEM_M3);
		btnBuyItem2.SetTitle(Titles_GetTextBody("AutoShotgun"));
		btnBuyItem2.SetTag(BUYITEM_XM1014);
		break;
	case BUYPAGE_SMGS:
		lblBuyScreenTitle.SetTitle(Titles_GetTextBody("Title_smg_selection"));

		if (inTeam == TEAM_CT) {
			btnBuyItem2.Show();
			btnBuyItem4.Hide();
		} else {
			btnBuyItem2.Hide();
			btnBuyItem4.Show();
		}
		btnBuyItem1.Show();
		btnBuyItem3.Show();
		btnBuyItem5.Show();
		btnBuyItem6.Hide();
		btnBuyItem7.Hide();
		btnBuyItem8.Hide();
		btnBuyItem9.Hide();

		btnBuyItem1.SetTitle(Titles_GetTextBody("SubMachineGun"));
		btnBuyItem1.SetTag(BUYITEM_MP5);
		btnBuyItem2.SetTitle(Titles_GetTextBody("SchmidtMP"));
		btnBuyItem2.SetTag(BUYITEM_TMP);
		btnBuyItem3.SetTitle(Titles_GetTextBody("ESC90"));
		btnBuyItem3.SetTag(BUYITEM_P90);
		btnBuyItem4.SetTitle(Titles_GetTextBody("Mac10_Short"));
		btnBuyItem4.SetTag(BUYITEM_MAC10);
		btnBuyItem5.SetTitle(Titles_GetTextBody("KMUMP45"));
		btnBuyItem5.SetTag(BUYITEM_UMP45);
		break;
	case BUYPAGE_RIFLES:
		lblBuyScreenTitle.SetTitle(Titles_GetTextBody("Title_rifle_selection"));

		if (inTeam == TEAM_CT) {
			btnBuyItem1.Hide();
			btnBuyItem2.Hide();
			btnBuyItem3.Show();
			btnBuyItem4.Show();
			btnBuyItem7.Hide();
		} else {
			btnBuyItem1.Show();
			btnBuyItem2.Show();
			btnBuyItem3.Hide();
			btnBuyItem4.Hide();
			btnBuyItem7.Show();
		}
		btnBuyItem5.Show();
		btnBuyItem6.Show();
		btnBuyItem8.Show();
		btnBuyItem9.Hide();

		btnBuyItem1.SetTitle(Titles_GetTextBody("AK47"));
		btnBuyItem1.SetTag(BUYITEM_AK47);
		btnBuyItem2.SetTitle(Titles_GetTextBody("Krieg552"));
		btnBuyItem2.SetTag(BUYITEM_SG552);
		btnBuyItem3.SetTitle(Titles_GetTextBody("M4A1_Short"));
		btnBuyItem3.SetTag(BUYITEM_M4A1);
		btnBuyItem4.SetTitle(Titles_GetTextBody("Aug"));
		btnBuyItem4.SetTag(BUYITEM_AUG);
		btnBuyItem5.SetTitle(Titles_GetTextBody("Schmidt"));
		btnBuyItem5.SetTag(BUYITEM_SCOUT);
		btnBuyItem6.SetTitle(Titles_GetTextBody("Magnum"));
		btnBuyItem6.SetTag(BUYITEM_AWP);
		btnBuyItem7.SetTitle(Titles_GetTextBody("D3AU1"));
		btnBuyItem7.SetTag(BUYITEM_G3SG1);
		btnBuyItem8.SetTitle(Titles_GetTextBody("Krieg550"));
		btnBuyItem8.SetTag(BUYITEM_G3SG1);
		break;
	case BUYPAGE_MGS:
		lblBuyScreenTitle.SetTitle(Titles_GetTextBody("Title_machinegun_selection"));

		btnBuyItem1.Show();
		btnBuyItem2.Hide();
		btnBuyItem3.Hide();
		btnBuyItem4.Hide();
		btnBuyItem5.Hide();
		btnBuyItem6.Hide();
		btnBuyItem7.Hide();
		btnBuyItem8.Hide();
		btnBuyItem9.Hide();

		btnBuyItem1.SetTitle(Titles_GetTextBody("ESM249"));
		btnBuyItem1.SetTag(BUYITEM_PARA);
		break;
	case BUYPAGE_EQUIPMENT:
		lblBuyScreenTitle.SetTitle(Titles_GetTextBody("Title_equipment_selection"));

		if (inTeam == TEAM_CT) {
			btnBuyItem6.Show();
		} else {
			btnBuyItem6.Hide();
		}

		btnBuyItem1.Show();
		btnBuyItem2.Show();
		btnBuyItem3.Show();
		btnBuyItem4.Show();
		btnBuyItem5.Show();
		btnBuyItem7.Show();
		btnBuyItem8.Hide();
		btnBuyItem9.Hide();

		btnBuyItem1.SetTitle(Titles_GetTextBody("Kevlar"));
		btnBuyItem1.SetTag(BUYITEM_KEVLAR);
		btnBuyItem2.SetTitle(Titles_GetTextBody("Kevlar_Helmet"));
		btnBuyItem2.SetTag(BUYITEM_HELMET);
		btnBuyItem3.SetTitle(Titles_GetTextBody("Flashbang"));
		btnBuyItem3.SetTag(BUYITEM_FLASHBANG);
		btnBuyItem4.SetTitle(Titles_GetTextBody("HE_Grenade"));
		btnBuyItem4.SetTag(BUYITEM_HENADE);
		btnBuyItem5.SetTitle(Titles_GetTextBody("Smoke_Grenade"));
		btnBuyItem5.SetTag(BUYITEM_SMOKE);
		btnBuyItem6.SetTitle(Titles_GetTextBody("Defusal_Kit"));
		btnBuyItem6.SetTag(BUYITEM_DEFUSE);
		btnBuyItem7.SetTitle(Titles_GetTextBody("NightVision"));
		btnBuyItem7.SetTag(BUYITEM_NIGHTVISION);
		break;
	}
}