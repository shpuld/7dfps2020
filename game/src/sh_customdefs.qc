//shared definitions

#define printf(x, ...) print(sprintf(x, __VA_ARGS__))

const float STAT_AIMING = 50;
const float STAT_AIM_PENALTY = 51;
const float STAT_CROUCHING = 52;
const float STAT_CHAMBERED = 53;
const float STAT_MAGAZINE = 54;
const float STAT_RESERVE = 55;
const float STAT_CREDITS = 56;
const float STAT_SPEED = 57;

const float EVENT_RECOIL = 1;
const float EVENT_RELOAD = 2;
const float EVENT_CHARGE = 3;
const float EVENT_SETGUN = 4;
const float EVENT_DAMAGE = 5;
const float EVENT_SYNC_TEAM = 6;
const float EVENT_SYNC_RECRUITABLES = 7;
const float EVENT_MUSIC_START = 8;
const float EVENT_MUSIC_STOP = 9;


const float WEP_PISTOL = 1;
const float WEP_AK = 2;
const float WEP_MP5 = 3;
const float WEP_RIFLE = 4;

float(float type) get_aim_inaccuracy =
{
	switch (type)
	{
	case WEP_PISTOL: return 0.15;
	case WEP_AK: return 0.08;
	case WEP_MP5: return 0.1;
	case WEP_RIFLE: return 0.03;
	default: return 0;
	}
}

float(float type) get_hip_inaccuracy =
{
	switch (type)
	{
	case WEP_PISTOL: return 0.2;
	case WEP_AK: return 0.2;
	case WEP_MP5: return 0.25;
	case WEP_RIFLE: return 0.1;
	default: return 0;
	}
}

float(float type) get_recoil =
{
	switch (type)
	{
	case WEP_PISTOL: return 0.35;
	case WEP_AK: return 0.32;
	case WEP_MP5: return 0.16;
	case WEP_RIFLE: return 0.4;
	default: return 0;
	}
}

float(float type) get_fire_delay =
{
	switch (type)
	{
	case WEP_PISTOL: return 0.2;
	case WEP_AK: return 0.1;
	case WEP_MP5: return 0.0666;
	case WEP_RIFLE: return 0.3;
	default: return 0;
	}
}

float(float type) get_movement_penalty_mult =
{
	switch (type)
	{
	case WEP_PISTOL: return 0.5;
	case WEP_AK: return 1.2;
	case WEP_MP5: return 0.8;
	case WEP_RIFLE: return 1.3;
	default: return 1;
	}
}

float(float type) get_damage =
{
	switch (type)
	{
	case WEP_PISTOL: return 26 + random() * 25;
	case WEP_AK: return 30 + random() * 25;
	case WEP_MP5: return 20 + random() * 25;
	case WEP_RIFLE: return 35 + random() * 35;
	default: return 0;
	}
}

string(float type) get_fire_sound =
{
	switch (type)
	{
	case WEP_PISTOL: return "sound/pistol.wav";
	case WEP_AK: return "sound/ak.wav";
	case WEP_MP5: return "sound/mp5.wav";
	case WEP_RIFLE: return "sound/ak.wav";
	default: return "";
	}
}

string(float type) get_reload_sound =
{
	switch (type)
	{
	case WEP_PISTOL: return "sound/pistol_reload.wav";
	default: return "sound/ak_reload.wav";
	}
}

string(float type) get_charge_sound =
{
	switch (type)
	{
	case WEP_PISTOL: return "sound/pistol_charge.wav";
	default: return "sound/ak_charge.wav";
	}
}


float(float type) get_reload_time =
{
	switch (type)
	{
	case WEP_PISTOL: return 1.5;
	default: return 2.45;
	}
}

string(float type) get_gun_model =
{
	switch (type)
	{
	case WEP_PISTOL: return "models/pistol.iqm";
	case WEP_AK: return "models/ak.iqm";
	case WEP_MP5: return "models/mp5.iqm";
	case WEP_RIFLE: return "models/ak.iqm";
	default: return "models/ak.iqm";
	}
}

