
// SERVER BLOCK

// moved to sv_customdefs
// float edit_mode;

struct editor_ent
{
	vector origin;
	vector angles;
	vector mins;
	vector maxs;
	vector colormod;
	float scale;
	float solid;
	float alpha;
	string model;
	string classname;
	string target;
	string targetname;
	float spawnflags;
};

// two-way connection, client knows what entity he is editing, and entity knows who is editing it
.entity editor_selection;
.float editor_grid_size;

// entity properties
.float is_edent;
.editor_ent * edent;

void(entity e) editor_send_selection;

void(entity e) editor_reset_ent
{
	setorigin(e, e.edent->origin);
	e.angles = e.edent->angles;
	e.scale = e.edent->scale;
	e.solid = e.edent->solid;
	e.velocity = '0 0 0';
	e.avelocity = '0 0 0';
	e.movetype = MOVETYPE_NONE;
	setmodel(e, e.edent->model);
	setsize(e, e.edent->mins,  e.edent->maxs);
	e.classname = e.edent->classname;
	e.alpha = e.edent->alpha;
	e.target = e.edent->target;
	e.targetname = e.edent->targetname;
	e.spawnflags = e.edent->spawnflags;
	e.nextthink = 0;
	e.flags = 0;
	e.touch = sub_noop;
	e.frame = 0;
}

void(entity e) editor_delete_ent =
{
	if (!e.is_edent)
	{
		print("Tried to delete a non-ed-ent\n");
		return;
	}
	if (e.editor_selection)
		e.editor_selection.editor_selection = world;
	memfree(e.edent);
	remove(e);
}


void(entity e, editor_ent * ed_ent) editor_copy_to_edent =
{
	ed_ent->origin = e.origin;
	ed_ent->angles = e.angles;
	ed_ent->mins = e.mins;
	ed_ent->maxs = e.maxs;
	ed_ent->colormod = e.colormod;
	ed_ent->scale = e.scale;
	ed_ent->solid = e.solid;
	ed_ent->alpha = e.alpha;
	ed_ent->model = e.model;
	ed_ent->classname = e.classname;
	ed_ent->target = e.target;
	ed_ent->targetname = e.targetname;
	ed_ent->spawnflags = e.spawnflags;
}

void(float filehandle, entity e) editor_write_ent =
{
	fputs(filehandle, "ent_begin\n");
	fputs(filehandle, sprintf("class %s\n", e.edent->classname));
	fputs(filehandle, sprintf("organg %v %v\n", e.edent->origin, e.edent->angles));
	if (e.edent->target != "")
		fputs(filehandle, sprintf("target %s\n", e.edent->target));
	if (e.edent->targetname != "")
		fputs(filehandle, sprintf("targetname %s\n", e.edent->targetname));
	if (e.edent->spawnflags)
		fputs(filehandle, sprintf("spawnflags %.0f\n", e.edent->spawnflags));
		
	fputs(filehandle, "end\n");
}

float(entity e, string type) editor_set_ent_type;
float(entity e) editor_init_edent;

void(float filehandle) editor_read_ent =
{
	float argc;
	string line = fgets(filehandle);
	entity e = spawn();
	while (line && line != "end")
	{
		argc = tokenize(line);
		switch (argv(0))
		{
		case "class":
			e.classname = argv(1);
			break;
		case "organg":
			setorigin(e, [stof(argv(1)), stof(argv(2)), stof(argv(3))]);
			e.angles = [stof(argv(4)), stof(argv(5)), stof(argv(6))];
			break;
		case "target":
			e.target = argv(1);
			break;
		case "targetname":
			e.targetname = argv(1);
			break;
		case "spawnflags":
			e.spawnflags = stof(argv(1));
			break;
		case "ent_begin":
			print("!!!!! BROKEN FILE !!!!!\n! ent_begin before end !\n");
			break;
		default:
			printf("Unknown parm %s\n", argv(0));
			break;
		}
		line = fgets(filehandle);
	}
	
	float success = editor_set_ent_type(e, e.classname);
	if (!success)
	{
		print("Invalid entity spawned\n");
		remove(e);
		return;
	}
	editor_init_edent(e);
}

float(entity e, string type) editor_set_ent_type =
{
	e.classname = type;
	switch (type)
	{
	case "misc_barrel":
		setmodel(e, "models/barrel.iqm");
		e.scale = 1;
		e.solid = SOLID_BBOX;
		setsize(e, '-12 -12 0', '12 12 36');
		break;
	default: return FALSE;
	}
	
	return TRUE;
}

