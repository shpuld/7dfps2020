textures/dev/white
{
	{
		map $nearest:textures/dev/white.tga
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
}

textures/dev/gray
{
	{
		map $nearest:textures/dev/gray.tga
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
}

textures/dev/graydark
{
	{
		map $nearest:textures/dev/graydark.tga
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
}

textures/dev/black
{
	{
		map $nearest:textures/dev/black.tga
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
}

textures/dev/green
{
	{
		map $nearest:textures/dev/green.tga
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
}

textures/dev/blue
{
	{
		map $nearest:textures/dev/blue.tga
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
}

textures/dev/brown
{
	{
		map $nearest:textures/dev/brown.tga
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
}
textures/dev/beige
{
	{
		map $nearest:textures/dev/beige.tga
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
}

textures/dev/orange
{
	{
		map $nearest:textures/dev/orange.tga
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
}

textures/dev/red
{
	{
		map $nearest:textures/dev/red.tga
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
}

textures/dev/purple
{
	{
		map $nearest:textures/dev/purple.tga
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
}

textures/dev/yellow
{
	{
		map $nearest:textures/dev/yellow.tga
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
}

textures/dev/test_sky
{
	qer_editorimage textures/dev/edsky.tga

	q3map_globaltexture
	q3map_sun 0.9 0.8 0.7 85 84 84
	
	surfaceparm sky
	surfaceparm noimpact
	surfaceparm nolightmap
	surfaceparm nomarks
	// skyparms textures/tropical/sky - -
	
	// surfaceparm nodraw
}

textures/dev/groundq3
{
	{
		map $linear:textures/dev/terrain_gradient.tga
		tcGen vector ( 0 0 1 ) ( 0 0 0.001 )
		tcMod transform 0.01 -0.003 0.01 -0.01 1 -0.5
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identityLighting
	}
	{
		map $nearest:textures/dev/ground.tga
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
	}
}

textures/dev/ground23
{
	{
		map $linear:textures/dev/terrain_gradient.tga
		tcGen vector ( 0 0 1 ) ( 0 0 0.001 )
		tcMod transform 0.01 -0.003 0.01 -0.01 1 -0.5
		rgbGen constant 1.62 1.55 1.45
	}
	{
	 	map $nearest:textures/dev/ground.tga
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
	}
	{
		map $whitetexture
		rgbGen vertex
		blendFunc add
	}
}

textures/dev/ground2
{
	{
		program glsl/ground.glsl#vertexlit
		map $nearest:textures/dev/ground.tga
		map $linear:textures/dev/terrain_gradient.tga
	}
}

textures/dev/ground
{
	{
		program glsl/ground.glsl
		map $nearest:textures/dev/ground.tga
		map $linear:textures/dev/terrain_gradient.tga
	}
}

textures/dev/ground2
{
	{
	 	map $nearest:textures/dev/ground.tga
		rgbGen entity
	}
}

alien
{
	{
		program glsl/defaultskin2.glsl
		map $nearest:models/alien.png
	}
}

aliengun
{
	{
		program glsl/defaultskin2.glsl
		map $nearest:models/aliengun.png
	}
}


ak
{
	{
		program glsl/defaultskin2.glsl
		map $nearest:models/ak
	}
}

mp5
{
	{
		program glsl/defaultskin2.glsl
		map $nearest:models/mp5
	}
}

usp
{
	{
		program glsl/defaultskin2.glsl
		map $nearest:models/usp
	}
}



skysky
{
	{
		map $nearest:textures/dev/skysky.tga
	}
}

crosshair
{
	// cull disable
	{
		map $whitetexture
		rgbGen vertex
		alphaGen vertex
		blendFunc blend
		// nodepthtest
	}
}

bullet
{
	{
		map models/bullet
		blendFunc add
	}
}

alienbullet
{
	{
		map models/alienbullet
		blendFunc add
	}
}


ak_mzl
{
	{
		map $nearest:models/ak_mzl
		blendFunc add
		rgbGen entity
		alphaGen entity
	}
}

mp5_mzl
{
	{
		map $nearest:models/mp5_mzl
		blendFunc add
		rgbGen entity
		alphaGen entity
	}
}

textures/heart
{
	{
		map $nearest:textures/heart
		alphafunc GE128
		blendfunc blend
	}
}