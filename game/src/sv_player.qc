
//
//	Player.qc - Various stuff done for the player, including per-frame functions like PlayerPreThink and PlayerPostThink, also client specific stuff like PutClientInServer etc.
//

.float reloading;

void(float type) set_gun_type =
{
	if (time < self.attack_finished && !self.reloading) return;

	self.weapontype = type;
	self.attack_finished = time + 0.6;
	BeginEvent(EVENT_SETGUN);
	MulticastByte(type);
	msg_entity = self;
	multicast('0 0 0', MULTICAST_ONE_R);
	self.aim_penalty = 1.25;
}

void(entity tgt, entity src) copy_gun =
{
	tgt.weapontype = src.weapontype;
	tgt.magazine = src.magazine;
	tgt.chambered = src.chambered;
	tgt.reserve = src.reserve;
}

void(entity gun) set_gun =
{
	if (time < self.attack_finished && !self.reloading) return;
	
	copy_gun(self, gun);
	set_gun_type(gun.weapontype);
}

void(entity newgun, float type) init_gun =
{
	newgun.weapontype = type;
	newgun.chambered = FALSE;
	newgun.magazine = get_magazine(type);
	newgun.reserve = get_reserve(type);
}

void() fill_magazine =
{
	float to_fill = get_magazine(self.weapontype) - self.magazine;
	float actual_fill = min(to_fill, self.reserve);
	self.magazine += actual_fill;
	self.reserve -= actual_fill;
	self.reloading = FALSE;
}

void() reload_gun =
{
	if (time < self.attack_finished) return;
	if (self.reserve <= 0) return;
	if (self.magazine >= get_magazine(self.weapontype)) return;
	if (self.dead) return;

	self.reloading = TRUE;
	self.nextthink = time + get_reload_time(self.weapontype);
	self.think = fill_magazine;
	self.attack_finished = time + get_reload_time(self.weapontype);
	BeginEvent(EVENT_RELOAD);
	msg_entity = self;
	multicast('0 0 0', MULTICAST_ONE);
	sound(self, CHAN_WEAPON, get_reload_sound(self.weapontype), 0.7, 1, 95 + random() * 15);
}

void() switch_gun =
{
	if (time < self.attack_finished && !self.reloading) return;
	if (self.dead) return;

	if (self.using_primary)
	{
		copy_gun(self.primary, self);
		set_gun(self.secondary);
		self.using_primary = FALSE;
	}
	else
	{
		copy_gun(self.secondary, self);
		set_gun(self.primary);
		self.using_primary = TRUE;
	}
	
	sound(self, CHAN_WEAPON, "sound/switch.wav", 0.7, 1.2, 95 + random() * 5);
	self.nextthink = 0;
	self.think = sub_noop;
	self.reloading = FALSE;
}

void() CheckImpulses =
{
	switch (self.impulse)
	{
	case 1:
		entity dummy = spawn();
		setorigin(dummy, self.origin + v_forward * 128 + '0 0 64');
		entity oldself = self;
		self = dummy;
		alien_minor();
		self = oldself;
		break;
	case 2:
		set_gun_type(WEP_MP5);
		break;
	case 3:
		set_gun_type(WEP_AK);
		break;
	case 10:
		reload_gun();
		break;
	case 11:
		switch_gun();
		break;
	default: break;
	}
	self.impulse = 0;
};

vector() get_spawn_point =
{
	entity spawnpoint = world;
	spawnpoint = find(spawnpoint, classname, "info_player_start");

	return spawnpoint.origin + '0 0 1';
};

void() player_normal =
{

}

void() player_jump =
{

}

void() player_land =
{

}

void(float amount, vector dir, entity dealer) player_hurt =
{
	BeginEvent(EVENT_DAMAGE);
	MulticastByte(amount);
	msg_entity = self;
	multicast('0 0 0', MULTICAST_ONE_R);
}

void() remove_soldier =
{
	for (int i = 0; i < player_team.length; i++)
	{
		if (player_team[i].player == self)
		{
			zero_soldier(&(player_team[i]));
			send_team(self, TRUE);
		}
	}
}

