vector sun_dir;
void() draw_sun =
{
	makevectors(camang);
	float sunstrength = max(0, (v_forward * sun_dir - 0.65));
	sunstrength += bound(0, (-camang_x + 25) * 0.005, 0.25);
	sunstrength = bound(0, sunstrength, 1.2);
	
	vector sun_screen_pos = project(sun_dir * -1000000);
	if (sun_screen_pos_z > 0) sun_screen_pos_y = -90000;
	if (sun_screen_pos_y < 0) sun_screen_pos_y = 0;
	if (sun_screen_pos_y > g_height) sun_screen_pos = 0;
	
	float top = sun_screen_pos_y - g_height * 1.5;
	float bot = sun_screen_pos_y + g_height * 1.5;
	
	R_BeginPolygon("ss_sun", 0, 1);
	vector col = '0.8 0.6 0.4' * sunstrength;
	R_PolygonVertex([0, top, 0], [0, 0], '0 0 0', 1);
	R_PolygonVertex([g_width, top, 0], [0, 0], '0 0 0', 1);
	R_PolygonVertex([g_width, sun_screen_pos_y, 0], [0, 0], col, 1);
	R_PolygonVertex([0, sun_screen_pos_y, 0], [0, 0], col, 1);
	
	R_EndPolygon();
	
	R_PolygonVertex([0, sun_screen_pos_y, 0], [0, 0], col, 1);
	R_PolygonVertex([g_width, sun_screen_pos_y, 0], [0, 0], col, 1);
	R_PolygonVertex([g_width, bot, 0], [0, 0], '0 0 0', 1);
	R_PolygonVertex([0, bot, 0], [0, 0], '0 0 0', 1);
	
	R_EndPolygon();
}