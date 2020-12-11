
void() CSQC_Ent_Remove =
{
	remove(self);
};

void() CSQC_Shutdown =
{
};

entity skybox;
entity viewmodel;
entity viewmodel_mzl;
float normalfov;

float vmodel_time;
float vmodel_walktime;
vector prev_angles;
vector prev_pos;
vector angle_sway;
float angle_reset_time;
float aiming_lerp;
vector recoil;
float current_fov;
vector recoil_pos;
float gunchange_time;

void() viewmodel_update =
{
	entity old_self = self;
	self = viewmodel;

	vmodel_time += frametime;

	vector baseoffset = '10 -2.5 -2.25';
	self.origin = baseoffset;

	vector idleoffset = [0, sin(vmodel_time * 1.25) * 0.25, cos(vmodel_time * 1.75) * 0.25];
	self.origin += idleoffset * 0.6;
		
	float yawdiff = angle_diff_signed(prev_angles_y, camang_y);
	float pitchdiff = angle_diff_signed(prev_angles_x, camang_x);
	
	if ((fabs(yawdiff) + fabs(pitchdiff)) > 20 * frametime)
	{
		angle_sway.y += yawdiff * 2.5 * frametime;
		angle_sway.z -= pitchdiff * 2.5 * frametime;
		if (vlen(angle_sway) > 1.5)
			angle_sway = normalize(angle_sway) * 1.5;
		angle_reset_time = vmodel_time;
	}

	if (vlen(angle_sway) > 0.8 && vmodel_time > angle_reset_time)
		angle_sway -= normalize(angle_sway) * frametime * 2;

	self.origin += angle_sway;
	
	float posdiff = vlen([prev_pos.x, prev_pos.y] - [campos.x, campos.y]);
	vmodel_walktime += posdiff * 0.03;
	vector walkoffset = 0.25 * [0, cos(vmodel_walktime * 1), -sin(vmodel_walktime * 2)]; 

	self.origin += walkoffset;
	
	float aiming = getstatf(STAT_AIMING);
	if (aiming) aiming_lerp = min(1, aiming_lerp + frametime * 3);
	else aiming_lerp = max(0, aiming_lerp - frametime * 6);
	
	if (vlen(recoil) > 0)
	{
		recoil_pos += recoil * frametime * 85;
		recoil = move_vector_to_zero(recoil, frametime * 8);
	}
	if (vlen(recoil_pos) > 0)
	{
		recoil_pos.x = max(-14, recoil_pos.x);
		recoil_pos.y = min(max(-0.5, recoil_pos.y), 0.5);
		recoil_pos.z = min(max(-0.5, recoil_pos.z), 0.5);
		recoil_pos = move_vector_to_zero(recoil_pos, frametime * (15 + (vlen(recoil_pos) > 3) * 70));
	}
	self.origin += recoil_pos;
	self.angles = [recoil_pos.x * 0.5, recoil_pos.y * 1.5, recoil_pos.z * 2.5];
	camang += self.angles;

	current_fov = normalfov - aiming_lerp * 30;

	self.origin -= (baseoffset + '-3 0 0') * 0.6 * aiming_lerp;
	self.origin -= angle_sway * 0.7 * aiming_lerp;
	self.origin -= idleoffset * 0.5 * aiming_lerp;
	self.origin -= walkoffset * 0.4 * aiming_lerp;
	
	if (gunchange_time > 0)
	{
		vector offhand_offset = '-5 0 -14';
		vector offhand_angles = '50 60 -90';
		
		self.origin += offhand_offset * gunchange_time * gunchange_time;
		self.angles += offhand_angles * gunchange_time * gunchange_time;
		
		gunchange_time -= frametime;
	}
	
	self.frame1time += frametime;
	
	prev_angles = camang;
	prev_pos = campos;
	
	self = old_self;
};

