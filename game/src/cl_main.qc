
void() CSQC_Ent_Remove =
{
	remove(self);
};

void() CSQC_Shutdown =
{
};

noref void(float apiver, string enginename, float enginever) CSQC_Init =
{
	precache_everything();
	
	cl_editor_init();
	
	makevectors('60 45 0');
	sun_dir = -v_forward;

	registercvar("cl_hud", "1");
	registercvar("cl_hud_timer", "0");
	registercommand("noclip");
};

noref void() CSQC_WorldLoaded =
{

};

noref void(float isnew) CSQC_Ent_Update =
{
	// printf("csqc ent update %f\n", isnew);
};

// CALLED EVERY CLIENT RENDER FRAME
void(float width, float height, float menushown) CSQC_UpdateView =
{
	//clear and update our global screen resolution vars
	clearscene();
	g_width = width;
	g_height = height;
	
	
	//disable quake status bar and quake crosshair
	setproperty(VF_DRAWENGINESBAR, 0);	
	setproperty(VF_DRAWCROSSHAIR, 0);

	campos = getproperty(VF_ORIGIN);
	camang = getproperty(VF_ANGLES);
	
	setproperty(VF_ANGLES, camang);
	setproperty(VF_ORIGIN, campos);
	
	//autoadd entities received from servers for drawing
	addentities(MASK_ENGINE);

	
	//does what you think it does
	renderscene();
	
	// draw_sun();
	
	draw_hud();
	
	sui_begin(g_width, g_height);

	draw_menu();

	cl_editor_draw();
	
	sui_end();
};

float(string cmd) CSQC_ConsoleCommand =
{
	if (cl_editor_command(cmd)) return TRUE;
	
	tokenize(cmd);
	switch(argv(0))
	{
		case "noclip":
			cheats_used = TRUE;
			return FALSE;
		default:
			return FALSE;
	}
	return TRUE;
};

float(float evtype, float scanx, float chary, float devid) CSQC_InputEvent =
{
	sui_input_event(evtype, scanx, chary, devid);
	
	switch(evtype)
	{
	case IE_KEYDOWN:
		if (scanx == K_LALT || scanx == K_RALT)
			alt_held = TRUE;
		if (scanx == K_LCTRL || scanx == K_RCTRL)
			ctrl_held = TRUE;
		if (scanx == K_LSHIFT || scanx == K_RSHIFT)
			shift_held = TRUE;
		break;
	case IE_KEYUP:
		if (scanx == K_LALT || scanx == K_RALT)
			alt_held = FALSE;
		if (scanx == K_LCTRL || scanx == K_RCTRL)
			ctrl_held = FALSE;
		if (scanx == K_LSHIFT || scanx == K_RSHIFT)
			shift_held = FALSE;
		break;
	case IE_MOUSEDELTA:
		break;
	case IE_MOUSEABS:
		cursor_pos_x = scanx;
		cursor_pos_y = chary;
		break;
	}
	
	if (cl_editor_input_event(evtype, scanx, chary, devid))
		return TRUE;
		
	return FALSE;
};

void() CSQC_Parse_Event =
{
	float first = readbyte();
	switch(first) {
		case EV_ED_UPDATE:
			cl_editor_update_selection();
			break;
		default:
			printf("No action for byte %f\n", first);
			break;
	}
};


float(string key, string val) find_player_id =
{
	for (int currentindex = 0; currentindex < maxclients; currentindex++)
	{
		if (getplayerkeyvalue(currentindex, key) == val) return currentindex;
	}
	return -1;
}

void(string printmsg, float printlvl) CSQC_Parse_Print =
{
	print(printmsg);
};
