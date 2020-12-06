

void() CSQC_Input_Frame =
{
	if (input_impulse) cheats_used = TRUE;
	float maxspeed = 270;
	input_movevalues_x = bound(-maxspeed, input_movevalues_x, maxspeed);
	input_movevalues_y = bound(-maxspeed, input_movevalues_y, maxspeed);
	input_movevalues_z = bound(-maxspeed, input_movevalues_z, maxspeed);
};