string(float type) get_gun_name =
{
	switch (type)
	{
	case WEP_PISTOL: return "9mm";
	case WEP_AK: return "AK-762";
	case WEP_MP5: return "MP-SD";
	case WEP_RIFLE: return "DMR";
	default: return "N/A";
	}
}


string(float type) get_muzzleflash_model =
{
	switch (type)
	{
	case WEP_PISTOL: return "models/pistol_mzl.iqm";
	case WEP_AK: return "models/ak_mzl.iqm";
	case WEP_MP5: return "models/mp5_mzl.iqm";
	// case WEP_RIFLE: return "models/ak.iqm";
	default: return "models/ak_mzl.iqm";
	}
}

float(float type) get_magazine =
{
	switch (type)
	{
	case WEP_PISTOL: return 12;
	case WEP_AK: return 30;
	case WEP_MP5: return 30;
	case WEP_RIFLE: return 10;
	default: return 0;
	}	
}

float(float type) get_reserve =
{
	switch (type)
	{
	case WEP_PISTOL: return 60;
	case WEP_AK: return 90;
	case WEP_MP5: return 90;
	case WEP_RIFLE: return 30;
	default: return 0;
	}	
}


struct soldier {
	string firstname;
	float lastnamei;
	float speed;
	float accuracy;
	float vitality;
	float weapontype;
	float cost;
	entity player;
};

soldier player_team[8];
soldier recruitable[4];

string lastnames[] =  {
	"Jackson",
	"Willy",
	"Mason",
	"Connors",
	"Ling",
	"Lee",
	"Ramirez",
	"Rodriguez",
	"Burke",
	"Smith",
	"Johnson",
	"Darkholme",
	"Herrington",
	"Wolff",
	"Jaeger",
	"Bastille",
	"Buck",
	"Braun",
	"Rogers",
	"Hernandez",
	"Sakamoto",
	"Perse",
	"Virta",
	"Granberg",
	"Rambo",
	"Willis",
	"Jones",
	"Trevor",
	"Paul",
	"Pierre",
	"Francis",
	"Holmes",
	"Greenberg",
	"Tanaka",
	"Murphy",
	"Mann",
	"Mungus",
	"Ripley",
	"Bravo",
	"Chavez",
	"Cash",
	"Prince",
	"King",
	"Palmer",
	"Ballmer",
	"Warden",
	"Focker",
	"Champion",
	"Jeeves",
	"Bobson",
	"Dugnutt",
	"Dogman",
	"Woods",
	"Bigfoot",
	"Bonzales",
	"Singov",
	"Smirnov",
	"Ivanov",
	"Romanov",
	"Makarov",
	"Lebedev",
	"Hermann",
	"Wesker",
	"Redfield",
	"Kennedy",
	"Carver",
	"Russo",
	"Bruno",
	"Lombardi",
	"Pellegrino",
	"Orlando",
	"Fisher",
	"Price",
	"Augustus",
	"Christian",
	"Guillaume",
	"Lambert",
	"Leroy",
	"Jenkins",
	"Page",
	"Simons",
	"Pascal",
	"Stallman",
	"Bacon",
	"Cofe",
	"Boss",
	"Petit",
	"Small",
	"Biggs",
	"Christin",
	"Jensen",
	"Adam",
	"Wetriver",
	"Kickelberg",
	"Poisson",
	"Morrison",
	"Kant",
	"Descartes",
	"Dozsa",
	"Andrzejczak",
	"Bartoszewicz",
	"Kobuszewski",
	"Radziszewski",
	"Matsumoto",
	"Hadaka",
	"Pelvis",
	"Campbell",
	"Redifer",
	"Gentleman",
	"Butte",
	"Denton",
	"Ross",
	"Hicks",
	"Night",
	"Badwater",
	"Goodwater",
	"Clearwater",
	"Krieg",
	"Wurst",
	"Flynn",
	"Stacker",
	"Scott",
	"Winters",
	"Standing",
	"Powers"
};

string(soldier* guy) soldier_name =
{
	return sprintf("%s.%s", guy->firstname, lastnames[guy->lastnamei]);
}

float() is_team_full =
{
	for (int i = 0; i < player_team.length; i++)
		if (player_team[i].firstname == "") return FALSE;
	return TRUE;
}

float() srandom = { return 2*random() - 1; }

