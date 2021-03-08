/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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

/*
=================
info_player_start

Counter-Terrorist Spawnpoints
=================
*/
void info_player_start(void)
{
	if (autocvar_fcs_swapteams == TRUE) {
		self.classname = "info_player_deathmatch";
	}
	self.botinfo = BOTINFO_SPAWNPOINT;
}

/*
=================
info_player_deathmatch

Terrorist Spawnpoints
=================
*/
void info_player_deathmatch(void)
{
	if (autocvar_fcs_swapteams == TRUE) {
		self.classname = "info_player_start";
	}
	self.botinfo = BOTINFO_SPAWNPOINT;
}

/* Counter-Strike: Source compat */
void info_player_counterterrorist(void)
{
	setorigin(self, self.origin + [0,0,32]);
	self.classname = "info_player_start";
	info_player_start();
}

void info_player_terrorist(void)
{
	setorigin(self, self.origin + [0,0,32]);
	self.classname = "info_player_deathmatch";
	info_player_deathmatch();
}

/*
=================
info_vip_start
=================
*/
void info_vip_start(void)
{
}
