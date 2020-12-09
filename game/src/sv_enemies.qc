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

const float AGGRO_DIST = 350;
const float AGGRO_DOT = 0.4;

float(entity target) can_see =
{
	traceline(self.origin + '0 0 30', target.origin + '0 0 30', MOVE_ENTCHAIN, self);
	for (entity e = trace_ent; e; e = e.chain)
	{
		if (e.movetype == MOVETYPE_NONE && e != target) return FALSE;
	}
	return TRUE;
};

void(float dist) move_to_enemy =
{
	if (angle_diff(self.angles_y, self.ideal_yaw) > 45)
	{
		changeyaw();
		return;
	}
	float success = walkmove(self.ideal_yaw, dist);
	if (!success) success = walkmove(self.ideal_yaw + 25, dist);
	if (!success) success = walkmove(self.ideal_yaw - 25, dist);
	if (!success) success = walkmove(self.ideal_yaw + 65, dist);
	if (!success) success = walkmove(self.ideal_yaw - 65, dist);
	if (!success) success = walkmove(self.ideal_yaw + 90, dist);
	if (!success) success = walkmove(self.ideal_yaw - 90, dist);
};

entity() find_enemy =
{
	for (entity head = player_chain_head; head; head = head.player_chain_next)
	{
		vector to_player = head.origin - self.origin;
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
	e.alert_state = ALERT_HOSTILE;
	e.enemy = player;
	e.frame = ANIM_IDLE_ALERT;
};

void(entity e, vector location) alert_enemy =
{
	if (e.alert_state < ALERT_AWARE)
		e.alert_state = ALERT_AWARE;
		
	// give enemy location as point of interest
};

void() enemy_think =
{
	self.nextthink = time + 0.1;
	self.think = enemy_think;
	
	float moving = FALSE;
	
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
	self.solid = SOLID_NOT;
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
	self.health = 100;
	self.hurt = enemy_hurt;
	self.die = enemy_die;
}