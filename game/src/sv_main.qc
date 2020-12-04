//
//	Main.qc - mostly functions that will be called from the engine and are expected to exist
//

//called for each frame that QC runs
void() StartFrame =
{

}

void() worldspawn =
{	
	precache_everything();
	
	sv_editor_init();

	editor_load_ents("default");
	editor_play();

}

void() SpectatorConnect =
{

}
