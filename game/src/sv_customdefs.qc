// put custom server-only globals and fields here

float edit_mode;


const float FL_JUMPRELEASED = 4096;
.float attack_finished;
.float takes_damage;
.void(float amount, vector dir, entity dealer) hurt;
.void(float amount, vector dir, entity dealer) die;
.void() attack;
.float movespeed;
.float dead;

.float mouse2released;

.float aiming;
.float aim_value;
.float aim_penalty;
.float crouching;

.float chambered;
.float magazine;
.float reserve;
.entity primary;
.entity secondary;
.float weapontype;
.float using_primary;

.float accuracy;
.float speed;

.float footstep_time;

float credits;
float objective_mode;

float objectives_completed;
float num_objectives;
float mission_number;

float mission_completed;

void(soldier* guy, float level) randomize_soldier =
{
	guy->firstname = chr2str(65 + rint(random() * 22));
	guy->lastnamei = floor(random() * lastnames.length);
	float reallevel = max(0, level - 1);
	guy->speed = min(7, reallevel + rint(random() * 2.2));
	guy->accuracy = min(7, reallevel + rint(random() * 2.2));
	guy->vitality = min(7, reallevel + rint(random() * 2.2));
	guy->weapontype = ceil(1 + random() * 2.6); // lower chance for dmr
	guy->cost = 1200 + reallevel * 800 + floor(random()*10)*100;
	guy->player = world;
}

void(soldier* dst, soldier* src) copy_soldier =
{
	dst->firstname = src->firstname;
	dst->lastnamei = src->lastnamei;
	dst->speed = src->speed;
	dst->accuracy = src->accuracy;
	dst->vitality = src->vitality;
	dst->weapontype = src->weapontype;
	dst->cost = src->cost;
}

void(soldier* guy) zero_soldier =
{
	guy->firstname = "";
	guy->lastnamei = 0;
	guy->speed = 0;
	guy->accuracy = 0;
	guy->vitality = 0;
	guy->weapontype = 0;
	guy->cost = 0;
	guy->player = world;
}

void(soldier* guy) level_up_soldier =
{
	float r = random();
	if (r < 0.333)
	{
		guy->vitality = min(7, guy->vitality + 1);
		guy->speed = min(7, guy->speed + 1);
	}
	else if (r < 0.667)
	{
		guy->accuracy = min(7, guy->accuracy + 1);
		guy->speed = min(7, guy->speed + 1);
	}
	else
	{
		guy->accuracy = min(7, guy->accuracy + 1);
		guy->vitality = min(7, guy->vitality + 1);
	}
}


void(soldier* guy, float file) save_soldier =
{
	string line = guy->firstname;
	line = strcat(line, sprintf(" %.0f %.0f %.0f", guy->lastnamei, guy->speed, guy->accuracy));
	line = strcat(line, sprintf(" %.0f %.0f %.0f\n", guy->vitality, guy->weapontype, guy->cost));
	fputs(file, line);
}

void() save_game =
{
	float file = fopen("game", FILE_WRITE);
	fputs(file, sprintf("%.0f\n", cvar("skill")));
	fputs(file, sprintf("%.0f\n", mission_number));
	fputs(file, sprintf("%.0f\n", credits));
	fputs(file, "team\n");
	for (int i = 0; i < player_team.length; i++)
	{
		soldier* guy = &(player_team[i]);
		if (guy->firstname != "")
			save_soldier(guy, file);
	}
	fputs(file, "recruitable\n");
	for (int i = 0; i < recruitable.length; i++)
	{
		soldier* guy = &(recruitable[i]);
		if (guy->firstname != "")
			save_soldier(guy, file);
	}
	fclose(file);
}

void(soldier* guy, string line) load_soldier =
{
	tokenize(line);
	// printf("%s\n", line);
	guy->firstname = argv(0);
	guy->lastnamei = stof(argv(1));
	guy->speed = stof(argv(2));
	guy->accuracy = stof(argv(3));
	guy->vitality = stof(argv(4));
	guy->weapontype = stof(argv(5));
	guy->cost = stof(argv(6));
}

