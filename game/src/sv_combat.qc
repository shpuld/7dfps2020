
void(entity target, float amount, vector dir, entity dealer) damage =
{
	if (!target.takes_damage) return;
	
	if (target.health <= 0) return;
	
	target.health -= amount;
	
	if (target.health > 0)
	{
		if (target.hurt)
		{
			withself(target, target.hurt(amount, dir, dealer));
		}
	}
	else
	{
		if (target.die) 
		{
			withself(target, target.die(amount, dir, dealer));
		}
	}
};


void(vector origin, float radius, float mindmg, float maxdmg, entity dealer) radius_damage =
{
	vector targetcenter;
	float ratio, realdamage;
	if (radius <= 0) radius = 1;
	for (entity target = findradius(origin, radius); target != world; target = target.chain)
	{
		if (!target.takes_damage) continue;
		if (target.health <= 0) continue;
		
		targetcenter = (target.absmin + target.absmax) * 0.5;
		traceline(origin, targetcenter, MOVE_NOMONSTERS, dealer);
		if (trace_fraction < 1) continue;
		
		ratio = vlen(origin - targetcenter) / radius;
		realdamage = (ratio * maxdmg) + (1 - ratio) * mindmg;
		damage(target, realdamage, normalize(targetcenter - origin), dealer);
	}
};