void() restart_server =
{
	// new recruitables
	for (int i = 0; i < recruitable.length; i++)
		zero_soldier(&(recruitable[i]));
	float howmany = 1 + rint(random() * 2);
	for (int i = 0; i < howmany; i++)
		randomize_soldier(&(recruitable[i]), floor(random() * 7));
		
	mission_number += 1;

	for (int i = 0; i < player_team.length; i++)
	{
		if (player_team[i].player)
			level_up_soldier(&(player_team[i]));
	}


	save_game();

	localcmd("restart\n");
}

void() restart_server_nosave =
{
	localcmd("restart\n");
}

void() close_server =
{
	localcmd("disconnect\n");
}

void(float amount, vector dir, entity dealer) player_die =
{
	BeginEvent(EVENT_DAMAGE);
	MulticastByte(amount);
	msg_entity = self;
	multicast('0 0 0', MULTICAST_ONE_R);
	
	setorigin(self, self.origin + self.view_ofs);
	self.view_ofs = '0 0 0';
	setsize(self, '-10 -10 -10', '10 10 8');
	self.movetype = MOVETYPE_TOSS;
	self.dead = TRUE;
	self.health = -1;
	
	msg_entity = self;
	BeginEvent(EVENT_DIE);
	multicast('0 0 0', MULTICAST_ONE_R);
	// sound(self, CHAN_AUTO, "sound/deathjingle.wav", 1.0, 0);
	
	remove_soldier();
	save_game();
	
	float all_dead = TRUE;
	for (int i = 0; i < player_team.length; i++)
	{
		if (player_team[i].firstname != "") all_dead = FALSE;
	}
	if (all_dead)
	{
		delete_save();
		self.nextthink = time + 5;
		self.think = close_server;
	}
	
}

entity(entity bullet) clone_bullet =
{
	entity nb = spawn();
	setmodel(nb, bullet.model);
	setsize(nb, bullet.mins, bullet.maxs);
	setorigin(nb, bullet.origin);
	nb.alpha = bullet.alpha;
	nb.angles = bullet.angles;
	nb.think = bullet.think;
	nb.nextthink = bullet.nextthink;
	nb.touch = bullet.touch;
	nb.owner = bullet.owner;
	nb.velocity = bullet.velocity;
	nb.solid = bullet.solid;
	nb.movetype = bullet.movetype;
	nb.weapontype = bullet.weapontype;
	return nb;
}

void() bullet_touch =
{
	if ((normalize(self.velocity) * trace_plane_normal) > -0.6 && random() > 0.75)
	{
		// printf("ricochet %f\n", normalize(self.velocity) * trace_plane_normal);
		entity nb = clone_bullet(self);
		nb.velocity = 0.7 * (-2 * (self.velocity * trace_plane_normal) * trace_plane_normal + nb.velocity);
		// nb.velocity += trace_plane_normal * (900 + random() * 500) + randomvec() * 900;
		// self.velocity = trace_plane_normal * 600;
		nb.angles = vectoangles(nb.velocity);
		nb.origin += trace_plane_normal * 8;
		sound_variation(nb, CHAN_AUTO, "sound/rico%.0f.wav", 3, 0.9 + random() * 0.3, 0.7);
	}
	else
	{
		sound(self, CHAN_AUTO, "sound/bullethit.wav", 0.2 + random() * 0.5, 1.3, 90 + random() * 25);
	}
	if (other.takes_damage)
	{
		float dmg_multi = 1;
		float from_bottom = self.origin_z - other.absmin_z;
		float ratio = from_bottom / (other.absmax_z - other.absmin_z);
		if (ratio > 0.85) dmg_multi = 2.0;
		if (ratio < 0.5) dmg_multi = 0.5;
		dmg_multi += (self.owner.accuracy - 2) * 0.05;
		// printf("damage multi %f, %f\n", dmg_multi, self.accuracy);
		// printf("ratio %f, multiplier %f\n", ratio, dmg_multi);
		damage(other, get_damage(self.weapontype) * dmg_multi, self.velocity, self.owner);
		// damage(other, 0.1 * dmg_multi, self.velocity, self.owner);
		pointparticles(particleeffectnum("weapons.alienblood"), self.origin, trace_plane_normal);
	}
	float surf = getsurfacenearpoint(other, self.origin);
	string text = getsurfacetexture(other, surf);
	
	if (text != "textures/dev/test_sky")
		pointparticles(particleeffectnum("weapons.bullet_impact"), self.origin + trace_plane_normal * 4, trace_plane_normal);

	remove(self);
	// printf("hit something %s\n", etos(other));
}

