// Empty


// For music
float num_hostile_enemies;

void() add_hostile_enemy =
{
	if (num_hostile_enemies == 0)
	{
		BeginEvent(EVENT_MUSIC_START);
		multicast('0 0 0', MULTICAST_ALL_R);
	}
	// localcmd("media_add sound/action_song.oga\n");
	num_hostile_enemies += 1;
	// printf("hostile enemies %.0f\n", num_hostile_enemies);
}

void() remove_hostile_enemy =
{
	
	num_hostile_enemies -= 1;
	// printf("hostile enemies %.0f\n", num_hostile_enemies);
	
	if (num_hostile_enemies == 0)
	{
		BeginEvent(EVENT_MUSIC_STOP);
		multicast('0 0 0', MULTICAST_ALL_R);
	}
	// localcmd("media_remove sound/action_song.oga\n");
}

void() misc_barrel =
{
	setmodel(self, "models/barrel.iqm");
	setsize(self, '-12 -12 0', '12 12 36');
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_TOSS;
	
	entity targetent = find(world, targetname, self.target);
	if (target)
		self.velocity = (targetent.origin - self.origin) * 4 + '0 0 400';
	
	self.touch = sub_fake_remove;
}

void() alienbullet_touch =
{
	pointparticles(particleeffectnum("weapons.alienbullet_hit"), self.origin, trace_plane_normal);
	sound(self, CHAN_AUTO, "sound/alienbullethit.wav", 0.4 + random() * 0.3, 0.8, 90 + random() * 16);
	sound_variation(self, CHAN_AUTO, "sound/rico%.0f.wav", 3, 0.9 + random() * 0.3, 0.7);
	
	if (other.classname == "player" && !mission_completed)
	{
		float dmg = 15 + random() * 12;
		dmg = rint(dmg * (0.24 + (cvar("skill") * 0.35)));
		damage(other, dmg, self.velocity, self.owner);
	}
	remove(self);
}

enum alert_state_t {
	ALERT_NONE,
	ALERT_AWARE,
	ALERT_HOSTILE
};

const float ANIM_T = 0;
const float ANIM_IDLE_ALERT = 1;
const float ANIM_SHOOT = 2;
const float ANIM_IDLE = 3;
const float ANIM_RUN = 4;
const float ANIM_WALK = 5;
const float ANIM_WALK_ALERT = 6;
const float ANIM_STAGGER = 7;
const float ANIM_HURT = 8;
const float ANIM_DIE = 9;

.alert_state_t alert_state;
.float on_move;
.vector targetpos;
.float spotting_counter;
.float next_move;
.float last_sound;

const float AGGRO_DIST = 2000;
const float AGGRO_DOT = 0.3;

float(entity target) can_see =
{
	traceline(self.origin + '0 0 50', target.origin + target.view_ofs, MOVE_ENTCHAIN, self);
	for (entity e = trace_ent; e; e = e.chain)
	{
		if (e.movetype == MOVETYPE_NONE && e != target) return FALSE;
	}
	return TRUE;
};

float(float dist) move_forward =
{
	self.movetype = MOVETYPE_STEP;
	if (angle_diff(self.angles_y, self.ideal_yaw) > 45)
	{
		changeyaw();
		return TRUE;
	}
	float success = walkmove(self.ideal_yaw, dist);
	if (!success) success = walkmove(self.ideal_yaw + 25, dist);
	if (!success) success = walkmove(self.ideal_yaw - 25, dist);
	if (!success) success = walkmove(self.ideal_yaw + 55, dist);
	if (!success) success = walkmove(self.ideal_yaw - 55, dist);
	if (!success) success = walkmove(self.ideal_yaw + 75, dist);
	if (!success) success = walkmove(self.ideal_yaw - 75, dist);
	
	return success;
};

entity() find_enemy =
{
	float aggrodist = is_night(mission_number) ? AGGRO_DIST * 0.7 : AGGRO_DIST;
	for (entity head = player_chain_head; head; head = head.player_chain_next)
	{
		vector to_player = head.origin - self.origin;
		float dist = AGGRO_DIST;
		if (self.alert_state == ALERT_NONE) dist *= 0.5;
		if (head.dead) continue;
		if (vlen(to_player) > aggrodist) continue;
		makevectors(self.angles);
		if (normalize(to_player) * v_forward < AGGRO_DOT) continue;
		if (!can_see(head)) continue;
		
		return head;
	}
	return world;
};

void(entity e, entity player) spot_enemy =
{
	if (!player) return;

	sound_variation(e, CHAN_VOICE, "sound/spotted%.0f.wav", 5, 1, 0.6);
	e.last_sound = time;
	if (self.alert_state != ALERT_HOSTILE)
		add_hostile_enemy();
	e.alert_state = ALERT_HOSTILE;
	e.attack_finished = time + 1.2 - cvar("skill") * 0.15;
	e.enemy = player;
	// e.frame = ANIM_IDLE_ALERT;
};

void(entity e, vector location) alert_enemy =
{
	if (e.alert_state < ALERT_AWARE)
		e.alert_state = ALERT_AWARE;
	
	e.targetpos = location;
	// give enemy location as point of interest
};

