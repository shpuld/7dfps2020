
//
//	Player.qc - Various stuff done for the player, including per-frame functions like PlayerPreThink and PlayerPostThink, also client specific stuff like PutClientInServer etc.
//

void() fill_magazine =
{
	self.magazine = 30;
}

void(float type) set_gun_type =
{
	if (time < self.attack_finished) return;

	self.weapontype = type;
	self.attack_finished = time + 0.6;
	BeginEvent(EVENT_SETGUN);
	MulticastByte(type);
	msg_entity = self;
	multicast('0 0 0', MULTICAST_ONE_R);
	self.aim_penalty = 1.25;
}

void(entity gun) set_gun =
{
	if (time < self.attack_finished) return;
	
	set_gun_type(gun.weapontype);
	self.magazine = gun.magazine;
	self.chambered = gun.chambered;
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
		if (time < self.attack_finished) return;
		self.nextthink = time + 2.6;
		self.think = fill_magazine;
		self.attack_finished = time + 2.6;
		BeginEvent(EVENT_RELOAD);
		msg_entity = self;
		multicast('0 0 0', MULTICAST_ONE);
		sound(self, CHAN_AUTO, "sound/ak_reload.wav", 0.8, 1, 95 + random() * 5);
		break;
	case 11:
		BeginEvent(EVENT_CHARGE);
		msg_entity = self;
		multicast('0 0 0', MULTICAST_ONE);
		sound(self, CHAN_AUTO, "sound/ak_charge.wav", 0.8, 1, 95 + random() * 5);
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

}

void(float amount, vector dir, entity dealer) player_die =
{

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
		if (ratio > 0.88) dmg_multi = 2.0;
		if (ratio < 0.5) dmg_multi = 0.5;
		printf("ratio %f, multiplier %f\n", ratio, dmg_multi);
		damage(other, (22 + random() * 35) * dmg_multi, self.velocity, self.owner);
	}
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
	bullet.solid = SOLID_BBOX;
	bullet.angles = vectoangles(dir);
	bullet.angles_z = random() * 360;
	bullet.scale = 3;

	bullet.touch = bullet_touch;
	bullet.owner = shooter;
	
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
	
	sound(self, CHAN_AUTO, get_fire_sound(self.weapontype), 1, 0.5, 90 + random() * 6);
	
	float recoil_amount = get_recoil(self.weapontype);
	// AK
	// self.recoil += 0.3;
	// MP5
	self.recoil += recoil_amount;
	
	BeginEvent(EVENT_RECOIL);
	MulticastByte(recoil_amount * 255);
	msg_entity = self;
	multicast('0 0 0', MULTICAST_ONE);
	
	if (self.recoil > 1) self.recoil = 1;
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
	CheckImpulses();
	makevectors(self.v_angle);

	if (self.dead)
	{
		return;
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
				sound(self, CHAN_AUTO, "sound/ak_charge.wav", 0.8, 1, 95 + random() * 5);
				self.attack_finished = time + 0.6;
				self.nextthink = time + 0.5;
				self.think = finish_chambering;
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

void() PlayerSpawn =
{
	self.classname = "player";
	self.solid = SOLID_SLIDEBOX;
	setmodel(self, "models/alien.iqm");
	self.movetype = MOVETYPE_WALK;
	self.health = 100;
	setorigin(self, get_spawn_point());
	self.angles = find(world, classname, "info_player_start").angles;
	self.angles_x = 24;
	self.fixangle = TRUE;
	setsize(self, [-16, -16, 0], [16, 16, STANDING_HEIGHT]);
	self.view_ofs = [0, 0, STANDING_VIEWOFS];
	self.hurt = player_hurt;
	self.die = player_die;
	self.takes_damage = TRUE;
	self.dead = FALSE;
	// self.weapontype = WEP_MP5;
	set_gun_type(WEP_AK);
	self.magazine = 30;
	droptofloor();
	player_normal();
};

void() PutClientInServer =
{
	player_chain_add(self);
	PlayerSpawn();
	
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
	
	tokenize(command_string);
	string cmd = argv(0);
	switch (cmd)
	{
	default: break;
	}
	clientcommand(self, command_string);
};


void() SV_RunClientCommand =
{
	if (self.dead)
		input_movevalues *= 0;
		
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
			
	runstandardplayerphysics(self);

	makevectors([0, self.angles_y, 0]);
	
	vector hvel = [self.velocity_x, self.velocity_y];
	vector proposed_velocity = self.velocity + (input_movevalues_x * v_forward + input_movevalues_y * v_right) * input_timelength * 1.5;
	
	if (vlen([proposed_velocity_x, proposed_velocity_y]) < 240)
		self.velocity = proposed_velocity;
		
	float target_penalty = self.aiming ? get_aim_inaccuracy(weaptype) : get_hip_inaccuracy(weaptype);
	if (!crouching) target_penalty += 0.05;
	target_penalty += min(1.4, vlen(self.velocity) / 320);
	
	if (self.recoil > 0)
	{
		self.recoil -= input_timelength;
		target_penalty += crouching ? self.recoil * 0.5 : self.recoil;
	}
	
	if (self.aim_penalty > target_penalty)
		self.aim_penalty = max(target_penalty, self.aim_penalty - input_timelength * 1);
	else 
		self.aim_penalty = min(target_penalty, self.aim_penalty + input_timelength * 3.5);
};


