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

int
ClientGame_ConsoleCommand(void)
{
	switch(argv(0)) {
	case "chooseteam":
		Textmenu_Toggle("TEAM_SELECT");
		break;
	case "buy":
		Textmenu_Toggle("BUY");
		break;
	case "radio1":
		Textmenu_Toggle("RADIOA");
		break;
	case "radio2":
		Textmenu_Toggle("RADIOB");
		break;
	case "radio3":
		Textmenu_Toggle("RADIOC");
		break;
	case "nightvision":
		/*Nightvision_Toggle();*/
		break;
	case "drop":
		sendevent("DropWeapon", "");
		break;
	case "glock":
		sendevent("BuyWeapon", "f", WEAPON_GLOCK18);
		break;
	case "usp":
		sendevent("BuyWeapon", "f", WEAPON_USP45);
		break;
	case "p228":
		sendevent("BuyWeapon", "f", WEAPON_P228);
		break;
	case "deagle":
		sendevent("BuyWeapon", "f", WEAPON_DEAGLE);
		break;
	case "fn57":
		sendevent("BuyWeapon", "f", WEAPON_FIVESEVEN);
		break;
	case "elites":
		sendevent("BuyWeapon", "f", WEAPON_ELITES);
		break;
	case "m3":
		sendevent("BuyWeapon", "f", WEAPON_M3);
		break;
	case "xm1014":
		sendevent("BuyWeapon", "f", WEAPON_XM1014);
		break;
	case "tmp":
		sendevent("BuyWeapon", "f", WEAPON_TMP);
		break;
	case "mac10":
		sendevent("BuyWeapon", "f", WEAPON_MAC10);
		break;
	case "mp5":
		sendevent("BuyWeapon", "f", WEAPON_MP5);
		break;
	case "ump45":
		sendevent("BuyWeapon", "f", WEAPON_UMP45);
		break;
	case "p90":
		sendevent("BuyWeapon", "f", WEAPON_P90);
		break;
	case "ak47":
		sendevent("BuyWeapon", "f", WEAPON_AK47);
		break;
	case "m4a1":
		sendevent("BuyWeapon", "f", WEAPON_M4A1);
		break;
	case "sg552":
		sendevent("BuyWeapon", "f", WEAPON_SG552);
		break;
	case "aug":
		sendevent("BuyWeapon", "f", WEAPON_AUG);
		break;
	case "scout":
		sendevent("BuyWeapon", "f", WEAPON_SCOUT);
		break;
	case "sg550":
		sendevent("BuyWeapon", "f", WEAPON_SG550);
		break;
	case "awp":
		sendevent("BuyWeapon", "f", WEAPON_AWP);
		break;
	case "g3sg1":
		sendevent("BuyWeapon", "f", WEAPON_G3SG1);
		break;
	case "m249":
		sendevent("BuyWeapon", "f", WEAPON_PARA);
		break;
	case "buyammo1":
	case "primammo":
		sendevent("AmmoBuyPrimary", "");
		break;
	case "buyammo2":
	case "secammo":
		sendevent("AmmoBuySecondary", "");
		break;
	case "vest":
		sendevent("BuyEquipment", "f", 0);
		break;
	case "vesthelm":
		sendevent("BuyEquipment", "f", 1);
		break;
	case "flash":
		sendevent("BuyEquipment", "f", 2);
		break;
	case "hegren":
		sendevent("BuyEquipment", "f", 3);
		break;
	case "vsgren":
		sendevent("BuyEquipment", "f", 4);
		break;
	case "defuser":
		sendevent("BuyEquipment", "f", 5);
		break;
	case "nvg":
		sendevent("BuyEquipment", "f", 6);
		break;
	case "coverme":
		sendevent("Radio", "f", RADIO_CT_COVERME);
		break;
	case "takepoint":
		sendevent("Radio", "f", RADIO_CT_POINT);
		break;
	case "takepoint":
		sendevent("Radio", "f", RADIO_POSITION);
		break;
	case "regroup":
		sendevent("Radio", "f", RADIO_REGROUP);
		break;
	case "followme":
		sendevent("Radio", "f", RADIO_FOLLOWME);
		break;
	case "takingfire":
		sendevent("Radio", "f", RADIO_FIREASSIS);
		break;
	case "go":
		sendevent("Radio", "f", RADIO_GO);
		break;
	case "fallback":
		sendevent("Radio", "f", RADIO_FALLBACK);
		break;
	case "sticktog":
		sendevent("Radio", "f", RADIO_STICKTOG);
		break;
	case "getinpos":
		sendevent("Radio", "f", RADIO_COM_GETINPOS);
		break;
	case "stormfront":
		sendevent("Radio", "f", RADIO_STORMFRONT);
		break;
	case "report":
		sendevent("Radio", "f", RADIO_COM_REPORTIN);
		break;
	case "roger":
		sendevent("Radio", "f", RADIO_ROGER);
		break;
	case "enemyspot":
		sendevent("Radio", "f", RADIO_CT_ENEMYS);
		break;
	case "needbackup":
		sendevent("Radio", "f", RADIO_CT_BACKUP);
		break;
	case "sectorclear":
		sendevent("Radio", "f", RADIO_CLEAR);
		break;
	case "inposition":
		sendevent("Radio", "f", RADIO_CT_INPOS);
		break;
	case "reportingin":
		sendevent("Radio", "f", RADIO_CT_REPORTINGIN);
		break;
	case "getout":
		sendevent("Radio", "f", RADIO_GETOUT);
		break;
	case "negative":
		sendevent("Radio", "f", RADIO_NEGATIVE);
		break;
	case "enemydown":
		sendevent("Radio", "f", RADIO_ENEMYDOWN);
		break;
	default:
		return FALSE;
	}
	return TRUE;
}
