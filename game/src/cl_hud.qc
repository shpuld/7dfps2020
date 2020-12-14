
float time_without_ammo;

void(entity viewmodel, float zoom) draw_hud =
{
	if (in_menu != MENU_NONE) return;
	
	if (damage_amount > 0)
	{
		drawfill([0, 0], [g_width, g_height], '0.8 0.1 0.05', sin(time * 8) * (damage_amount / 100) * 0.1, 0);
		drawfill([0, 0], [g_width, g_height], '1 0.1 0.05', damage_amount / 100, 1);	
		damage_amount -= frametime * 5;
	}

	makevectors(camang);
	vector hudsize = [42 * 4 + 8, 28];
	vector basepos = project(campos + v_forward * (viewmodel.origin.x + 2 + zoom * 12) - v_right * viewmodel.origin.y + v_up * (viewmodel.origin.z - 4 + zoom * 6)) - [hudsize.x, 0];
	basepos = [floor(basepos.x*2)/2, floor(basepos.y*2)/2];
	// vector basepos = [8, g_height - 8 - hudsize.y];
	drawfill(basepos, hudsize, '0 0 0', 0.6);
	
	float hp = max(0, getstatf(STAT_HEALTH));
	float frac = hp / getstatf(STAT_MAX_HEALTH);
	
	drawfill([basepos.x + 4, basepos.y + 4], [(hudsize.x - 8) * frac, 8], '1 1 1', 0.3);
	string hpstr = sprintf("%3.0f", hp);
	drawpic([basepos.x + hudsize.x - strlen(hpstr) * 8 - 12, basepos.y + 4], "textures/heart", [8, 8], '1 1 1', 1, 0);
	drawstring([basepos.x + hudsize.x - strlen(hpstr) * 8 - 4, basepos.y + 4], hpstr, [8, 8], '1 1 1', 1, 0);
	
	float mag = getstatf(STAT_MAGAZINE);
	float chambered = getstatf(STAT_CHAMBERED);
	float reserve = getstatf(STAT_RESERVE);
	
	float bulletw = 3;
	float bulleth = 8;
	float i;
	for (i = 0; i < mag; i++)
	{
		drawfill([basepos.x + 4 + i * (bulletw+1), basepos.y + hudsize.y - 4 - bulleth], [bulletw, bulleth], '1 1 1', 0.3);
	}
	if (chambered)
	{
		drawfill([basepos.x + 4 + i * (bulletw+1), basepos.y + hudsize.y - 4 - bulleth], [bulletw, bulleth], '1 1 1', 0.8);
	}
	
	string ammocount = sprintf("%.0f/%.0f", mag + chambered, reserve);
	drawstring([basepos.x + hudsize.x - strlen(ammocount) * 8 - 4, basepos.y + hudsize.y - 4 - 8], ammocount, [8, 8], '1 1 1', 1, 0);
	
	if ((mag + chambered) <= 0 && viewmodel.frame != 3)
	{
		time_without_ammo = min(1, time_without_ammo + frametime);
		tokenize(findkeysforcommand("impulse 10"));
		string keyname = keynumtostring(stof(argv(0)));
		string message = sprintf("Press %s to Reload", keyname);
		if (reserve <= 0)
			message = "Get more ammo from the vehicle";
		
		drawstring([g_width/2 - strlen(message) * 4, g_height/2 + 64], message, [8, 8], '1 1 1', time_without_ammo, 0);
	}
	else
	{
		time_without_ammo = 0;
	}
	
	float objectives_completed = getstatf(STAT_OBJS_COMPLETED);
	float total_objectives = getstatf(STAT_NUM_OBJS);
	if (objectives_completed != old_objectives_completed)
	{
		show_objective_time = time;
		old_objectives_completed = objectives_completed;
	}

	if (time >= show_objective_time)
	{
		string temps = objective_text();
		string objstring = sprintf(temps, objectives_completed, total_objectives); 
		if (objectives_completed == total_objectives)
		{
			objstring = "Return to vehicle";
			vector objpos = project('-32 -32 80');
			string extstr = "Extraction point";
			if (objpos.z > 0)
				drawstring(objpos - [strlen(extstr) * 4, -4], extstr, [8, 8], '1 1 1', 1, 0);
		}
		hudsize = [8 * strlen(objstring) + 8, 24];
		
		float showlength = 8;
		float lerp = 1;
		if ((time - show_objective_time) < 0.5) lerp = (time - show_objective_time) * 2;
		if ((time - show_objective_time) > (showlength - 0.5)) lerp = (showlength - (time - show_objective_time)) * 2;
		
		if (lerp >= 1 && objectives_completed >= total_objectives)
			show_objective_time = time - 2;

		basepos = [g_width - hudsize.x*lerp, g_height - 64];
		drawfill(basepos, hudsize, '0 0 0', 0.6);
		drawstring([basepos.x + 4, basepos.y + 4], "Objective:", [8, 8], '1 1 1', 1, 0);
		drawstring([basepos.x + 4, basepos.y + 4 + 8], objstring, [8, 8], '1 1 1', 1, 0);
		
		if (time > (show_objective_time + showlength))
			show_objective_time = time + 48;
	}
	
	if (time < (hack_time + 0.6))
	{
		string hacktext = "Hold FIRE to hack";
		if (holding_fire) hacktext = sprintf("Hacking... %.0f%%", (1 - hack_done / hack_total) * 100);
		if (hack_done <= 0) hacktext = "Comms tower hacked";
		drawfill([g_width / 2 - strlen(hacktext) * 4 - 4, g_height / 2 + 32], [strlen(hacktext) * 8 + 8, 16], '0 0 0', 0.6, 0);
		drawstring([g_width / 2 - strlen(hacktext) * 4, g_height / 2 + 32 + 4], hacktext, [8, 8], '1 1 1', 1, 0);
	}


	if (die_time)
	{
		float alpha = min(1.0, (time - die_time) * 0.5);
		drawfill([0, 0], [g_width, g_height], '0 0 0', alpha, 0);
		
		float alldead = TRUE;
		for (int i = 0; i < player_team.length; i++)
		{
				if (player_team[i].firstname != "") alldead = FALSE;
		}
		
		string deathmessage = sprintf("%s has fallen.", character_name);
		float textsize = 16;
		drawstring([g_width/2 - strlen(deathmessage) * textsize * 0.5, g_height / 2 - textsize * 0.5], deathmessage, [textsize, textsize], '1 1 1', alpha, 0);
		
		if (alldead)
		{
			deathmessage = "Your team has been wiped out.";
			drawstring([g_width/2 - strlen(deathmessage) * textsize * 0.5, g_height / 2 - textsize * 0.5 + 48], deathmessage, [textsize, textsize], '1 1 1', alpha, 0);
			deathmessage = "Game over";
			drawstring([g_width/2 - strlen(deathmessage) * textsize * 0.5, g_height / 2 - textsize * 0.5 + 64], deathmessage, [textsize, textsize], '1 1 1', alpha, 0);
		}
		
		if ((time - die_time) > 5 && in_menu == MENU_NONE && !alldead)
			set_menu(MENU_PICK);
	}
	
	if (complete_time)
	{
		float alpha = min(1.0, (time - complete_time) * 0.5);
		drawfill([0, 0], [g_width, g_height], '0 0 0', alpha, 0);
		
		string winmessage = "Mission completed";
		float textsize = 16;
		drawstring([g_width/2 - strlen(winmessage) * textsize * 0.5, g_height / 2 - textsize * 0.5], winmessage, [textsize, textsize], '1 1 1', alpha, 0);
		
		/*
		if ((time - die_time) > 5 && in_menu == MENU_NONE)
			set_menu(MENU_PICK);
		*/
	}
}