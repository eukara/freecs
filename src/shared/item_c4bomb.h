#ifdef SERVER
void C4Bomb_Plant(NSClientPlayer); 
#endif

#ifdef CLIENT
string g_c4bombled_spr;
void w_c4bomb_parse(void);
#endif
