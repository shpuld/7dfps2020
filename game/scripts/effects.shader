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
