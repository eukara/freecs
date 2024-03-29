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

/*!QUAKED armoury_entity (0 0 0.8) (-16 -16 0) (16 16 16)
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.
"item"          Which weapon/equipment this item will contain
"count"         How many of said item will players be able to pick up from this

COUNTER-STRIKE (1999) ENTITY

Items in the armoury.

An item oriented entity that contains one or more weapon/equipment item
for players to pick up. It's limited to early Counter-Strike weapons, as
it was never updated in newer versions to add support for newly added ones.

List of available items:
    0 =  H&K MP5-Navy
    1 =  Steyr Tactical (TMP)
    2 =  FN P90
    3 =  Ingram MAC-10
    4 =  AK-47
    5 =  Sig SG-552 Commando
    6 =  Colt M4A1 Carbine
    7 =  Steyr AUG
    8 =  Steyr Scout
    9 =  H&K G3/SG-1
    10 = AI Arctic Warfare/Magnum
    11 = Benneli M3 Super90
    12 = Benneli XM1014
    13 = FN M249 Para
    14 = Flashbang Grenade
    15 = HE Grenade
    16 = Kevlar
    17 = Kevlar + Helmet
    18 = Smoke Grenade
*/

var int autocvar_fcs_nopickups = FALSE;

int g_cstrike_armouryitems[19] = {
	WEAPON_MP5,
	WEAPON_TMP,
	WEAPON_P90,
	WEAPON_MAC10,
	WEAPON_AK47,
	WEAPON_SG552,
	WEAPON_M4A1,
	WEAPON_AUG,
	WEAPON_SCOUT,
	WEAPON_G3SG1,
	WEAPON_AWP,
	WEAPON_M3,
	WEAPON_XM1014,
	WEAPON_PARA,
	WEAPON_FLASHBANG,
	WEAPON_HEGRENADE,
	0,/*EQUIPMENT_KEVLAR,*/
	0,/*EQUIPMENT_HELMET,*/
	WEAPON_SMOKEGRENADE
};

string g_cstrike_armourymodels[19] = {
	"models/w_mp5.mdl",
	"models/w_tmp.mdl",
	"models/w_p90.mdl",
	"models/w_mac10.mdl",
	"models/w_ak47.mdl",
	"models/w_sg552.mdl",
	"models/w_m4a1.mdl",
	"models/w_aug.mdl",
	"models/w_scout.mdl",
	"models/w_g3sg1.mdl",
	"models/w_awp.mdl",
	"models/w_m3.mdl",
	"models/w_xm1014.mdl",
	"models/w_m249.mdl",
	"models/w_flashbang.mdl",
	"models/w_hegrenade.mdl",
	"models/w_kevlar.mdl",
	"models/w_assault.mdl",
	"models/w_smokegrenade.mdl"
};

class armoury_entity:NSRenderableEntity
{
	int m_iCount;
	int m_iLeft;
	int m_iID;

	void(void) armoury_entity;
	virtual void(void) Spawned;
	virtual void(float) Save;
	virtual void(string,string) Restore;
	virtual void(entity) Touch;
	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;
};

void
armoury_entity::armoury_entity(void)
{
	m_iID = 0;
	m_iCount = 1;
	m_iLeft = 0;
}

void
armoury_entity::Spawned(void)
{
	if (autocvar_fcs_nopickups == TRUE) {
		Destroy();
		return;
	}

	super::Spawned();

	precache_model(g_cstrike_armourymodels[m_iID]);
	precache_sound("items/gunpickup2.wav");
	precache_sound("items/tr_kevlar.wav");
}

void
armoury_entity::Save(float handle)
{
	super::Save(handle);
	SaveInt(handle, "m_iID", m_iID);
	SaveInt(handle, "m_iCount", m_iCount);
	SaveInt(handle, "m_iLeft", m_iLeft);
}

void
armoury_entity::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_iID":
		m_iID = ReadInt(strValue);
		break;
	case "m_iCount":
		m_iCount = ReadInt(strValue);
		break;
	case "m_iLeft":
		m_iLeft = ReadInt(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
armoury_entity::Touch(entity eToucher)
{
	player pl;
	if (eToucher.classname != "player") {
		return;
	}

	pl = (player)eToucher;

	/* armor is separate from weapons */
	if (m_iID == 17 || m_iID == 16) {
		bool picked_up = false;

		/* skip if we already got armor */
		if (pl.armor < 100) {
			pl.armor = 100;
			picked_up = true;
		}

		/* we may need a helmet though */
		if (!(pl.g_items & ITEM_HELMET) && m_iID == 17) {
			pl.g_items |= ITEM_HELMET;
			picked_up = true;
		}

		/* if nothing got picked up, cancel out */
		if (picked_up == false)
			return;

		sound(pl, CHAN_ITEM, "items/tr_kevlar.wav", 1, ATTN_NORM);
	} else { /* weapon pickup code */
		if (Weapons_AddItem(pl, g_cstrike_armouryitems[m_iID], -1) == FALSE)
			return;

		sound(pl, CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_NORM);
	}

	Logging_Pickup(pl, this, __NULL__);
	m_iLeft--;

	if (m_iLeft <= 0) {
		Disappear();
	}
}

void
armoury_entity::Respawn(void)
{
	SetOrigin(GetSpawnOrigin());
	SetSolid(SOLID_TRIGGER);
	SetModel(g_cstrike_armourymodels[m_iID]);
	SetSize([-16,-16,0], [16,16,16]);
	DropToFloor();

	m_iLeft = m_iCount;
}

void
armoury_entity::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "count":
		m_iCount = stoi(strValue);
		break;
	case "item":
		m_iID = stoi(strValue);

		if (m_iID < 0 || m_iID >= 19) {
			NSLog("^1armoury_entity with invalid item %i. ignoring\n", m_iID);
			Destroy();
		}
		break;
	default:
		super::SpawnKey(strKey, strValue);
		break;
	}
}