void(float spot_threshold) spot_enemy_try =
{
	entity enm = find_enemy();
	if (enm)
	{
		self.spotting_counter++;
		if (vlen(self.origin - enm.origin) < 500) self.spotting_counter++;

		if (self.spotting_counter >= spot_threshold)
		{
			if (self.alert_state == ALERT_NONE)
				alert_enemy(self, enm.origin);
			else
				spot_enemy(self, enm);
			
			self.spotting_counter = 0;
		}
	}
	else
	{
		self.spotting_counter = 0;
	}
}

void() enemy_think =
{
	self.nextthink = time + 0.1;
	self.think = enemy_think;
	
	float moving = FALSE;
	float moved;
	float r = random();
	vector to_target;
	
	if (self.alert_state == ALERT_NONE)
	{
		if (self.on_move <= 0)
		{
			if (random() > 0.9)
			{
				self.on_move = 10 + random() * 40;
				self.ideal_yaw = random() * 360;
			}
		}
		else
		{
			changeyaw();
			move_forward(5);
			self.on_move -= 1;
			moving = TRUE;
		}
		
		if (time > (self.last_sound + 5) && random() > 0.8)
		{
			sound_variation(self, CHAN_VOICE, "sound/idle%.0f.wav", 5, 0.7, 0.8);
			self.last_sound = time;
		}
		
		spot_enemy_try(8);
	}
	else if (self.alert_state == ALERT_AWARE)
	{
		to_target = self.targetpos - self.origin;

		spot_enemy_try(6);

		changeyaw();
		
		if (time > (self.last_sound + 5) && random() > 0.8)
		{
			sound_variation(self, CHAN_VOICE, "sound/alert%.0f.wav", 5, 0.7, 0.8);
			self.last_sound = time;
		}

		if (vlen(to_target) > 96)
		{
			self.ideal_yaw = vectoangles(to_target)[1];
			moved = move_forward(8);
			if (moved)
				moving = TRUE;
			else
				self.targetpos = self.origin;
		}
		else
		{
			if (r > 0.6)
			{
				self.ideal_yaw = random() * 360;
			}
			if (r > 0.75)
			{
				float baseangle = random() * 360;
				for (float i = 0; i < 16; i++)
				{
					makevectors([0, baseangle + i * 25, 0]);
					traceline(self.origin + '0 0 48', self.origin + '0 0 48' + v_forward * 512, 0, self);
					if (trace_fraction >= 0.25)
					{
						self.targetpos = self.origin + (trace_endpos - self.origin) * trace_fraction;
						break;
					}
				}
			}
			if (r > 0.85)
			{
				entity enm = find_enemy();
				if (enm && vlen(enm.origin) > 400)
					self.targetpos = enm.origin;
				else
					self.ideal_yaw = random() * 360;
			}
		}
	}
	else if (self.alert_state == ALERT_HOSTILE)
	{
		if (time > (self.last_sound + 5) && random() > 0.8)
		{
			sound_variation(self, CHAN_VOICE, "sound/spotted%.0f.wav", 5, 0.7, 0.8);
			self.last_sound = time;
		}
		
		if (self.enemy.dead)
		{
			self.alert_state = ALERT_AWARE;
			self.targetpos = self.origin;
			self.enemy = world;
			self.spotting_counter = 0;
			remove_hostile_enemy();
		}

		if (!can_see(self.enemy))
		{
			// self.targetpos = self.enemy.origin;
			to_target = self.targetpos - self.origin;
			self.ideal_yaw = vectoangles(to_target)[1];
			changeyaw();
			
			moved = move_forward(20);
			
			if (!moved)
			{
				float tgtyaw = 30 + r * 60;
				if (r < 0.5) tgtyaw = -tgtyaw;
				makevectors([0, self.angles.y + tgtyaw]);
				traceline(self.origin + '0 0 30', self.origin + '0 0 30' + v_forward * 250, 0, self);
				float oldfrac = trace_fraction;
				vector oldend = trace_endpos;
				traceline(trace_endpos, self.enemy.origin + self.enemy.view_ofs, MOVE_NOMONSTERS, self);
				if (trace_fraction >= 1 || oldfrac > 0.8) self.targetpos = oldend;
			}
			else
			{
				moving = TRUE;
			}
			
			self.next_move = time + 0.75;
			self.spotting_counter += 1;
			if (self.spotting_counter > 100)
			{
				self.alert_state = ALERT_AWARE;
				self.targetpos = self.origin;
				self.enemy = world;
				self.spotting_counter = 0;
				remove_hostile_enemy();
			}
		}
		else
		{
			if (self.spotting_counter > 30)
			{
				sound_variation(self, CHAN_VOICE, "sound/spotted%.0f.wav", 5, 0.7, 0.8);
				self.last_sound = time;
			}

			self.spotting_counter = 0;
			self.targetpos = self.enemy.origin + '0 0 45';
			to_target = self.targetpos - self.origin;
			self.ideal_yaw = vectoangles(to_target)[1];
			changeyaw();
			
			if (time > (self.next_move - 3))
			{
				if (vlen(to_target) > 90)
				{
					move_forward(20);
					moving = TRUE;
				}
				else
				{
					self.next_move -= 0.05;
				}
				if (time > self.next_move)
				{
					self.next_move = time + 4;
					if (vlen(to_target) < 180)
						self.next_move += 2;
				}
			}
			else
			{
				if (time > self.attack_finished && angle_diff(self.angles_y, self.ideal_yaw) < 25)
				{
					
					vector aimpos = self.targetpos + [self.enemy.velocity.x, self.enemy.velocity.y] * 0.2;
					vector fwd = normalize(aimpos - (self.origin + '0 0 42'));
					entity bull = spawn();
					setmodel(bull, "models/alienbullet.iqm");
					bull.velocity = fwd * 2100 + randomvec() * 80;
					setsize(bull, '0 0 0', '0 0 0');
					bull.movetype = MOVETYPE_FLYMISSILE;
					bull.touch = alienbullet_touch;
					bull.solid = SOLID_BBOX;
					bull.angles = vectoangles(bull.velocity);
					bull.owner = self;
					setorigin(bull, self.origin + '0 0 42' + fwd * 16);
					self.attack_finished = time + 0.15;
					self.frame = ANIM_SHOOT;
					
					pointparticles(particleeffectnum("weapons.alien_mzl"), bull.origin, fwd);
					sound(self, CHAN_WEAPON, "sound/alienshot.wav", 1.0, 0.3, 90 + random() * 18);
				}
			}
		}
	}
	
	if (moving)
	{
		if (self.alert_state == ALERT_NONE)
			self.frame = ANIM_WALK;
		else if (self.alert_state == ALERT_AWARE)
			self.frame = ANIM_WALK_ALERT;
		else
			self.frame = ANIM_RUN;
	}
	else
	{
		if (self.alert_state == ALERT_NONE)
			self.frame = ANIM_IDLE;
		else
			self.frame = ANIM_IDLE_ALERT;
			
		self.movetype = MOVETYPE_TOSS;
		self.velocity.x *= 0.5;
		self.velocity.y *= 0.5;
		self.gravity = 1;
	}
	
	
};