.float recoil;


entity(entity shooter, vector pos, vector dir) bullet_spawn =
{
	entity bullet = spawn();
	setorigin(bullet, pos);
	setmodel(bullet, "models/bullet.iqm");
	setsize(bullet, '0 0 0', '0 0 0');
	bullet.movetype = MOVETYPE_TOSS;
	bullet.velocity = normalize(dir) * 10000;  
	if (shooter.weapontype == WEP_RIFLE) bullet.velocity *= 1.5;
	bullet.solid = SOLID_BBOX;
	bullet.angles = vectoangles(dir);
	bullet.angles_z = random() * 360;
	bullet.scale = 3;

	bullet.touch = bullet_touch;
	bullet.owner = shooter;
	bullet.weapontype = shooter.weapontype;
	
	return bullet;
}

void() player_attack =
{
	// traceline(self.origin + self.view_ofs, self.origin + self.view_ofs + v_forward * 2500, 0, self);
	// printf("hit at %v\n", trace_endpos);
	
	vector inaccuracy = normalize([srandom() * 5, srandom() * 5, srandom() * 5]) * min(1, self.aim_penalty) * 0.1;
	vector dir = normalize(v_forward + inaccuracy);
	entity bl = bullet_spawn(self, self.origin + self.view_ofs + v_forward * 8 - v_up * 0.5 + v_right * 0.5, dir);
	
	traceline(bl.origin, bl.origin + normalize(bl.velocity) * (32 + random() * 64), 0, bl);
	setorigin(bl, bl.origin + 0.9 * (trace_endpos - bl.origin));
	
	sound(self, CHAN_AUTO, get_fire_sound(self.weapontype), 0.95, 0.5, 88 + random() * 8);
	sound(self, CHAN_AUTO, get_fire_sound(self.weapontype), 0.4 * random(), 0.9, 98 + random() * 6);
	
	float alertradius = 1700;
	if (self.weapontype == WEP_MP5) alertradius = 250;
	for (entity enm = findradius(self.origin, alertradius); enm; enm = enm.chain)
	{
		if (enm.classname != "alien_minor") continue;
		alert_enemy(enm, self.origin);
	}
	
	float recoil_amount = get_recoil(self.weapontype);
	// AK
	// self.recoil += 0.3;
	// MP5
	self.recoil += recoil_amount;
	
	BeginEvent(EVENT_RECOIL);
	MulticastByte(recoil_amount * 255);
	msg_entity = self;
	multicast('0 0 0', MULTICAST_ONE);
	
	if (self.recoil > 1.2) self.recoil = 1.2;
	self.attack_finished = time + get_fire_delay(self.weapontype);
}


void() PlayerJump =
{
	if (!(self.flags & FL_ONGROUND))
		return;

	if ( !(self.flags & FL_JUMPRELEASED) )
		return;
	
	self.weaponframe = 0;
	self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
	self.button2 = 0;
	player_jump();
};

void() finish_chambering =
{
	self.chambered = TRUE;
	self.magazine -= 1;
}

