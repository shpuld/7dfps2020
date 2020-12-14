//
//	Main.qc - mostly functions that will be called from the engine and are expected to exist
//

//called for each frame that QC runs
void() StartFrame =
{

}

void() spawn_enemies;
void() spawn_objectives;
void() spawn_ambients;

void() post_generation =
{
	if (mission_number < 6) num_objectives = 2;
	else num_objectives = 4;
	spawn_enemies();
	if (objective_mode != OBJ_ELIMINATION)
		spawn_objectives();
}



void() worldspawn =
{	
	precache_everything();
	spawn_ambients();

	sv_editor_init();

	// editor_load_ents("default");
	editor_play();
	
	clientstat(STAT_AIMING, EV_FLOAT, aiming);
	clientstat(STAT_AIM_PENALTY, EV_FLOAT, aim_penalty);
	clientstat(STAT_CHAMBERED, EV_FLOAT, chambered);
	clientstat(STAT_MAGAZINE, EV_FLOAT, magazine);
	clientstat(STAT_RESERVE, EV_FLOAT, reserve);
	clientstat(STAT_SPEED, EV_FLOAT, speed);
	clientstat(STAT_MAX_HEALTH, EV_FLOAT, max_health);
	
	globalstat(STAT_CREDITS, EV_FLOAT, "credits");
	globalstat(STAT_NUM_OBJS, EV_FLOAT, "num_objectives");
	globalstat(STAT_OBJS_COMPLETED, EV_FLOAT, "objectives_completed");
	globalstat(STAT_OBJ_MODE, EV_FLOAT, "objective_mode");
	globalstat(STAT_MISSION_NUM, EV_FLOAT, "mission_number");
	
	if (cvar("removesave"))
	{
		delete_save();
		localcmd("removesave 0\n");
	}

	if (!load_game())
	{
		for (int i = 0; i < 2; i++)
			randomize_soldier(&(player_team[i]), 1);
		
		float howmany = 1 + rint(random() * 2);
		for (int i = 0; i < howmany; i++)
			randomize_soldier(&(recruitable[i]), floor(random() * 3));
	
		credits = 1500;
	}
	
	objective_mode = OBJ_ELIMINATION;
	switch (mission_number % 4)
	{
	case 0: objective_mode = OBJ_ELIMINATION; break;
	case 1: objective_mode = OBJ_COMMS; break;
	case 2: objective_mode = OBJ_ELIMINATION; break;
	case 3: objective_mode = OBJ_ARTIFACT; break;
	}

	self.nextthink = time + 2.5;
	self.think = post_generation;
}

void() SpectatorConnect =
{

}

// float BLOCK_SIZE = 320;
float BLOCK_SIZE = 512;
vector WORLD_SIZE = '10 10 0';

void() spawn_enemies =
{
	float enemies_to_spawn = 6 + mission_number + cvar("skill");
	if (objective_mode == OBJ_ELIMINATION) enemies_to_spawn = floor(enemies_to_spawn * 1.25);
	float enemies_spawned = 0;
	float safedist = 1600;
	entity point = find(world, classname, "info_notnull");
	entity old_self = self;
	for (float i = 0; i < 100; i++)
	{
		vector pos = point.origin + [safedist + random() * (BLOCK_SIZE * WORLD_SIZE.x - safedist * 1.75), safedist + random() * (BLOCK_SIZE * WORLD_SIZE.y - safedist * 1.75), 512];
		tracebox(pos, '-16 -16 0', '16 16 64', pos - '0 0 1024', 0, point);
		if (trace_endpos.z > (point.origin.z + 32)) continue;
		if (trace_plane_normal.z < 0.7) continue;

		entity dummy = spawn();
		setorigin(dummy, trace_endpos);	
		self = dummy;
		alien_minor();
		enemies_spawned += 1;
	
		if (enemies_spawned >= enemies_to_spawn) break;
	}
	self = old_self;
	
	if (objective_mode == OBJ_ELIMINATION) num_objectives = enemies_spawned;
}


