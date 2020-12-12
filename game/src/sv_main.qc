//
//	Main.qc - mostly functions that will be called from the engine and are expected to exist
//

//called for each frame that QC runs
void() StartFrame =
{

}

void() spawn_enemies;

void() worldspawn =
{	
	precache_everything();
	
	sv_editor_init();

	// editor_load_ents("default");
	editor_play();
	
	clientstat(STAT_AIMING, EV_FLOAT, aiming);
	clientstat(STAT_AIM_PENALTY, EV_FLOAT, aim_penalty);
	clientstat(STAT_CHAMBERED, EV_FLOAT, chambered);
	clientstat(STAT_MAGAZINE, EV_FLOAT, magazine);
	clientstat(STAT_RESERVE, EV_FLOAT, reserve);
	
	self.nextthink = time + 2.5;
	self.think = spawn_enemies;
}

void() SpectatorConnect =
{

}

// float BLOCK_SIZE = 320;
float BLOCK_SIZE = 512;
vector WORLD_SIZE = '10 10 0';

void() spawn_enemies =
{
	float enemies_to_spawn = 12;
	float enemies_spawned = 0;
	float safedist = 1600;
	entity point = find(world, classname, "info_notnull");
	entity old_self = self;
	for (float i = 0; i < 100; i++)
	{
		vector pos = point.origin + [safedist + random() * (BLOCK_SIZE * WORLD_SIZE.x - safedist * 1.25), safedist + random() * (BLOCK_SIZE * WORLD_SIZE.y - safedist * 1.25), 512];
		tracebox(pos, '-16 -16 0', '16 16 64', pos - '0 0 1024', 0, point);
		if (trace_endpos.z > (point.origin.z + 64)) continue;
		if (trace_plane_normal.z < 0.7) continue;

		entity dummy = spawn();
		setorigin(dummy, trace_endpos);	
		self = dummy;
		alien_minor();
		enemies_spawned += 1;
	
		if (enemies_spawned >= enemies_to_spawn) break;
	}
	self = old_self;
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