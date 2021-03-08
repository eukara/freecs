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

#ifdef SERVER
void CSEv_PlayerBuyEquipment_f(float fID) {
/*	if (Rules_BuyingPossible() == FALSE) {
		return;
	}
	
	if ((self.fMoney - eqptTable[fID].iPrice) >= 0) {
		if (eqptTable[fID].iID == EQUIPMENT_DEFUSALKIT) {
			if (self.team == TEAM_T) { return; }
			if (!(self.iEquipment & EQUIPMENT_DEFUSALKIT)) {
				self.iEquipment |= EQUIPMENT_DEFUSALKIT;
				Money_AddMoney(self, -200);
				sound(self, CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_IDLE);
			} else {
				centerprint(self, "You already have a defusal kit!");
			}
		} else if (eqptTable[fID].iID == EQUIPMENT_NIGHTVISION) {
			if (!(self.iEquipment & EQUIPMENT_NIGHTVISION)) {
				self.iEquipment |= EQUIPMENT_NIGHTVISION;
				Money_AddMoney(self, -1250);
				sound(self, CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_IDLE);
			} else {
				centerprint(self, "You already have nightvision goggles!");
			}
		} else if (eqptTable[fID].iID == WEAPON_HEGRENADE) {
			if (self.iAmmo_HEGRENADE < 2) {
				self.iAmmo_HEGRENADE++;
				Money_AddMoney(self, -300);
				sound(self, CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_IDLE);
			} else {
				centerprint(self, "You can't carry any more!");
			}
		} else if (eqptTable[fID].iID == WEAPON_FLASHBANG) {
			if (self.iAmmo_FLASHBANG < 2) {
				self.iAmmo_FLASHBANG++;
				Money_AddMoney(self, -300);
				sound(self, CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_IDLE);
			} else {
				centerprint(self, "You can't carry any more!");
			}
		} else if (eqptTable[fID].iID == WEAPON_SMOKEGRENADE) {
			if (self.iAmmo_SMOKEGRENADE < 2) {
				self.iAmmo_SMOKEGRENADE++;
				Money_AddMoney(self, -300);
				sound(self, CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_IDLE);
			} else {
				centerprint(self, "You can't carry any more!");
			}
		} else if (eqptTable[fID].iID == EQUIPMENT_KEVLAR) {
			if (self.armor == 100) {
				// You already own kevlar etc.
				centerprint(self, "You already have kevlar!");
			} else {
				self.armor = 100;
				Money_AddMoney(self, -650);
			}
			
			sound(self, CHAN_ITEM, "items/tr_kevlar.wav", 1, ATTN_IDLE);
			self.fAttackFinished = time + 1.0;
			return;
		} else if (eqptTable[fID].iID == EQUIPMENT_HELMET) {
			if (self.armor == 100) {
				if (self.iEquipment & EQUIPMENT_HELMET) {
					// You already have full kevlar and a helmet
					centerprint(self, "You already have kevlar and a helmet!");
				} else {
					// You have full kevlar, but no helmet
					Money_AddMoney(self, -350);
					sound(self, CHAN_ITEM, "items/tr_kevlar.wav", 1, ATTN_IDLE);
					centerprint(self, "You already have some kevlar,\nand now you've bought a helmet!");
					self.iEquipment = self.iEquipment | EQUIPMENT_HELMET;
				}
			} else {
				if (self.iEquipment & EQUIPMENT_HELMET) {
					// Only get kevlar
					self.armor = 100;
					Money_AddMoney(self, -650);
					sound(self, CHAN_ITEM, "items/tr_kevlar.wav", 1, ATTN_IDLE);
					centerprint(self, "You already have a helmet,\nand now you've bought some kevlar!");
				} else {
					// Get both
					self.armor = 100;
					self.iEquipment = self.iEquipment | EQUIPMENT_HELMET;
					Money_AddMoney(self, -1000);
					sound(self, CHAN_ITEM, "items/tr_kevlar.wav", 1, ATTN_IDLE);
				}
			}
			
			self.fAttackFinished = time + 1.0;
			return;
		} 
	} else {
		centerprint(self, "You have insufficient funds!");
	}
	
	self.fAttackFinished = time + 1.0;*/
}
#endif