void() PlayerPreThink =
{	
	if (self.dead || mission_completed)
	{
		return;
	}
	
	CheckImpulses();
	makevectors(self.v_angle);
	
	if (num_objectives == objectives_completed)
	{
		if (vlen(self.origin) < 200)
		{
			BeginEvent(EVENT_COMPLETE);
			multicast('0 0 0', MULTICAST_ALL_R);
			mission_completed = TRUE;
			self.takes_damage = FALSE;
			self.nextthink = time + 5;
			self.think = restart_server;
			credits += 750;
			return;
		}
	}
	
	float reserve_min = get_reserve(self.weapontype) - get_magazine(self.weapontype);
	if (self.reserve < reserve_min)
	{
		if (vlen(self.origin) < 200)
		{
			self.reserve = reserve_min;
			sound(self, CHAN_AUTO, "sound/switch.wav", 0.8, 1.0);
		}
	}
	
	if (objective_mode == OBJ_COMMS && time > self.attack_finished)
	{
		traceline(self.origin + self.view_ofs, self.origin + self.view_ofs + v_forward * 64, 0, self);
		if (trace_ent.classname == "comms_tower")
		{
			if (self.button0 && trace_ent.health > 0)
			{
				// printf("%f\n", trace_ent.health);
				trace_ent.health--;
				
				if (trace_ent.health <= 0)
				{
					credits += 250;
					objectives_completed += 1;
				}
			}
			BeginEvent(EVENT_COMMS_UPDATE);
			MulticastByte(trace_ent.health);
			MulticastByte(trace_ent.max_health);
			multicast('0 0 0', MULTICAST_ONE_R);
			self.attack_finished = time + 0.3;
			return;
		}
	}

	// Attack
	if (time > self.attack_finished)
	{
		if (!self.chambered)
		{
			if (self.magazine > 0)
			{
				// Do the proper charging animation here
				BeginEvent(EVENT_CHARGE);
				msg_entity = self;
				multicast('0 0 0', MULTICAST_ONE);
				sound(self, CHAN_AUTO, get_charge_sound(self.weapontype), 0.8, 1, 95 + random() * 5);
				self.attack_finished = time + 0.4;
				self.nextthink = time + 0.35;
				self.think = finish_chambering;
			}
			else if (self.button0)
			{
				sound(self, CHAN_AUTO, "sound/empty.wav", 0.6, 1);
				self.attack_finished = time + 0.35;
			}
		}
		if (self.button0 && self.chambered)
		{
			player_attack();
			self.chambered = FALSE;
			
			if (self.magazine > 0)
			{
				self.chambered = TRUE;
				self.magazine -= 1;
			}
		}
	}
	
	// Jump
	if (self.button2)
	{
		PlayerJump();
	}
	else
	{
		self.flags = self.flags | FL_JUMPRELEASED;
	}
	
	// Mouse2
	if (self.button3)
	{
		self.mouse2released = FALSE;
		self.aiming = TRUE;
	}
	else
	{
		self.mouse2released = TRUE;
		self.aiming = FALSE;
	}
	
};

void() PlayerPostThink =
{

};

void() ClientKill =
{
};

//called when a client connects to the server
void() ClientConnect =
{
	// print("Client connect\n");
};

const float STANDING_HEIGHT = 64;
const float CROUCHING_HEIGHT = 44;
const float STANDING_VIEWOFS = 52;
const float CROUCHING_VIEWOFS = 32;

void(float soldier) PlayerSpawn =
{
	self.classname = "player";
	self.solid = SOLID_SLIDEBOX;
	setmodel(self, "models/alien.iqm");
	self.movetype = MOVETYPE_WALK;
	self.health = 70 + 5 * player_team[soldier]->vitality;
	self.max_health = self.health;
	setsize(self, [-16, -16, 0], [16, 16, STANDING_HEIGHT]);
	setorigin(self, get_spawn_point());
	for (int i = 0; i < 100; i++)
	{
		vector pos = get_spawn_point() + [random() * 256, random() * 256];
		tracebox(pos, self.mins, self.maxs, pos - '0 0 2000', 0, self);
		if (trace_plane_normal.z > 0.7 && trace_endpos.z < 64)
		{
			setorigin(self, trace_endpos);
			break;
		}
	}
	self.angles = find(world, classname, "info_player_start").angles;
	self.fixangle = TRUE;
	self.view_ofs = [0, 0, STANDING_VIEWOFS];
	self.hurt = player_hurt;
	self.die = player_die;
	self.takes_damage = TRUE;
	self.dead = FALSE;
	// self.weapontype = WEP_MP5;
	droptofloor();
	player_normal();
	
	self.primary = spawn();
	self.secondary = spawn();
	init_gun(self.primary, player_team[soldier]->weapontype);
	init_gun(self.secondary, WEP_PISTOL);
	set_gun(self.primary);
	self.using_primary = TRUE;
	self.speed = player_team[soldier]->speed;
	self.accuracy = player_team[soldier]->accuracy;
	
	player_team[soldier]->player = self;
	send_team(self, TRUE);
	
	localcmd("media_remove sound/action_song.oga\n");
	// localcmd("media_add sound/action_song.oga\n");
};

void() PutClientInServer =
{
	player_chain_add(self);
	self.dead = TRUE;
	// PlayerSpawn();
	send_team(self, FALSE);
	send_recruitables(self, FALSE);
};

void() ClientDisconnect =
{
	bprint(PRINT_HIGH, self.netname);
	bprint(PRINT_HIGH, " has left the game.\n");
};


