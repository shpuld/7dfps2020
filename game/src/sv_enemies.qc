// Empty


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

const float AGGRO_DIST = 1600;
const float AGGRO_DOT = 0.4;

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
	if (angle_diff(self.angles_y, self.ideal_yaw) > 45)
	{
		changeyaw();
		return TRUE;
	}
	float success = walkmove(self.ideal_yaw, dist);
	if (!success) success = walkmove(self.ideal_yaw + 25, dist);
	if (!success) success = walkmove(self.ideal_yaw - 25, dist);
	if (!success) success = walkmove(self.ideal_yaw + 65, dist);
	if (!success) success = walkmove(self.ideal_yaw - 65, dist);
	if (!success) success = walkmove(self.ideal_yaw + 80, dist);
	if (!success) success = walkmove(self.ideal_yaw - 80, dist);
	
	return success;
};

entity() find_enemy =
{
	for (entity head = player_chain_head; head; head = head.player_chain_next)
	{
		vector to_player = head.origin - self.origin;
		float dist = AGGRO_DIST;
		if (self.alert_state == ALERT_NONE) dist *= 0.5;
		if (vlen(to_player) > AGGRO_DIST) continue;
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

	e.alert_state = ALERT_HOSTILE;
	e.enemy = player;
	e.frame = ANIM_IDLE_ALERT;
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
			move_forward(4);
			self.on_move -= 1;
			moving = TRUE;
		}
		
		spot_enemy_try(7);
	}
	else if (self.alert_state == ALERT_AWARE)
	{
		to_target = self.targetpos - self.origin;

		spot_enemy_try(7);

		changeyaw();

		if (vlen(to_target) > 96)
		{
			self.ideal_yaw = vectoangles(to_target)[1];
			moved = move_forward(6);
			if (moved)
				moving = TRUE;
			else
				self.targetpos = self.origin;
		}
		else
		{
			if (r > 0.75)
			{
				self.ideal_yaw = random() * 360;
			}
			if (r > 0.9)
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
		}
	}
	else if (self.alert_state == ALERT_HOSTILE)
	{
		if (!can_see(self.enemy))
		{
			// self.targetpos = self.enemy.origin;
			to_target = self.targetpos - self.origin;
			self.ideal_yaw = vectoangles(to_target)[1];
			changeyaw();
			
			moved = move_forward(15);
			
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
			
			self.next_move = time + 1;
			self.spotting_counter += 1;
			if (self.spotting_counter > 100)
			{
				self.alert_state = ALERT_AWARE;
				self.targetpos = self.origin;
				self.enemy = world;
				self.spotting_counter = 0;
			}
		}
		else
		{
			self.spotting_counter = 0;
			self.targetpos = self.enemy.origin + '0 0 45';
			to_target = self.targetpos - self.origin;
			self.ideal_yaw = vectoangles(to_target)[1];
			changeyaw();
			
			if (time > (self.next_move - 3))
			{
				move_forward(15);
				moving = TRUE;
				if (time > self.next_move)
				{
					self.next_move = time + 4.2;
					if (vlen(to_target) > 128)
						self.next_move += 2;
				}
			}
			else
			{
				if (time > self.attack_finished)
				{
					vector aimpos = self.targetpos + [self.enemy.velocity.x, self.enemy.velocity.y] * 0.2;
					vector fwd = normalize(aimpos - (self.origin + '0 0 42'));
					entity bull = spawn();
					setmodel(bull, "models/alienbullet.iqm");
					bull.velocity = fwd * 2100 + randomvec() * 80;
					setsize(bull, '0 0 0', '0 0 0');
					bull.movetype = MOVETYPE_FLYMISSILE;
					bull.touch = sub_remove;
					bull.solid = SOLID_BBOX;
					bull.angles = vectoangles(bull.velocity);
					bull.owner = self;
					setorigin(bull, self.origin + '0 0 42' + fwd * 16);
					self.attack_finished = time + 0.2;
					self.frame = ANIM_SHOOT;
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
	}
};

void(float amount, vector dir, entity dealer) enemy_hurt = 
{
	float stagger = random() > 0.6;
	if (stagger)
	{
		self.frame = ANIM_STAGGER;
		self.nextthink = time + 1.5;
	}
	else
	{
		self.frame = ANIM_HURT;
		self.nextthink = time + 1.0;
	}
	self.think = enemy_think;
	alert_enemy(self, dealer.origin + '0 0 32');
};

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
}


void() alien_minor =
{
	setmodel(self, "models/alien.iqm");
	setsize(self, '-12 -12 0', '12 12 64');
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_STEP;
	
	self.nextthink = time + 1 + random()*2;
	self.think = enemy_think;
	self.alert_state = ALERT_NONE;
	self.takes_damage = TRUE;
	self.health = 90;
	self.hurt = enemy_hurt;
	self.die = enemy_die;
	self.yaw_speed = 15;
}