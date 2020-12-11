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


