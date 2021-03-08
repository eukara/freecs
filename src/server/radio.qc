/*
=================
Radio_BroadcastMessage

A global radio message for all players
=================
*/
void
Radio_BroadcastMessage(float fMessage)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_RADIOMSG);
	WriteByte(MSG_MULTICAST, fMessage);
	msg_entity = self;
	multicast([0,0,0], MULTICAST_ALL);
}

/*
=================
Radio_TeamMessage

A radio message targetted at members of a specific team
=================
*/
void
Radio_TeamMessage(float fMessage, float fTeam)
{
	static void Radio_TeamMessage_Send(float fMessage, entity eEnt) {
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, EV_RADIOMSG);
		WriteByte(MSG_MULTICAST, fMessage);
		msg_entity = eEnt;
		multicast([0,0,0], MULTICAST_ONE);
	}
	
	for (entity eFind = world; (eFind = find(eFind, classname, "player"));) {
		if (eFind.team == fTeam) {
			Radio_TeamMessage_Send(fMessage, eFind);
		} else if (eFind.team == TEAM_VIP && fTeam == TEAM_CT) {
			Radio_TeamMessage_Send(fMessage, eFind);
		}
	}
}

/*
=================
Radio_DefaultStart

Pick a generic, random radio string for global start messages
=================
*/
float
Radio_DefaultStart(void)
{
	float fRand = floor(random(1, 4));
	
	if (fRand == 1) {
		return RADIO_MOVEOUT;
	} else if (fRand == 2) {
		return RADIO_LOCKNLOAD;
	} else {
		return RADIO_LETSGO;
	}
}

/*
=================
Radio_StartMessage

Decide which startmessage to play at the beginning of each round
=================
*/
void
Radio_StartMessage(void)
{
	if (g_cs_vipzones > 0) {
		Radio_TeamMessage(RADIO_VIP, TEAM_CT);
		Radio_TeamMessage(Radio_DefaultStart(), TEAM_T);
	} else if (g_cs_escapezones > 0) {
		Radio_TeamMessage(RADIO_GETOUT, TEAM_T);
		Radio_TeamMessage(Radio_DefaultStart(), TEAM_CT);
	} else {
		Radio_BroadcastMessage(Radio_DefaultStart());
	}
}

/*
=================
CSEv_Radio_f

Triggered by clients, plays a message to members of the same team
=================
*/
void
CSEv_Radio_f(float fMessage)
{
	static void CSEv_Radio_Send(float fMessage, entity eEnt) {
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, EV_RADIOMSG2);
		WriteByte(MSG_MULTICAST, num_for_edict(eEnt) - 1);
		WriteByte(MSG_MULTICAST, fMessage);
		msg_entity = eEnt;
		multicast([0,0,0], MULTICAST_ONE);
	}
	
	// Don't allow spamming
	/*if (self.fRadioFinished > time) {
		return;
	}*/
	
	// When dead, don't talk
	if (self.health <= 0) {
		return;
	}
	
	// Make sure that VIPs and CTs get eachother
	float fTargetTeam = self.team;
	if (fTargetTeam == TEAM_VIP) {
		fTargetTeam = TEAM_CT;
	}
	
	for (entity eFind = world; (eFind = find(eFind, classname, "player"));) {
		if (eFind.team == fTargetTeam) {
			CSEv_Radio_Send(fMessage, eFind);
		} else if (eFind.team == TEAM_VIP && fTargetTeam == TEAM_CT) {
			CSEv_Radio_Send(fMessage, eFind);
		}
	}
	
	/*self.fRadioFinished = time + 3.0f;*/
} 
