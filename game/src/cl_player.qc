

void() player_shoot =
{
	
}

void() CSQC_Input_Frame =
{
	holding_fire = input_buttons & 1;
	if (input_impulse) cheats_used = TRUE;
	float maxspeed = 180 + getstatf(STAT_SPEED) * 14;
	if (vlen(input_movevalues) > maxspeed)
		input_movevalues = normalize(input_movevalues) * maxspeed;
	/*
	input_movevalues_x = bound(-maxspeed, input_movevalues_x, maxspeed);
	input_movevalues_y = bound(-maxspeed, input_movevalues_y, maxspeed);
	input_movevalues_z = bound(-maxspeed, input_movevalues_z, maxspeed);
	*/
};
