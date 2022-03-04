/*
 * Copyright (c) 2016-2021 Marco Hladik <marco@icculus.org>
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

#include "animations.h"
#include "radio.h"
#include "weapons.h"
#include "items.h"
#include "entities.h"
#include "events.h"
#include "pmove.h"

#define TEAM_SPECTATOR	0
#define TEAM_T		1
#define TEAM_CT		2
#define TEAM_VIP	3

enum
{
	STAT_MONEY = 34,
	STAT_PROGRESS,
	STAT_GAMETIME,
	STAT_GAMESTATE
};

string
HUD_GetChatColorHEX(float fTeam)
{
	if (fTeam == TEAM_CT) {
		return "^x7AC";
	} else if (fTeam == TEAM_T) {
		return "^xC33";
	} else {
		return "^xCCC";
	}
}

enum
{
	GAME_INACTIVE,
	GAME_COMMENCING,
	GAME_FREEZE,
	GAME_ACTIVE,
	GAME_END, 
	GAME_OVER
};
