//shared definitions

#define printf(x, ...) print(sprintf(x, __VA_ARGS__))

const float STAT_AIMING = 50;
const float STAT_AIM_PENALTY = 51;
const float STAT_CROUCHING = 52;
const float STAT_CHAMBERED = 53;
const float STAT_MAGAZINE = 54;

const float EVENT_RECOIL = 1;
const float EVENT_RELOAD = 2;
const float EVENT_CHARGE = 3;
const float EVENT_SETGUN = 4;



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
	case WEP_PISTOL: return 0.25;
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
	case WEP_PISTOL: return 0.3;
	case WEP_AK: return 0.3;
	case WEP_MP5: return 0.18;
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

string(float type) get_fire_sound =
{
	switch (type)
	{
	case WEP_PISTOL: return "sound/FireX.wav";
	case WEP_AK: return "sound/FireX.wav";
	case WEP_MP5: return "sound/mp5.wav";
	case WEP_RIFLE: return "sound/FireX.wav";
	default: return "";
	}
}

string(float type) get_gun_model =
{
	switch (type)
	{
	case WEP_PISTOL: return "models/ak.iqm";
	case WEP_AK: return "models/ak.iqm";
	case WEP_MP5: return "models/mp5.iqm";
	case WEP_RIFLE: return "models/ak.iqm";
	default: return "models/ak.iqm";
	}
}

string(float type) get_muzzleflash_model =
{
	switch (type)
	{
	// case WEP_PISTOL: return "models/ak.iqm";
	case WEP_AK: return "models/ak_mzl.iqm";
	case WEP_MP5: return "models/mp5_mzl.iqm";
	// case WEP_RIFLE: return "models/ak.iqm";
	default: return "models/ak_mzl.iqm";
	}
}


float() srandom = { return 2*random() - 1; }

void() precache_everything =
{
	precache_sound("demon/dland2.wav");
	precache_sound("sound/FireX.wav");
	precache_sound("sound/mp5.wav");
	precache_sound("sound/ak_charge.wav");
	precache_sound("sound/ak_reload.wav");
	precache_sound("sound/rico1.wav");
	precache_sound("sound/rico2.wav");
	precache_sound("sound/rico3.wav");
	precache_sound("sound/bullethit.wav");
	precache_model("models/testplayer.iqm");
	precache_model("models/alien.iqm");
	precache_model("models/barrel.iqm");
	precache_model("models/skybox.iqm");
	precache_model("models/bullet.iqm");
	precache_model("models/alienbullet.iqm");
	precache_model("models/ak.iqm");
	precache_model("models/ak_mzl.iqm");
	precache_model("models/mp5.iqm");
	precache_model("models/mp5_mzl.iqm");
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
	sound(e, chan, sprintf(samp, 1 + floor(random() * numvar)), vol, atten, 95 + random() * 10);
}

