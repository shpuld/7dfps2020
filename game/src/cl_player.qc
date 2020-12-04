

void() CSQC_Input_Frame =
{
	if (input_impulse) cheats_used = TRUE;
	
	input_movevalues_x = bound(-350, input_movevalues_x, 350);
	input_movevalues_y = bound(-350, input_movevalues_y, 350);
	input_movevalues_z = bound(-350, input_movevalues_z, 350);
};


