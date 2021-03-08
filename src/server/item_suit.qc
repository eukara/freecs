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

class item_suit:CBaseTrigger
{
	void(void) item_suit;

	virtual void(void) touch;
	virtual void(void) Respawn;
};

void item_suit::touch(void)
{
	player pl = (player)other;

	if (pl.classname != "player") {
		return;
	}

	if (pl.g_items & ITEM_SUIT) {
		return;
	}

	sound(other, CHAN_ITEM, "items/tr_kevlar.wav", 1, ATTN_NORM);
	pl.g_items |= ITEM_SUIT;

	UseTargets(other, TRIG_TOGGLE, m_flDelay);

	if (cvar("sv_playerslots") == 1) {
		remove(self);
	} else {
		Hide();
		think = Respawn;
		nextthink = time + 30.0f;
	}
}

void item_suit::Respawn(void)
{
	SetSolid(SOLID_TRIGGER);
	SetMovetype(MOVETYPE_TOSS);
	SetSize(VEC_HULL_MIN, VEC_HULL_MAX);
	SetOrigin(m_oldOrigin);
	SetModel(m_oldModel);

	think = __NULL__;
	nextthink = -1;
}

void item_suit::item_suit(void)
{
	model = "models/w_kevlar.mdl";
	precache_sound("items/tr_kevlar.wav");
	CBaseTrigger::CBaseTrigger();
	Respawn();
}
