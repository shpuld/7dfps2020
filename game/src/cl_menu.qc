
float(string id, vector pos, vector size, string text) my_button =
{
	sui_push_frame(pos, size);
	vector basecolor = sui_is_hovered(id) ? MENU_BUTTON + MENU_HIGHLIGHT * 0.1 : MENU_BUTTON; 
	basecolor = sui_is_held(id) ? MENU_BUTTON - MENU_DARKEN * 0.1 : basecolor;
	sui_fill([0, 0], size, basecolor, 0.6, 0);
	sui_border_box([0, 0], size, 1, MENU_BUTTON_BORDER, 0.4, 0);
	
	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_CENTER]);
	sui_text([0, 0], MENU_TEXT_SMALL, text, MENU_TEXT_1, 1, 0);	
	sui_action_element([0, 0], size, id, sui_noop);
	sui_pop_frame();
	
	return sui_is_clicked(id);
};

void(float menu) set_menu =
{
	if (menu == MENU_NONE)
	{
		setcursormode(FALSE);
		in_menu = MENU_NONE;
		return;
	}
	setcursormode(TRUE);
	in_menu = menu;
}



float team_member_selected;
float recruitable_selected;

void(float own_team, vector framesize) draw_team =
{
	if (own_team)
		sui_set_align([SUI_ALIGN_START, SUI_ALIGN_CENTER]);
	else
		sui_set_align([SUI_ALIGN_END, SUI_ALIGN_CENTER]);

	vector col_size = [framesize.x / 2 - 4, 24 + 22 * 8 + 2 + 16];
	sui_push_frame([0, 0], col_size);
	
	sui_fill([0, 0], col_size, '0 0 0', 0.5, 0);

	if (own_team)
		sui_text([4, 4], [8, 8], "Your Team:", '1 1 1', 1, 0);
	else
		sui_text([4, 4], [8, 8], "Soldiers to recruit:", '1 1 1', 1, 0);

	float ypos = 24;
	
	soldier* soldiers = own_team ? player_team : recruitable;
	float len = own_team ? player_team.length : recruitable.length;
	float select = own_team ? team_member_selected : recruitable_selected;
	for (int i = 0; i < len; i++)
	{
		soldier* guy = &(soldiers[i]);
		if (guy->firstname == "") continue;
		string nm = own_team ? sprintf("tmb%i", i) : sprintf("rec%i", i);
		vector npos = [4, ypos + 22 * i];
		if (own_team)
			my_button(nm, npos, [128, 20], soldier_name(guy)) ? team_member_selected = i : 0;
		else
			my_button(nm, npos, [128, 20], soldier_name(guy)) ? recruitable_selected = i : 0;

		if (select == i)
			sui_fill(npos, [128, 20], '0 0 0', 0.4, 0);
		// sui_pop_frame();
	}
	soldier* selected = &(soldiers[select]);
	float xpos = 4 + 128 + 16;
	ypos = 24;
	
	if (selected->firstname == "") 
	{
		sui_pop_frame();
		return;
	}
	
	sui_text([xpos, ypos], [8, 8], soldier_name(selected), '1 1 1', 1, 0);
	ypos += 16;
	
	sui_text([xpos, ypos], [8, 8], "Speed:", '1 1 1', 1, 0);
	ypos += 8;
	for (int i = 0; i < 8; i++)
		sui_fill([xpos + 12 * i, ypos + 2], [10, 6], '1 1 1', i > selected->speed ? 0.1 : 0.8, 0);
	ypos += 20;
	
	sui_text([xpos, ypos], [8, 8], "Accuracy:", '1 1 1', 1, 0);
	ypos += 8;
	for (int i = 0; i < 8; i++)
		sui_fill([xpos + 12 * i, ypos + 2], [10, 6], '1 1 1', i > selected->accuracy ? 0.1 : 0.8, 0);
	ypos += 20;
	
	sui_text([xpos, ypos], [8, 8], "Vitality:", '1 1 1', 1, 0);
	ypos += 8;
	for (int i = 0; i < 8; i++)
		sui_fill([xpos + 12 * i, ypos + 2], [10, 6], '1 1 1', i > selected->vitality ? 0.1 : 0.8, 0);
	ypos += 20;
	
	sui_text([xpos, ypos], [8, 8], "Weapon:", '1 1 1', 1, 0);
	ypos += 8;
	sui_text([xpos+8, ypos], [8, 8], get_gun_name(selected->weapontype), '1 1 1', 1, 0);
	ypos += 20;
	
	if (!own_team)
	{
		sui_text([xpos, ypos], [8, 8], "Cost:", '1 1 1', 1, 0);
		ypos += 8;
		sui_text([xpos+8, ypos], [8, 8], sprintf("%.0f Credits", selected->cost), '1 1 1', 1, 0);
	}
	
	if (!own_team)
	{
		sui_set_align([SUI_ALIGN_END, SUI_ALIGN_END]);
		
		if (is_team_full())
			sui_text([-4, -4], [8, 8], "Team full", '1 1 1', 1, 0);
		else if (getstatf(STAT_CREDITS) < selected->cost)
			sui_text([-4, -4], [8, 8], "Not enough credits", '1 1 1', 1, 0);
		else
			my_button("hire", [-4, -4], [80, 20], "Hire") ? localcmd(sprintf("cmd hire %.0f\n", recruitable_selected)) : 0;
			
	}
	else
	{
		sui_set_align([SUI_ALIGN_START, SUI_ALIGN_END]);
		sui_text([4, -4], [8, 8], sprintf("Credits: %.0f", getstatf(STAT_CREDITS)), '1 1 1', 1, 0);
	}
	
	sui_pop_frame();
}

void() draw_menu =
{
	if (in_menu == MENU_NONE) return;

	sui_fill([0, 0], [g_width, g_height], '0 0 0', 0.6, 0);

	vector framesize = [g_width - 16, g_height - 16];
	sui_push_frame([8, 8], framesize);

	switch (in_menu)
	{
	case MENU_TEAM:
		sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_START]);
		sui_text([0, 0], [16, 16], "Team Management", '1 1 1', 1, 0);
		
		draw_team(TRUE, framesize);
		draw_team(FALSE, framesize);
		
		sui_set_align([SUI_ALIGN_START, SUI_ALIGN_END]);
		sui_fill([0, 0], [framesize.x, 40], '0 0 0', 0.5, 0);
		my_button("quitmngment", [4, -4], [128, 32], "Save & Quit") ? print("save & quit not implemented yet\n") : 0;
		sui_set_align([SUI_ALIGN_END, SUI_ALIGN_END]);
		my_button("briefing", [-4, -4], [128, 32], "Briefing") ? set_menu(MENU_BRIEFING) : 0;
		break;
	case MENU_BRIEFING:
		sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_START]);
		sui_text([0, 0], [16, 16], "Briefing", '1 1 1', 1, 0);

		draw_team(TRUE, framesize);

		sui_set_align([SUI_ALIGN_START, SUI_ALIGN_END]);
		sui_fill([0, 0], [framesize.x, 40], '0 0 0', 0.5, 0);
		my_button("quitmngment", [4, -4], [128, 32], "Save & Quit") ? print("save & quit not implemented yet\n") : 0;
		sui_set_align([SUI_ALIGN_END, SUI_ALIGN_END]);
		if (my_button("deploy", [-4, -4], [128, 32], "Deploy")) 
		{
			localcmd(sprintf("cmd deploy %.0f\n", team_member_selected));
			set_menu(MENU_NONE);
		}
		break;
	default: break;
	}
	
	sui_pop_frame();
}
