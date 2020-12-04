
// CLIENT BLOCK

float grid_size;

float last_scroll_time;

float view_unlocked;

// Call this in CSQC_Init
void() cl_editor_init =
{
	registercommand("toggleeditmode");
	
	grid_size = 16;
}

float selected_entity_index;

string entlist[] = {
	"misc_barrel"
};

vector entity_menu_scroll;

string editor_selection_org;
string editor_selection_ang;
string editor_selection_spawnflags;
string editor_selection_target;
string editor_selection_targetname;

void() send_org = { localcmd(sprintf("cmd edit_setprop origin %s\n", editor_selection_org)); }
void() send_ang = { localcmd(sprintf("cmd edit_setprop angles %s\n", editor_selection_ang)); }
void() send_spawnflags = { localcmd(sprintf("cmd edit_setprop spawnflags %s\n", editor_selection_spawnflags)); }
void() send_target = { localcmd(sprintf("cmd edit_setprop target %s\n", editor_selection_target)); }
void() send_targetname = { localcmd(sprintf("cmd edit_setprop targetname %s\n", editor_selection_targetname)); }

void(string id, vector pos, vector size, __inout vector scrollofs) entity_list =
{
	sui_fill(pos, size, '0.2 0.2 0.2', 0.75, 0);
	sui_list_view_begin(strcat(id, "scrl"), pos, size, [size_x - 6, 16], entlist.length, scrollofs, [0, 6]);
	vector listitem_pos = '0 0 0';
	for (float index = sui_list_item(listitem_pos); index > -1; index = sui_list_item(listitem_pos))
	{
		sui_push_frame(listitem_pos, [size_x - 6, 16]);
		string iid = strcat(id, ftos(index));
		sui_action_element([0, 0], [size_x -6, 16], iid, sui_noop);
		if (sui_is_hovered(iid)) sui_fill([0, 0], [size_x - 6, 16], '1 1 1', 0.1, 0);
		if (sui_is_clicked(iid)) selected_entity_index = index;
		sui_set_align([SUI_ALIGN_START, SUI_ALIGN_CENTER]);
		if (selected_entity_index == index)
			sui_fill([0, 0], [size_x - 6, 16], '1 1 1', 0.2, 0);
		sui_text([0, 0], [8, 8], entlist[index], '1 1 1', 1, 0);
		sui_pop_frame();
	}
	sui_list_view_end();	
}

var void() current_apply;
void() no_apply = {};
float prop_editor_cursor;
void(string id, vector pos, vector size, string label, __inout string str, void() apply) entity_prop_input =
{
	sui_push_frame(pos, size);
	vector tsize = [size_y/2, size_y/2];
	string inid = strcat("in_", id);
	string before = str;
	sui_text([0, 0], tsize, label, '1 1 1', 1, 0);
	sui_text_input(inid, [0, tsize_y], [size_x, tsize_y], str, prop_editor_cursor);
	sui_fill([0, tsize_y], [size_x, tsize_y], '0.2 0.2 0.2', 0.5, 0);
	sui_text([0, tsize_y], tsize, str, '1 1 1', 1, 0);
	if (sui_is_last_clicked(inid))
	{
		sui_fill([tsize_x*prop_editor_cursor, tsize_y], tsize, '1 1 1', 0.5, 0);
		current_apply = apply;
	}

	sui_pop_frame();
}


void(vector pos, vector size) entity_prop_editor =
{
	sui_fill(pos, size, '0 0 0', 0.5, 0);
	float xpos = 4;
	float ypos = 4;
	float insize = 16;
	
	entity_prop_input("org", [xpos, ypos], [size_x - 8, insize], "Origin", editor_selection_org, send_org);
	ypos += insize;
	entity_prop_input("ang", [xpos, ypos], [size_x - 8, insize], "Angles", editor_selection_ang, send_ang);
	ypos += insize;
	entity_prop_input("sf", [xpos, ypos], [size_x - 8, insize], "Spawnflags", editor_selection_spawnflags, send_spawnflags);
	ypos += insize;
	entity_prop_input("target", [xpos, ypos], [size_x - 8, insize], "Target", editor_selection_target, send_target);
	ypos += insize;
	entity_prop_input("targetname", [xpos, ypos], [size_x - 8, insize], "Targetname", editor_selection_targetname, send_targetname);
	ypos += insize;
}

