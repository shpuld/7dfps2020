//shared definitions

#define printf(x, ...) print(sprintf(x, __VA_ARGS__))

const float STAT_AIMING = 50;
const float STAT_AIM_PENALTY = 51;
const float STAT_CROUCHING = 52;

const float EVENT_RECOIL = 1;
const float EVENT_RELOAD = 2;
const float EVENT_CHARGE = 3;

float() srandom = { return 2*random() - 1; }

void() precache_everything =
{
	precache_sound("demon/dland2.wav");
	precache_sound("sound/FireX.wav");
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
	precache_model("models/ak.iqm");
	precache_model("models/ak_mzl.iqm");
	precache_model("models/bullet.iqm");
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