void() draw_crosshair =
{
	float aim_penalty = getstatf(STAT_AIM_PENALTY);
	float ofs = min(256, aim_penalty);
	
	makevectors(camang);
	vector center = campos + v_forward * 8;

	R_BeginPolygon("crosshair");
	float segments = 6;
	float thickness = 0.1;
	float alpha = max(0, 1.5 - aim_penalty) * 0.3;
	for (float i = 0; i < segments; i++)
	{
		float an = (i/segments + camang_y / 360) * 2 * M_PI;
		R_PolygonVertex(center + v_up * sin(an) * (ofs + thickness) + v_right * cos(an) * (ofs + thickness), '0 0 0', '0.6 0.6 0.6', 0);
		R_PolygonVertex(center + v_up * sin(an) * ofs + v_right * cos(an) * ofs, '0 0 0', '1 1 1', alpha);
		
		an = ((i + 1)/segments + camang_y / 360) * 2 * M_PI;
		
		R_PolygonVertex(center + v_up * sin(an) * ofs + v_right * cos(an) * ofs, '0 0 0', '1 1 1', alpha);
		R_PolygonVertex(center + v_up * sin(an) * (ofs + thickness) + v_right * cos(an) * (ofs + thickness), '0 0 0', '0.6 0.6 0.6', 0);
		R_EndPolygon();
	}
	
	
	/*
	float chsize = 16;
	drawfill([g_width/2 - chsize - ofs, g_height/2], [chsize, 1], [0.1, 0.8, 0], 0.8, 1);
	drawfill([g_width/2 + ofs + 1, g_height/2], [chsize, 1], [0.1, 0.8, 0], 0.8, 1);
	drawfill([g_width/2, g_height/2 - chsize - ofs], [1, chsize], [0.1, 0.8, 0], 0.8, 1);
	drawfill([g_width/2, g_height/2 + ofs + 1], [1, chsize], [0.1, 0.8, 0], 0.8, 1);
	
	drawstring([50, 200], sprintf("%f, %f", g_width, g_height), '8 8 0', '1 1 1', 1, 0);
	*/
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
	skybox = spawn();
	setmodel(skybox, "models/skybox.iqm");
	// skybox.scale = 2;
	
	viewmodel = spawn();
	// setmodel(viewmodel, "models/mp5.iqm");
	viewmodel_mzl = spawn();
	// setmodel(viewmodel_mzl, "models/mp5_mzl.iqm");
	// viewmodel.drawmask = MASK_ENGINE;
	viewmodel.renderflags = RF_VIEWMODEL;
	viewmodel_mzl.renderflags = RF_VIEWMODEL;
	// viewmodel.predraw = viewmodel_draw;
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
	normalfov = getproperty(VF_AFOV);
	
	viewmodel_update();
	
	setproperty(VF_ANGLES, camang);
	setproperty(VF_ORIGIN, campos);
	setproperty(VF_AFOV, current_fov);

	addentity(skybox);
	renderscene();
	
	clearscene();
	//autoadd entities received from servers for drawing
	addentities(MASK_ENGINE);
	addentity(viewmodel);
	
	if (viewmodel_mzl.alpha > 0)
	{
		addentity(viewmodel_mzl);
		viewmodel_mzl.colormod = [viewmodel_mzl.alpha * 1.25, viewmodel_mzl.alpha * 1.25, viewmodel_mzl.alpha * 1.25];
		viewmodel_mzl.origin = viewmodel.origin;
		viewmodel_mzl.angles = viewmodel.angles;
		viewmodel_mzl.frame1time += frametime * 0.25;
		viewmodel_mzl.frame1time += 0.5;
		addentity(viewmodel_mzl);
		viewmodel_mzl.frame1time -= 0.5;
		
		viewmodel_mzl.alpha -= frametime * 35;
	}

	draw_crosshair();

	setproperty(VF_ANGLES, camang);
	setproperty(VF_ORIGIN, campos);
	setproperty(VF_AFOV, current_fov);
	
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
		case EVENT_RECOIL:
			float amount = readbyte() / 100;
			recoil += [-amount, amount * srandom() * 0.2, amount * srandom() * 0.2];
			if (vlen(recoil) > 2) recoil = normalize(recoil) * 2;
			viewmodel_mzl.alpha = random();
			viewmodel_mzl.frame1time = random() * 10;
			viewmodel.frame1time = 0;
			viewmodel.frame = 2;
			// viewmodel_mzl.scale = 0.95 + random() * 0.2;
			// pointparticles(particleeffectnum("weapons.muzzle1"), campos += v_forward * (viewmodel.origin.x + 2) - v_right * (viewmodel.origin.y * 0.5) + v_up * (viewmodel.origin.z * 0.5));
			break;
		case EVENT_RELOAD:
			viewmodel.frame = 3;
			viewmodel.frame1time = 0;
			break;
		case EVENT_CHARGE:
			viewmodel.frame = 4;
			viewmodel.frame1time = 0;
			break;
		case EVENT_SETGUN:
			float guntype = readbyte();
			setmodel(viewmodel, get_gun_model(guntype));
			setmodel(viewmodel_mzl, get_muzzleflash_model(guntype));
			viewmodel.frame = 0;
			gunchange_time = 0.6;
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