void(float amount, vector dir, entity dealer) enemy_hurt = 
{
	float stagger = random() > 0.6;
	if (stagger)
	{
		self.frame = ANIM_STAGGER;
		self.nextthink = time + 1.4;
	}
	else
	{
		self.frame = ANIM_HURT;
		self.nextthink = time + 0.75;
	}
	self.think = enemy_think;
	spot_enemy(self, dealer);
	
	sound_variation(self, CHAN_VOICE, "sound/hurt%.0f.wav", 4, 1, 0.8);
	self.last_sound = time;
	
	for (entity enm = findradius(self.origin, 900); enm; enm = enm.chain)
	{
		if (enm.classname == "alien_minor")
			alert_enemy(enm, dealer.origin);
	}
	// alert_enemy(self, dealer.origin + '0 0 32');
};

void() align_body =
{
	if (vlen(self.velocity) > 50) return;
	traceline(self.origin + '0 0 1', self.origin - '0 0 16', 0, self);
	if (trace_plane_normal.z < 0.5) return;
	makevectors(self.angles);
	vector newforward = crossproduct(trace_plane_normal, v_right);
	self.angles = vectoangles(newforward, trace_plane_normal);
}

void() push_body_along_normal =
{
	traceline(self.origin + '0 0 1', self.origin - '0 0 16', 0, self);
	if (trace_plane_normal.z < 0.5) self.velocity = trace_plane_normal * 150;
}

void() body_hit =
{
	self.nextthink = time + 0.4;
	self.think = align_body;
	
	if (trace_plane_normal_z < 0.5)
	{
		self.nextthink = time + 0.01;
		self.think = push_body_along_normal;
	}
}

void(float amount, vector dir, entity dealer) enemy_die =
{
	self.nextthink = 0;
	self.frame = ANIM_DIE;
	self.takes_damage = FALSE;
	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_TOSS;
	self.velocity = normalize(dir) * 250;
	self.velocity_z = 150;
	self.angles = vectoangles(-[dir.x, dir.y]);
	self.touch = body_hit;
	setsize(self, '0 0 0', '0 0 0');
	sound_variation(self, CHAN_VOICE, "sound/die%.0f.wav", 5, 1, 0.8);
	if (self.alert_state == ALERT_HOSTILE)
		remove_hostile_enemy();
	
	if (objective_mode == OBJ_ELIMINATION)
		objectives_completed += 1;
	
	credits += 50 + min(5 - cvar("skill"), 0) * 50;
}


void() alien_minor =
{
	setmodel(self, "models/alien.iqm");
	setsize(self, '-12 -12 0', '12 12 64');
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_STEP;
	
	self.nextthink = time + 0.1 + random()*0.5;
	self.think = enemy_think;
	self.alert_state = ALERT_NONE;
	self.takes_damage = TRUE;
	self.health = 90;
	self.hurt = enemy_hurt;
	self.die = enemy_die;
	self.yaw_speed = 17;
	
	self.classname = "alien_minor";
}