void() SetNewParms =
{
};

void() SetChangeParms =
{
};

void() info_player_start =
{
};

void(float elapsedtime) SV_PausedTic =
{
	// if (elapsedtime > 2) setpause(0);
};

float(string cmd) sv_editor_command;

void(string command_string) SV_ParseClientCommand =
{
	if (sv_editor_command(command_string)) return;
	
	float argc = tokenize(command_string);
	string cmd = argv(0);
	switch (cmd)
	{
	case "hire":
		if (argc < 2) return;
		float target = stof(argv(1));
		if (recruitable[target]->cost > credits) return;

		for (int i = 0; i < player_team.length; i++)
		{
			if (player_team[i].firstname == "")
			{
				copy_soldier(&(player_team[i]), &(recruitable[target]));
				credits -= recruitable[target]->cost;
				zero_soldier(&(recruitable[target]));
				send_team(self, TRUE);
				send_recruitables(self, TRUE);
				return;
			}
		}
		break;
	case "deploy":
		if (argc < 2) return;
		float soldier = stof(argv(1));
		PlayerSpawn(soldier);	
		return;
	case "quit":
		save_game();
		// fixme
		localcmd("disconnect\n");
		return;
	default: break;
	}
	clientcommand(self, command_string);
};


void() SV_RunClientCommand =
{
	if (self.dead)
	{
		input_movevalues *= 0;
		runstandardplayerphysics(self);
		return;
	}
	
	float weaptype = self.weapontype;
		
	if (self.aiming) input_movevalues *= 0.6;
	
	float crouching = input_buttons & 8;
	if (!crouching && self.view_ofs_z <= CROUCHING_VIEWOFS)
	{
		tracebox(self.origin, self.mins, [self.maxs.x, self.maxs.y, STANDING_HEIGHT], self.origin, 0, self);
		if (trace_startsolid)
			crouching = TRUE;
		else
			setsize(self, self.mins, [self.maxs.x, self.maxs.y, STANDING_HEIGHT]);
	}
	
	if (crouching)
	{
		setsize(self, self.mins, [self.maxs.x, self.maxs.y, CROUCHING_HEIGHT]);
		self.view_ofs_z = max(CROUCHING_VIEWOFS, self.view_ofs_z - input_timelength * 180);
		input_movevalues *= 0.4;
	}
	else
		self.view_ofs_z = min(STANDING_VIEWOFS, self.view_ofs_z + input_timelength * 180);
	
	vector oldpos = self.origin;
	runstandardplayerphysics(self);
	
	if (self.flags & FL_ONGROUND)
	{
		self.footstep_time += vlen(oldpos - self.origin);
		if (self.footstep_time > 70)
		{
			// sound(self, CHAN_AUTO, "sound/empty.wav", 1, 1);
			sound_variation(self, CHAN_AUTO, "sound/step%.0f.wav", 7, 0.1, 1.5);
			self.footstep_time = 0;
		}
	}
	else self.footstep_time = 100;

	makevectors([0, self.angles_y, 0]);
	
	vector hvel = [self.velocity_x, self.velocity_y];
	vector proposed_velocity = self.velocity + (input_movevalues_x * v_forward + input_movevalues_y * v_right) * input_timelength * 1.5;
	
	if (vlen([proposed_velocity_x, proposed_velocity_y]) < 240)
		self.velocity = proposed_velocity;
		
	float target_penalty = self.aiming ? get_aim_inaccuracy(weaptype) : get_hip_inaccuracy(weaptype);
	if (!crouching) target_penalty += 0.03;
	target_penalty += min(1.6, vlen(self.velocity) / 320) * get_movement_penalty_mult(self.weapontype);
	
	
	if (self.recoil > 0)
	{
		self.recoil -= input_timelength * 1.1;
		target_penalty += crouching ? self.recoil * 0.5 : self.recoil;
	}
	
	float accuracy_bonus = (4.5 - self.accuracy) * 0.02;
	target_penalty += accuracy_bonus;
	
	if (self.aim_penalty > target_penalty)
		self.aim_penalty = max(target_penalty, self.aim_penalty - input_timelength * (1.3 + self.accuracy * 0.15));
	else 
		self.aim_penalty = min(target_penalty, self.aim_penalty + input_timelength * 3.4);
};


