#define AMMO_COUNT 13

string g_ammo_spr;

typedef struct
{
	float alpha;
	int count;
} ammonote_t;
ammonote_t g_ammonotify[AMMO_COUNT];

vector g_ammotype[AMMO_COUNT] = {
	[24/256,72/256], // ammo_50ae
	[72/256,72/256], // ammo_762mm
	[0/256,96/256], // ammo_556mm
	[0/256,96/256], // ammo_556mmbox
	[24/256,96/256], // ammo_338mag
	[48/256,72/256],// ammo_9mm
	[0/256,72/256], // ammo_buckshot
	[96/256,72/256], // ammo_45acp
	[120/256,72/256], // ammo_357sig
	[120/256,96/256], // ammo_57mm
	[72/256,96/256], // ammo_hegrenade
	[48/256,96/256], // ammo_fbgrenade
	[144/256,96/256], // ammo_smokegrenade
};

void
HUD_AmmoNotify_Init(void)
{
	g_ammo_spr = spriteframe("sprites/640hud7.spr", 0, 0.0f);
}

void
HUD_AmmoNotify_Draw(vector startpos)
{
	vector pos = startpos;

	for (int i = 0; i < AMMO_COUNT; i++) {
		vector srcpos;
		float a;

		/* make sure we skip any faded entries, and also null them */
		if (g_ammonotify[i].alpha <= 0.0f) {
			g_ammonotify[i].count = 0;
			continue;
		}

		/* let's get the src img pos for our type */
		srcpos = g_ammotype[i];
		a = bound(0, g_ammonotify[i].alpha, 1.0);

		drawsubpic(pos,
			[24,24],
			g_ammo_spr,
			srcpos,
			[24/256, 24/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);

		drawfont = Font_GetID(FONT_20);
		string txt = sprintf("%i", g_ammonotify[i].count);
		float offs = stringwidth(txt, FALSE, [20,20]);
		drawstring(pos + [-offs - 8,4], sprintf("%i", g_ammonotify[i].count), [20,20], g_hud_color, a, DRAWFLAG_ADDITIVE);

		g_ammonotify[i].alpha -= (clframetime * 0.5);
		pos -= [0, 32]; /* go up a notch */
	}
}

void
HUD_AmmoNotify_Insert(int type, int count)
{
	if (count <= 0)
		return;

	g_ammonotify[type].count += count;
	g_ammonotify[type].alpha = 2.5f;

}

/* called whenever we should check for pickup updates */
void
HUD_AmmoNotify_Check(player pl)
{
	HUD_AmmoNotify_Insert(0, pl.ammo_50ae - pl.ammo_50ae_net);
	HUD_AmmoNotify_Insert(1, pl.ammo_762mm - pl.ammo_762mm_net);
	HUD_AmmoNotify_Insert(2, pl.ammo_556mm - pl.ammo_556mm_net);
	HUD_AmmoNotify_Insert(3, pl.ammo_556mmbox - pl.ammo_556mmbox_net);
	HUD_AmmoNotify_Insert(4, pl.ammo_338mag - pl.ammo_338mag_net);
	HUD_AmmoNotify_Insert(5, pl.ammo_9mm - pl.ammo_9mm_net);
	HUD_AmmoNotify_Insert(6, pl.ammo_buckshot - pl.ammo_buckshot_net);
	HUD_AmmoNotify_Insert(7, pl.ammo_45acp - pl.ammo_45acp_net);
	HUD_AmmoNotify_Insert(8, pl.ammo_357sig - pl.ammo_357sig_net);
	HUD_AmmoNotify_Insert(9, pl.ammo_57mm - pl.ammo_57mm_net);
	HUD_AmmoNotify_Insert(10, pl.ammo_hegrenade - pl.ammo_hegrenade_net);
	HUD_AmmoNotify_Insert(11, pl.ammo_fbgrenade - pl.ammo_fbgrenade_net);
	HUD_AmmoNotify_Insert(12, pl.ammo_smokegrenade - pl.ammo_smokegrenade_net);
}