void() comms_tower =
{
	setmodel(self, "models/comm.iqm");
	setsize(self, '-10 -10 -12', '10 10 64');
	self.solid = SOLID_BBOX;
	self.classname = "comms_tower";
	self.health = 20;
	self.max_health = self.health;
}

void() artifact_touch =
{
	if (other.classname == "player")
	{
		objectives_completed += 1;
		credits += 250;
		sound(self, CHAN_AUTO, "sound/switch.wav", 0.8, 1.0);
		remove(self);
	}
}

void() artifact =
{
	setmodel(self, "models/artifact.iqm");
	setsize(self, '-16 -16 -12', '16 16 42');
	self.solid = SOLID_TRIGGER;
	self.classname = "artifact";
	self.touch = artifact_touch;
}

string() objective_classname =
{
	switch (objective_mode)
	{
		case OBJ_COMMS: return "comms_tower";
		case OBJ_ARTIFACT: return "artifact";
		default: return "sub_remove";
	}
}

void() spawn_objectives =
{
	float objectives_to_spawn = num_objectives;
	float objectives_spawned = 0;
	float safedist = 1600;
	entity point = find(world, classname, "info_notnull");
	entity old_self = self;

	for (float i = 0; i < 200; i++)
	{
		vector pos = point.origin + [safedist + random() * (BLOCK_SIZE * WORLD_SIZE.x - safedist * 1.25), safedist + random() * (BLOCK_SIZE * WORLD_SIZE.y - safedist * 1.25), 512];
		tracebox(pos, '-16 -16 0', '16 16 64', pos - '0 0 1024', 0, point);
		if (trace_endpos.z > (point.origin.z + 60)) continue;
		if (trace_plane_normal.z < 0.8) continue;

		float too_close = FALSE;
		for (entity otherobj = findchain(classname, objective_classname()); otherobj; otherobj = otherobj.chain)
		{
			if (vlen(otherobj.origin - trace_endpos) < 800)
			{
				too_close = TRUE;
				break;
			}
		}
		if (too_close) continue;

		entity dummy = spawn();
		setorigin(dummy, trace_endpos);	
		self = dummy;
		callfunction(objective_classname());
		objectives_spawned += 1;
	
		if (objectives_spawned >= objectives_to_spawn) break;
	}
	self = old_self;
	num_objectives = objectives_spawned;
}

void() spawn_ambients =
{
	for (float x = 0; x < WORLD_SIZE.x + 1; x++)
	{
		for (float y = 0; y < WORLD_SIZE.y + 1; y++)
		{
			string sample = sprintf("sound/ambient%.0f.wav", ceil(random()*3.999));
			ambientsound([x*BLOCK_SIZE - BLOCK_SIZE * 0.75 + random() * 0.5 * BLOCK_SIZE, y*BLOCK_SIZE + BLOCK_SIZE*0.25 + random()*0.5*BLOCK_SIZE, 32 + random() * 64], sample, 0.2 + random() * 0.1, 0.35);
		}
	}
	
}


.vector org_point;
.vector real_origin;

void(entity ent, vector ang) set_bmodel_angles =
{
	ent.angles = ang;
	makevectors(ent.angles);
	setorigin(ent, v_forward * -ent.org_point_x - v_right * -ent.org_point_y + v_up * -ent.org_point_z + ent.org_point);
}

void(entity ent, vector org) set_bmodel_org =
{
	makevectors(ent.angles);
	setorigin(ent, v_forward * -ent.org_point_x - v_right * -ent.org_point_y + v_up * -ent.org_point_z + org);
}