float(entity e) editor_init_edent =
{
	e.is_edent = TRUE;
	e.edent = memalloc(sizeof(editor_ent));
	if (!e.edent) {
		e.is_edent = FALSE;
		return FALSE;
	}
	
	editor_copy_to_edent(e, e.edent);
	return TRUE;
}

vector(vector coord) editor_snap_to_grid =
{
	float size = 16;
	return [rint(coord_x/size)*size, rint(coord_y/size)*size, rint(coord_z/size)*size];
}

void(entity selector, entity selectee) editor_set_select =
{	
	// Unselect first
	if (selector.editor_selection)
	{
		if (selector.editor_selection.editor_selection)
			selector.editor_selection.editor_selection = world;
		selector.editor_selection.effects -= self.editor_selection.effects & EF_FULLBRIGHT;
		selector.editor_selection = world;
	}
	
	if (!selectee.is_edent) return;
	
	selector.editor_selection = selectee;
	selectee.editor_selection = self;
	selectee.effects |= EF_FULLBRIGHT;
}

void() editor_select_ent =
{
	if (!edit_mode) return;
	
	
	makevectors(self.v_angle);
	traceline(self.origin + self.view_ofs, self.origin + self.view_ofs + v_forward * 8096, MOVE_EVERYTHING, self);
	
	editor_set_select(self, trace_ent);
	
	editor_send_selection(trace_ent);
}

void(entity e, vector org) editor_set_origin =
{
	if (!e.is_edent) return;
	setorigin(e, org);
	e.edent->origin = org;
	
	editor_send_selection(e);
}

void(float dir) editor_move_selection =
{
	if (!self.editor_selection) return;
	entity e = self.editor_selection;
	
	makevectors([0, rint(self.v_angle_y/90)*90, 0]);
	
	float amount = self.editor_grid_size > 0 ? self.editor_grid_size : 16;
	
	if (dir == 0) editor_set_origin(e, e.origin + v_forward * amount);
	if (dir == 1) editor_set_origin(e, e.origin - v_forward * amount);
	if (dir == 2) editor_set_origin(e, e.origin - v_right * amount);
	if (dir == 3) editor_set_origin(e, e.origin + v_right * amount);
	if (dir == 4) editor_set_origin(e, e.origin + v_up * amount);
	if (dir == 5) editor_set_origin(e, e.origin - v_up * amount);
}

void(float angle) editor_rotate_selection =
{
	if (!self.editor_selection) return;
	entity e = self.editor_selection;
	if (!e.is_edent) return;
	
	e.angles_y += angle;
	e.edent->angles.y = e.angles_y;
	
	editor_send_selection(e);
}

void(string type) editor_add_ent = 
{
	if (!edit_mode) return;
	
	entity new_ent = spawn();
	
	vector pos;
	makevectors(self.v_angle);
	traceline(self.origin + self.view_ofs, self.origin + self.view_ofs + v_forward * 8096, 0, self);
	if (trace_fraction == 1) 
		pos = self.origin + self.view_ofs + v_forward * 512;
	else
		pos = trace_endpos;
		
	setorigin(new_ent, editor_snap_to_grid(pos));
	
	new_ent.angles = [0, rint(self.angles_y / 90) * 90, 0];
	
	float success = editor_set_ent_type(new_ent, type);
	
	if (!success)
	{
		printf("Unknown entity type %s\n", type);
		remove(new_ent);
		return;
	}
	
	success = editor_init_edent(new_ent);
	
	if (!success)
	{
		printf("Could not memalloc for entity %s\n", type);
		remove(new_ent);
		return;
	}
	
	editor_set_select(self, new_ent);
	
	editor_send_selection(new_ent);
}

void(string filename) editor_save_ents =
{
	if (filename == "default") filename = cvar_string("mapname");
	if (filename == "")
	{
		print("edit_save: will not save without filename\n");
		print("edit_save: use 'edit_save default' for map default ents\n");
	}
	
	filename = strcat(filename, ".ef");
	printf("Saving into %s\n", filename);
	
	float filehandle = fopen(filename, FILE_WRITE);
	entity ed_ent = findfloat(world, is_edent, TRUE);
	while (ed_ent)
	{
		editor_write_ent(filehandle, ed_ent);
		ed_ent = findfloat(ed_ent, is_edent, TRUE);
		fputs(filehandle, "\n");
	}
	
	fclose(filehandle);
}

