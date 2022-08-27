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

class item_suit:NSRenderableEntity
{
	void(void) item_suit;

	virtual void(entity) Touch;
	virtual void(void) Respawn;
	virtual void(void) Spawned;
};

void
item_suit::item_suit(void)
{
	/* a custom map may choose to override this */
	model = "models/w_kevlar.mdl";
}

void
item_suit::Spawned(void)
{
	super::Spawned();

	precache_model(model);
	precache_sound("items/tr_kevlar.wav");
}

void
item_suit::Respawn(void)
{
	SetSolid(SOLID_TRIGGER);
	SetMovetype(MOVETYPE_TOSS);
	SetModel(GetSpawnModel());
	SetSize(VEC_HULL_MIN, VEC_HULL_MAX);
	SetOrigin(GetSpawnOrigin());
	ReleaseThink();
}

void
item_suit::Touch(entity eToucher)
{
	player pl = (player)eToucher;

	if (pl.classname != "player") {
		return;
	}

	if (pl.g_items & ITEM_SUIT) {
		return;
	}

	sound(eToucher, CHAN_ITEM, "items/tr_kevlar.wav", 1, ATTN_NORM);
	pl.g_items |= ITEM_SUIT;

	UseTargets(eToucher, TRIG_TOGGLE, m_flDelay);

	if (cvar("sv_playerslots") == 1) {
		Destroy();
	} else {
		Disappear();
		ScheduleThink(Respawn, 30.0f);
	}
}