float() try_place_bmodel =
{
	vector ofs = '0 0 0';
	float width = rint((self.absmax_x - self.absmin_x) / BLOCK_SIZE);
	float height = rint((self.absmax_y - self.absmin_y) / BLOCK_SIZE);
	
	// printf("Placing %s with size %f %f\n", self.targetname, width, height);
	
	entity point = find(world, classname, "info_notnull");
	float initial_angle = floor(random()*4) * 90;

	for (int i = 0; i < 150; i++)
	{
		vector world_ofs = [floor(random() * WORLD_SIZE.x), floor(random() * WORLD_SIZE.y)];
		vector world_pos = point.origin + world_ofs * BLOCK_SIZE;
		traceline(world_pos + '0 0 512', world_pos - '0 0 128', MOVE_NORMAL, point);
		if (trace_ent != world) continue;
		
		for (int j = 0; j < 4; j++)
		{
			set_bmodel_angles(self, [0, initial_angle + j * 90]);
			makevectors(self.angles);

			float clear = TRUE;

			for (int x = 0; x < width; x++)
			{
				if (!clear) break;
				for (int y = 0; y < height; y++)
				{
					ofs = BLOCK_SIZE * x * v_forward + BLOCK_SIZE * y * -v_right;
					traceline(self.org_point + '0 0 512' + ofs, self.org_point + ofs - '0 0 128', MOVE_NORMAL, point);

					if (trace_ent != world)
					{
						// printf("hit model at %v\n", trace_endpos);
						traceline(world_pos + '0 0 512' + ofs, world_pos - '0 0 128' + ofs, MOVE_NORMAL, point);
						
						if (trace_ent != world || trace_startsolid)
						{
							// print("not clear!\n");
							clear = FALSE;
							break;
						}
					}
				}
			}
			if (clear)
			{
				set_bmodel_org(self, world_pos);
				return TRUE;
			}
		}
	}
	
	// print("Could not place model\n");
	self.solid = SOLID_NOT;
	self.modelindex = 0;
	return FALSE;
}

void() func_plat_init =
{
	entity point = find(world, targetname, strcat("org", self.targetname));
	
	// printf("point: %s\n", etos(point));
	if (!point)
	{
		vector dividedmin = self.absmin / BLOCK_SIZE;
		self.org_point = [ceil(dividedmin_x), ceil(dividedmin_y), ceil(dividedmin_z)] * BLOCK_SIZE;
	}
	else
	{
		self.org_point = point.origin;
	}
	try_place_bmodel();
}

void() func_plat =
{
	setmodel(self, self.model);
	self.solid = SOLID_BSP;
	
	float width = rint((self.absmax_x - self.absmin_x) / BLOCK_SIZE);
	float height = rint((self.absmax_y - self.absmin_y) / BLOCK_SIZE);

	self.nextthink = time + 0.1 + max(0, 1.6 - width*height*0.1) + random() * 0.5;
	self.think = func_plat_init;
}

void() func_fallback_init =
{
	entity point = find(world, classname, "info_notnull");
	// set_bmodel_angles(self, [0, initial_angle]);
	
	for (float x = 0; x < WORLD_SIZE.x; x++)
	{
		for (float y = 0; y < WORLD_SIZE.y; y++)
		{
			vector world_pos = point.origin + [x, y] * BLOCK_SIZE;
			traceline(world_pos + '0 0 512', world_pos - '0 0 128', MOVE_NORMAL, point);
			if (trace_ent == world || trace_fraction == 1)
			{
				// printf("filling empty spot at %f %f\n", x, y);
				entity clone = spawn();
				float ang = floor(random()*4) * 90;
				clone.org_point = self.org_point;
				setmodel(clone, self.model);
				clone.solid = SOLID_BSP;
				set_bmodel_angles(clone, [0, ang]);
				set_bmodel_org(clone, world_pos);
			}
		}
	}
	
	self.modelindex = 0;
}

void() func_fallback =
{
	setmodel(self, self.model);
	self.solid = SOLID_BSP;
	
	entity point = find(world, targetname, strcat("org", self.targetname));

	if (!point)
	{
		vector dividedmin = self.absmin / BLOCK_SIZE;
		self.org_point = [ceil(dividedmin_x), ceil(dividedmin_y), ceil(dividedmin_z)] * BLOCK_SIZE;
	}
	else
	{
		self.org_point = point.origin;
	}
	
	self.nextthink = time + 2.2;
	self.think = func_fallback_init;
}

void() info_null =
{
}


void() info_notnull =
{
	
}