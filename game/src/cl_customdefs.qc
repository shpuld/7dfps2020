//Various globals that are used in this FTEQW example are defined here, they are not used by the engine itself

vector MENU_BG = '0 0.15 0.1';
vector MENU_BG_DARK = '0 0.1 0';
vector MENU_BORDER = '0 0.3 0.2';
vector MENU_BUTTON = '0 0.3 0.2';
vector MENU_BUTTON_BORDER = '0 0.4 0.25';
vector MENU_TEXT_1 = '1 1 1';
vector MENU_TEXT_2 = '0.7 0.75 0.75';
vector MENU_HIGHLIGHT = '1 1 1';
vector MENU_DARKEN = '1 1 1';

vector MENU_TEXT_SMALL = '8 8 0';
vector MENU_TEXT_MEDIUM = '16 16 0';
vector MENU_TEXT_LARGE = '24 24 0';

#pragma warning disable Q302
vector cursor_pos; /* Current mouse cursor position, updated in csqc_inputevent */
float g_width, g_height; /* Globals for screen width and height */

//Menu stuff
float in_menu; //what menu are we in
float time_in_menu;

const float MENU_NONE = 0;
const float MENU_BRIEFING = 1;
const float MENU_PICK = 2;
const float MENU_TEAM = 3;
const float MENU_DEPLOYING = 4;

// for keybinding
float active_bind_index;
float menu_click_held;


float in_input_box;
float input_cursor;

float cheats_used;

vector campos;
vector camang;

entity localplayer;

vector kickangle;

float alt_held;
float shift_held;
float ctrl_held;

float current_gun;

float music_playing;
float music_stop_time;

float die_time;
float complete_time;

string character_name;

float hack_done;
float hack_total;
float hack_time;

float damage_amount;
float show_objective_time;
float old_objectives_completed;

float holding_fire;

entity start_timer;

string() objective_text =
{
	switch (getstatf(STAT_OBJ_MODE))
	{
	case OBJ_ELIMINATION: return "Eliminate hostiles %.0f/%.0f";
	case OBJ_ARTIFACT: return "Secure artifacts %.0f/%.0f";
	case OBJ_COMMS: return "Hack comms towers %.0f/%.0f";
	default: return "Completed %.0f/%.0f";
	}
}

vector() readvector =
{
	vector r = '0 0 0';
	r_x = readcoord();
	r_y = readcoord();
	r_z = readcoord();
	return r;
};