void() precache_everything =
{
	precache_sound("demon/dland2.wav");
	precache_sound("sound/ak.wav");
	precache_sound("sound/mp5.wav");
	precache_sound("sound/pistol.wav");
	precache_sound("sound/ak_charge.wav");
	precache_sound("sound/pistol_charge.wav");
	precache_sound("sound/ak_reload.wav");
	precache_sound("sound/pistol_reload.wav");
	precache_sound("sound/rico1.wav");
	precache_sound("sound/rico2.wav");
	precache_sound("sound/rico3.wav");
	precache_sound("sound/bullethit.wav");
	precache_sound("sound/alienshot.wav");
	precache_sound("sound/alienbullethit.wav");
	precache_sound("sound/deathjingle.wav");
	precache_sound("sound/switch.wav");
	
	precache_sound("sound/hurt1.wav");
	precache_sound("sound/hurt2.wav");
	precache_sound("sound/hurt3.wav");
	precache_sound("sound/hurt4.wav");
	
	precache_sound("sound/die1.wav");
	precache_sound("sound/die2.wav");
	precache_sound("sound/die3.wav");
	precache_sound("sound/die4.wav");
	precache_sound("sound/die5.wav");
	
	precache_sound("sound/idle1.wav");
	precache_sound("sound/idle2.wav");
	precache_sound("sound/idle3.wav");
	precache_sound("sound/idle4.wav");
	precache_sound("sound/idle5.wav");
	
	precache_sound("sound/alert1.wav");
	precache_sound("sound/alert2.wav");
	precache_sound("sound/alert3.wav");
	precache_sound("sound/alert4.wav");
	precache_sound("sound/alert5.wav");
	
	precache_sound("sound/spotted1.wav");
	precache_sound("sound/spotted2.wav");
	precache_sound("sound/spotted3.wav");
	precache_sound("sound/spotted4.wav");
	precache_sound("sound/spotted5.wav");
	precache_sound("sound/spotted6.wav");

	precache_model("models/testplayer.iqm");
	precache_model("models/alien.iqm");
	precache_model("models/barrel.iqm");
	precache_model("models/skybox.iqm");
	precache_model("models/bullet.iqm");
	precache_model("models/alienbullet.iqm");
	precache_model("models/ak.iqm");
	precache_model("models/pistol.iqm");
	precache_model("models/ak_mzl.iqm");
	precache_model("models/mp5.iqm");
	precache_model("models/mp5_mzl.iqm");
	precache_model("models/pistol_mzl.iqm");
	
	particleeffectnum("weapons.alienblood");
	particleeffectnum("weapons.bullethit");
	particleeffectnum("weapons.alien_mzl");
	particleeffectnum("weapons.alienbullet_hit");
};

float(float a, float b, float amount) turn_angle =
{
	a = anglemod(a);
	b = anglemod(b);
	float diff = b - a;
	
	if (fabs(diff) < amount)
	{
		return b;
	}
	
	if (diff < -180)
	{
		b += 360;	
	}
	else if (diff > 180)
	{
		b -= 360;
	}
	
	if (fabs(b - a) < amount)
	{
		return b;
	}
	if (a < b)
		return a + amount;
	else
		return a - amount;	
}

float(float a, float b) angle_diff =
{
	return fabs((a - b + 180) % 360 - 180);
}

float(float a, float b) angle_diff_signed =
{
	float diff = (a - b + 180) % 360 - 180;
	if (diff < -180) diff += 360;
	if (diff > 180) diff += 360;
	// if (fabs(diff) > 180) printf("diff %f, a %f, b %f\n", diff, a, b);
	return diff;
}

vector(vector v, float amount) move_vector_to_zero =
{
	vector amounts = normalize(v) * amount;
	for (float d = 0; d < 3; d++)
		v[d] = v[d] > 0 ? max(0, v[d] - amounts[d]) : min(0, v[d] + -amounts[d]);
	return v;
}

void(entity e, float chan, string samp, float numvar, float vol, float atten) sound_variation =
{
	sound(e, chan, sprintf(samp, 1 + floor(random() * numvar)), vol, atten, 95 + random() * 10, SOUNDFLAG_FOLLOW);
}

