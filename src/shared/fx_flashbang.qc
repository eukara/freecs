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
void
FX_Flashbang(vector org)
{
	for (entity e = world; (e = find(e, ::classname, "player"));) {
		float fov_dot;
		vector val;
		float blindness;
		float fade;

		/* wall check */
		traceline(e.origin + e.view_ofs, org, FALSE, e);
		if (trace_fraction < 1.0f)
			continue;

		/* calculate the fov in dotproduct form */
		makevectors(e.v_angle);
		val = normalize(org - (e.origin + e.view_ofs));
		fov_dot = val * v_forward;

		/* it's behind us */
		if (fov_dot < 0) {
			blindness = 0.1;
			fade = 1.0f;
		} else {
			blindness = 2 * fov_dot;
			fade = 4 * fov_dot;
		}

		/* send the blinding env_fade event */
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, EV_FADE);
		WriteFloat(MSG_MULTICAST, 1.0f);
		WriteFloat(MSG_MULTICAST, 1.0f);
		WriteFloat(MSG_MULTICAST, 1.0f);
		WriteFloat(MSG_MULTICAST, 1.0f);
		WriteFloat(MSG_MULTICAST, blindness);
		WriteFloat(MSG_MULTICAST, fade);
		WriteByte(MSG_MULTICAST, EVF_FADEDROM);
		msg_entity = e;
		multicast([0,0,0], MULTICAST_ONE_R);
	}
}
#endif 