void(string filename) editor_load_ents =
{
	if (filename == "default") filename = cvar_string("mapname");
	
	filename = strcat(filename, ".ef");
	// printf("Loading from %s\n", filename);
	
	float filehandle = fopen(filename, FILE_READ);
	
	string line = fgets(filehandle);
	
	while (line)
	{
		tokenize(line);
		
		switch (argv(0))
		{
		case "ent_begin":
			editor_read_ent(filehandle);
			break;
		default:
			if (argv(0) == "") break;
			if (substring(argv(0), 0, 1) == "#") break;
			printf("Unknown line %s in %s\n", line, filename);
			break;
		}
		
		line = fgets(filehandle);
	}
	
	fclose(filehandle);
}


float() entcustomize =
{
	if (self.origin_z > -100 && other.origin.z < -100) return FALSE;
	if (self.origin_z < -100 && other.origin.z > -100) return FALSE;
	return TRUE;
}

void() editor_play =
{
	entity ed_ent = findfloat(world, is_edent, TRUE);


	while (ed_ent)
	{
		// ed_ent.customizeentityforclient = entcustomize;
		withself(ed_ent, callfunction(ed_ent.classname));
		ed_ent = findfloat(ed_ent, is_edent, TRUE);
	}

}

void() editor_reset =
{
	entity ed_ent = findfloat(world, is_edent, TRUE);
	while (ed_ent)
	{
		editor_reset_ent(ed_ent);
		ed_ent = findfloat(ed_ent, is_edent, TRUE);
	}
}

void(entity e) editor_send_selection =
{
	if (!e.editor_selection) return;
	msg_entity = e.editor_selection;
	BeginEvent(EV_ED_UPDATE);
	MulticastVector(e.origin);
	MulticastVector(e.angles);
	MulticastFloat(e.spawnflags);
	MulticastString(e.target);
	MulticastString(e.targetname);
	multicast('0 0 0', MULTICAST_ONE_R);
}

void(float argc) editor_set_property =
{
	if (!self.editor_selection) return;
	entity e = self.editor_selection;
	switch (argv(1))
	{
	case "origin":
		vector org = [stof(argv(2)), stof(argv(3)), stof(argv(4))];
		editor_set_origin(e, org);
		break;
	
	case "angles":
		vector ang = [stof(argv(2)), stof(argv(3)), stof(argv(4))];
		e.angles = ang;
		e.edent->angles = ang;
		break;
	
	case "target":
		e.target = argv(2);
		e.edent->target = argv(2);
		break;
	
	case "targetname":
		e.targetname = argv(2);
		e.edent->targetname = argv(2);
		break;
		
	case "spawnflags":
		e.spawnflags = stof(argv(2));
		e.edent->spawnflags = e.spawnflags;
		break;
	}
	
	editor_send_selection(e);
}

// This must be called in SV_ParseClientCommand
// input entity self
// input string cmd: same as in SV_ParseClientCommand
// output float: TRUE if command was handled, FALSE if not
float(string cmd) sv_editor_command =
{
	float argc = tokenize(cmd);
	switch (argv(0))
	{
	case "toggleeditmode":
		edit_mode = !edit_mode;
		if (edit_mode)
		{
			editor_reset();
		}
		else
		{
			editor_play();
		}
		return TRUE;
		
	case "edit_add":
		if (argc >= 2) 
			editor_add_ent(argv(1));
		return TRUE;
	
	case "edit_select":
		editor_select_ent();
		return TRUE;
		
	case "edit_delete":
		if (edit_mode && self.editor_selection)
			editor_delete_ent(self.editor_selection);
		return TRUE;
		
	case "edit_save":
		if (edit_mode && argc >= 2)
			editor_save_ents(argv(1));
		return TRUE;
		
	case "edit_load":
		if (edit_mode && argc >= 2)
			editor_load_ents(argv(1));
		return TRUE;
		
	case "edit_move":
		if (edit_mode && argc >= 2)
			editor_move_selection(stof(argv(1)));
		return TRUE;
		
	case "edit_grid":
		if (edit_mode && argc >= 2)
			self.editor_grid_size = stof(argv(1));
		return TRUE;
		
	case "edit_rotate":
		if (edit_mode && argc >= 2)
			editor_rotate_selection(stof(argv(1)));
		return TRUE;
		
	case "edit_setprop":
		if (edit_mode && argc >= 3)
			editor_set_property(argc);
		return TRUE;

	default: break;
	}
	return FALSE;
}

void() sv_editor_init =
{
	globalstat(STAT_ED_MODE, EV_FLOAT, "edit_mode");
	clientstat(STAT_ED_GRID, EV_FLOAT, editor_grid_size);
}


