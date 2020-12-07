
//
//	Player.qc - Various stuff done for the player, including per-frame functions like PlayerPreThink and PlayerPostThink, also client specific stuff like PutClientInServer etc.
//

void() CheckImpulses =
{
	switch (self.impulse)
	{
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

void() player_attack =
{
	traceline(self.origin + self.view_ofs, self.origin + self.view_ofs + v_forward * 1500, 0, self);
	printf("Hit: %s, %f, %f\n", etos(trace_ent), trace_startsolid, (float)trace_endcontents);
	printf("point contents %f\n", pointcontents(self.origin - '0 0 50'));
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


void() PlayerPreThink =
{	
	CheckImpulses();
	makevectors(self.v_angle);

	if (self.dead)
	{
		return;
	}
		
	// Attack
	if (self.button0)
	{
		if (time > self.attack_finished)
		{
			self.attack_finished = time + 0.5; 
			player_attack();
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
	}
	else
	{
		self.mouse2released = TRUE;
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

void() PlayerSpawn =
{
	self.classname = "player";
	self.solid = SOLID_SLIDEBOX;
	setmodel(self, "models/testplayer.iqm");
	self.movetype = MOVETYPE_WALK;
	self.health = 3;
	setorigin(self, get_spawn_point());
	self.angles = find(world, classname, "info_player_start").angles;
	self.angles_x = 24;
	self.fixangle = TRUE;
	setsize(self, [-16, -16, 0], [16, 16, 64]);
	self.view_ofs = [0, 0, 52];
	self.hurt = player_hurt;
	self.die = player_die;
	self.takes_damage = TRUE;
	self.dead = FALSE;
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
			
	runstandardplayerphysics(self);

	makevectors([0, self.angles_y, 0]);
	
	vector hvel = [self.velocity_x, self.velocity_y];
	vector proposed_velocity = self.velocity + (input_movevalues_x * v_forward + input_movevalues_y * v_right) * input_timelength * 1.5;
	
	if (vlen([proposed_velocity_x, proposed_velocity_y]) < 320)
		self.velocity = proposed_velocity;
	
};


