aparticle
{
	{
		map particles/puff.tga
		alphagen vertex
		rgbGen vertex
		alphafunc GE128
		blendFunc GL_ONE GL_ONE
	}
}

aparticle2
{
	{
		map particles/puff.tga
		alphagen vertex
		rgbGen vertex
		alphafunc GE128
	}
}


aring
{
	{
		map particles/ring.tga
		alphagen vertex
		rgbGen vertex
		alphafunc GE128
		blendFunc GL_ONE GL_ONE
	}
}

adot
{
	{
		map particles/dot.tga
		alphagen vertex
		rgbGen vertex
		alphafunc GE128
	}
}

adotadd
{
	{
		map particles/dot.tga
		alphagen vertex
		rgbGen vertex
		alphafunc GE128
		blendFunc GL_ONE GL_ONE
	}
}

dotdecal
{
    sort 6
    polygonOffset
    {
		map $nearest:particles/dot.tga
		alphagen vertex
		rgbGen vertex
		alphafunc GE128
	}
}

ss_sun
{
	{
		map $white
		blendFunc GL_ONE GL_ONE
		rgbGen vertex
	}
}


playershadow
{
	polygonOffset 2
	discrete
	sort unlitdecal
	noShadows
	{
		map textures/playershadow
		blendFunc blend
		alphaGen vertex	
	}
}

menu/cursor
{
	{
		map gfx/xhair
	}
}