void() cl_editor_draw =
{
	if (!getstatf(STAT_ED_MODE)) return;
	
	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_END]);
	sui_text([0, -8], [16, 16], "EDIT MODE", '1 0.1 0.1', 1, 0);
	sui_text([0, -32], [8, 8], sprintf("Grid size: %d", grid_size), '1 1 1', 1, 0);
	
	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_CENTER]);
	sui_fill([0, 0], [4, 4], '0 0 0', 0.5, 0);
	sui_fill([0, 0], [2, 2], '1 1 1', 0.75, 0);
	
	vector ent_menu_size = [140, 200];
	sui_set_align([SUI_ALIGN_START, SUI_ALIGN_END]);
	sui_push_frame([0, 0], ent_menu_size);
	
	sui_fill([0, 0], ent_menu_size, '0 0 0', 0.5, 0);
	entity_list("entlist", [0, 0], ent_menu_size - [2, 2], entity_menu_scroll);
	
	sui_pop_frame();
	
	sui_set_align([SUI_ALIGN_END, SUI_ALIGN_END]);
	ent_menu_size = [140, 140];
	sui_push_frame([0, 0], ent_menu_size);
	entity_prop_editor([0, 0], ent_menu_size);
	
	sui_pop_frame();
	
	cheats_used = TRUE;
}

void() cl_editor_update_selection =
{
	editor_selection_org = sprintf("%v", readvector());
	editor_selection_ang = sprintf("%v", readvector());
	editor_selection_spawnflags = sprintf("%.0f", readfloat());
	editor_selection_target = readstring();
	editor_selection_targetname = readstring();
}

// This must be called in CSQC_ConsoleCommand
// input entity self
// input string cmd: same as in CSQC_ConsoleCommand
// output float: TRUE if command was handled, FALSE if not
float(string cmd) cl_editor_command =
{
	float argc = tokenize(cmd);
	switch (argv(0))
	{
	case "toggleeditmode":
		if (getstatf(STAT_ED_MODE)) setcursormode(FALSE);
		else setcursormode(TRUE);

		localcmd("cmd toggleeditmode\n");
		return TRUE;
		break;
	default: break;
	}
	return FALSE;
}

float(float evtype, float scanx, float chary, float devid) cl_editor_input_event =
{
	if (!getstatf(STAT_ED_MODE)) return FALSE;
	
	switch(evtype)
	{
	case IE_KEYDOWN:
		if (substring(sui_get_last_clicked(), 0, 3) == "in_") return TRUE;
		
		if (chr2str(chary) == "n") {
			localcmd(sprintf("cmd edit_add %s\n", entlist[selected_entity_index]));
		}
		if (scanx == K_MOUSE1) { 
			if (!getcursormode(TRUE))
				localcmd("cmd edit_select\n");
			return TRUE;
		}
		if (scanx == K_UPARROW) { localcmd("cmd edit_move 0\n"); return TRUE; }
		if (scanx == K_DOWNARROW) { localcmd("cmd edit_move 1\n"); return TRUE; }
		if (scanx == K_LEFTARROW)
		{
			if (ctrl_held && shift_held)
				localcmd("cmd edit_rotate 15\n");
			else if (shift_held)
				localcmd("cmd edit_rotate 45\n");
			else
				localcmd("cmd edit_move 2\n");
			return TRUE;
		}
		if (scanx == K_RIGHTARROW)
		{
			if (ctrl_held && shift_held)
				localcmd("cmd edit_rotate -15\n");
			else if (shift_held)
				localcmd("cmd edit_rotate -45\n");
			else
				localcmd("cmd edit_move 3\n");
			return TRUE;
		}
		if (scanx == K_PGUP) { localcmd("cmd edit_move 4\n"); return TRUE; }
		if (scanx == K_PGDN) { localcmd("cmd edit_move 5\n"); return TRUE; }
		if (scanx == K_DEL) { localcmd("cmd edit_delete\n"); return TRUE; }
		
		if (scanx == K_MOUSE2) { setcursormode(FALSE); return TRUE; }
		break;
	case IE_KEYUP:
		if (scanx == K_MWHEELUP) 
		{
			if (time - last_scroll_time < 0.1) return FALSE;
			grid_size *= 2;
			grid_size = min(256, grid_size);
			localcmd(sprintf("cmd edit_grid %f\n", grid_size));
			last_scroll_time = time;
			return TRUE;
		}
		if (scanx == K_MWHEELDOWN) 
		{
			if (time - last_scroll_time < 0.1) return FALSE;
			grid_size *= 0.5;
			grid_size = max(1, grid_size);
			localcmd(sprintf("cmd edit_grid %f\n", grid_size));
			last_scroll_time = time;
			return TRUE;
		}
		
		if (scanx == K_ENTER)
		{
			if (current_apply) current_apply();
			current_apply = no_apply;
			return TRUE;
		}
		
		if (scanx == K_MOUSE2) { setcursormode(TRUE); return TRUE; }
		break;
	case IE_MOUSEDELTA:
		break;
	case IE_MOUSEABS:
		break;
	}
	
	return FALSE;
}