float() load_game =
{
	float file = fopen("game", FILE_READ);
	if (!file)
	{
		fclose(file);
		return FALSE;
	}
	string firstline = fgets(file);
	if (!firstline)
	{
		fclose(file);
		return FALSE;
	}
	cvar_set("skill", firstline);

	mission_number = stof(fgets(file));
	credits = stof(fgets(file));
	if (fgets(file) != "team")
	{
		fclose(file);
		return FALSE;
	}
	
	for (string line = fgets(file), int i = 0; line != "recruitable"; line = fgets(file), i++)
	{
		if (i < player_team.length)
			load_soldier(&(player_team[i]), line);
	}
	for (string line = fgets(file), int i = 0; line; line = fgets(file), i++)
	{
		if (i < recruitable.length)
			load_soldier(&(recruitable[i]), line);
	}
	fclose(file);
	return TRUE;
}

void() delete_save =
{
	float file = fopen("game", FILE_WRITE);
	fclose(file);
}


void() sub_remove =
{
	remove(self);
};

void() sub_noop = {};

void(entity e) fake_remove =
{
	e.modelindex = 0;
	e.solid = SOLID_NOT;
	e.movetype = MOVETYPE_NONE;
	setorigin(e, '0 0 -90000');
}

void() sub_fake_remove =
{
	fake_remove(self);
};

entity oself;
#define withself(e, ...) oself = self; self = e; __VA_ARGS__; self = oself

void(void() fn, entity new_self) runself = 
{
	entity old_self = self;
	self = new_self;
	fn();
	self = old_self;
};

void(float event) BeginEvent =
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, event);
};

void(vector vec) MulticastVector =
{
	WriteCoord(MSG_MULTICAST, vec_x);
	WriteCoord(MSG_MULTICAST, vec_y);
	WriteCoord(MSG_MULTICAST, vec_z);
};

void(float val) MulticastByte =
{
	WriteByte(MSG_MULTICAST, val);
};

void(float val) MulticastShort =
{
	WriteShort(MSG_MULTICAST, val);
};

void(float val) MulticastFloat =
{
	WriteFloat(MSG_MULTICAST, val);
};

void(entity e) MulticastEnt =
{
	WriteEntity(MSG_MULTICAST, e);
};

void(string s) MulticastString =
{
	WriteString(MSG_MULTICAST, s);
};




void(soldier* guy) MulticastSoldier =
{
	MulticastString(guy->firstname);
	MulticastByte(guy->lastnamei);
	MulticastByte(guy->speed);
	MulticastByte(guy->accuracy);
	MulticastByte(guy->vitality);
	MulticastByte(guy->weapontype);
	MulticastShort(guy->cost);
	MulticastEnt(guy->player);
}

void(entity to_whom, float broadcast) send_team =
{
	msg_entity = to_whom;
	BeginEvent(EVENT_SYNC_TEAM);
	MulticastByte((float)(player_team.length));
	for (int i = 0; i < player_team.length; i++)
	{
		MulticastSoldier(&(player_team[i]));
	}
	if (broadcast)
		multicast('0 0 0', MULTICAST_ALL_R);
	else
		multicast('0 0 0', MULTICAST_ONE_R);
}

void(entity to_whom, float broadcast) send_recruitables =
{
	msg_entity = to_whom;
	BeginEvent(EVENT_SYNC_RECRUITABLES);
	MulticastByte((float)(recruitable.length));
	for (int i = 0; i < recruitable.length; i++)
	{
		MulticastSoldier(&(recruitable[i]));
	}
	if (broadcast)
		multicast('0 0 0', MULTICAST_ALL_R);
	else
		multicast('0 0 0', MULTICAST_ONE_R);
}




void() light =
{
	remove(self);
};

entity player_chain_head;
.entity player_chain_next;
.entity player_chain_prev;

// Put an entity as the first of the linked list
void(entity adding) player_chain_add =
{
	if (adding.player_chain_prev || adding.player_chain_next || (adding == player_chain_head && !adding.player_chain_next)) 
	{
		print("Trying to adding an entity into player chain while it already is in chain!\n");
		return;
	}
	if (player_chain_head) player_chain_head.player_chain_prev = adding;
	adding.player_chain_next = player_chain_head;
	player_chain_head = adding;
};

// Remove entity from linked list
void(entity removing) player_chain_remove =
{
	if (removing == player_chain_head)
	{
		player_chain_head = removing.player_chain_next;
	}
	
	if (removing.player_chain_next) removing.player_chain_next.player_chain_prev = removing.player_chain_prev;
	if (removing.player_chain_prev) removing.player_chain_prev.player_chain_next = removing.player_chain_next;
	removing.player_chain_next = world;
	removing.player_chain_prev = world;
};


