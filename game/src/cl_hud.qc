
void() draw_hud =
{
	vector hudsize = [42 * 4 + 8, 28];
	vector basepos = [8, g_height - 8 - hudsize.y];
	drawfill(basepos, hudsize, '0 0 0', 0.6);
	
	float hp = getstatf(STAT_HEALTH);
	float frac = hp / 100;
	
	drawfill([basepos.x + 4, basepos.y + 4], [(hudsize.x - 8) * frac, 8], '1 1 1', 0.3);
	string hpstr = sprintf("+%.0f", hp);
	drawstring([basepos.x + hudsize.x - strlen(hpstr) * 8 - 4, basepos.y + 4], hpstr, [8, 8], '1 1 1', 1, 0);
	
	float mag = getstatf(STAT_MAGAZINE);
	float chambered = getstatf(STAT_CHAMBERED);
	
	float bulletw = 3;
	float bulleth = 8;
	float i;
	for (i = 0; i < mag; i++)
	{
		drawfill([basepos.x + 4 + i * (bulletw+1), basepos.y + hudsize.y - 4 - bulleth], [bulletw, bulleth], '1 1 1', 0.3);
	}
	if (chambered)
	{
		drawfill([basepos.x + 4 + i * (bulletw+1), basepos.y + hudsize.y - 4 - bulleth], [bulletw, bulleth], '1 1 1', 0.8);
	}
	
	string ammocount = sprintf("%.0f/%.0f", mag + chambered, 90);
	drawstring([basepos.x + hudsize.x - strlen(ammocount) * 8 - 4, basepos.y + hudsize.y - 4 - 8], ammocount, [8, 8], '1 1 1', 1, 0);
}