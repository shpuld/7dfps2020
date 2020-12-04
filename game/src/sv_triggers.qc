
/*
void() trigger_example =
{
	setmodel(self, self.model);
	self.modelindex = 0;
	self.solid = SOLID_TRIGGER;
	self.touch = something;
};
*/

void() func_illusionary =
{
	setmodel(self, self.model);
	self.solid = SOLID_NOT;
};

