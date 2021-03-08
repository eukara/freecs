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

/*QUAKED armoury_entity (0 0 0.8) (-16 -16 0) (16 16 16)
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

string sArmouryModels[19] = {
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

class armoury_entity:CBaseEntity
{
	int m_iCount;
	int m_iLeft;
	int m_iItem;

	void(void) armoury_entity;
	virtual void(void) touch;
	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;
};

void
armoury_entity::touch(void)
{
	if (other.classname != "player") {
		return;
	}

	/* temp */
	if (m_iItem == 17 || m_iItem == 16)
		return;

	if (Weapons_AddItem((player)other, m_iItem, -1) == FALSE) {
		return;
	}

	Logging_Pickup(other, this, __NULL__);
	sound(other, CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_NORM);

	m_iLeft--;
	if (m_iLeft <= 0) {
		Hide();
	}
}

void
armoury_entity::Respawn(void)
{
	SetModel(m_oldModel);
	setsize(this, [-16,-16,0], [16,16,16]);
	solid = SOLID_TRIGGER;
	m_iLeft = m_iCount;
	droptofloor();
}

void
armoury_entity::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "count":
		m_iCount = stoi(strValue);
		break;
	case "item":
		int id = stoi(strValue);

		if (id < 0 || id >= 19) {
			print(sprintf("^1armoury_entity with invalid item %i. ignoring\n", m_iItem));
			remove(this);
			return;
		}

		m_iItem = g_cstrike_armouryitems[id];
		model = sArmouryModels[id];
		break;
	default:
		CBaseEntity::SpawnKey(strKey, strValue);
		break;
	}
}

void
armoury_entity::armoury_entity(void)
{
	if (autocvar_fcs_nopickups == TRUE) {
		remove(this);
		return;
	}

	m_iCount = 1;
	CBaseEntity::CBaseEntity();
}
