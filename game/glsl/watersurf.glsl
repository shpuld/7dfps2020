!!ver 100 150
!!permu TESS
!!permu FULLBRIGHT
!!permu UPPERLOWER
!!permu FRAMEBLEND
!!permu SKELETAL
!!permu FOG
!!permu BUMP
!!permu REFLECTCUBEMASK
!!cvarf r_glsl_offsetmapping_scale
!!cvarf gl_specular
!!cvardf gl_affinemodels=0
!!cvardf r_tessellation_level=5
!!samps !EIGHTBIT diffuse normalmap specular fullbright upper lower reflectmask reflectcube
!!samps =EIGHTBIT paletted 1
!!samps =OCCLUDE occlusion
//!!permu VC			// adds rgba vertex colour multipliers
//!!permu SPECULAR		// auto-added when gl_specular>0
//!!permu OFFSETMAPPING	// auto-added when r_glsl_offsetmapping is set
//!!permu NONORMALS		// states that there's no normals available, which affects lighting.
//!!permu ORM			// specularmap is r:Occlusion, g:Roughness, b:Metalness
//!!permu SG			// specularmap is rgb:F0, a:Roughness (instead of exponent)
//!!permu PBR			// an attempt at pbr logic (enabled from ORM or SG)
//!!permu NOOCCLUDE		// ignores the use of ORM's occlusion... yeah, stupid.
//!!permu OCCLUDE		// use an explicit occlusion texturemap (separate from roughness+metalness).
//!!permu EIGHTBIT		// uses software-style paletted colourmap lookups
//!!permu ALPHATEST		// if defined, this is the required alpha level (more versatile than doing it at the q3shader level)

#include "sys/defs.h"

#if gl_affinemodels==1 && __VERSION__ >= 130 && !defined(GL_ES)
#define affine noperspective
#else
#define affine
#endif

#ifdef NONORMALS	//lots of things need normals to work properly. make sure nothing breaks simply because they added an extra texture.
	#undef BUMP
	#undef SPECULAR
	#undef OFFSETMAPPING
	#undef REFLECTCUBEMASK
#endif


#ifdef VERTEX_SHADER
#include "sys/skeletal.h"

affine varying vec2 tc;
varying vec3 eyevector;
varying vec4 vp;

void main ()
{
	vec4 p;
#ifdef NONORMALS
	vec3 n, w;
	p = skeletaltransform_w(w);
	n = vec3(0.0);
#else
	vec3 n, s, t, w;
	p = skeletaltransform_wnst(w,n,s,t);
#endif
	gl_Position = p;
	tc = v_texcoord;
	vp = gl_Position;
}
#endif






#ifdef FRAGMENT_SHADER

#include "sys/fog.h"
uniform sampler2D	s_t0;

affine varying vec2 tc;
varying vec3 eyevector;
varying vec4 vp;


void main ()
{
	vec4 col;

	col = texture2D(s_t0,tc * 180.0 + vec2(e_time * 0.05, e_time * 0.06)) * 3.5 +
		texture2D(s_t0, tc * 110.0 + vec2(sin(e_time * 0.1), cos(e_time * 0.1))) * 3.8 +
		texture2D(s_t0,tc * 30.0 + vec2(e_time * -0.03, e_time * -0.04)) * 6.9;
	
	col.rgb *= (vec3(1.6) - col.rgb);
	col.rgb = (col.rgb - vec3(0.2)) * 0.5;
	col += col * texture2D(s_t0,tc * 140.0 + vec2(e_time * 0.04, e_time * 0.05)) * 3.5;
	
	float d = 1.0 - min(1.0, length(vec3(eyevector.x, eyevector.y, 0.0) - vp.xyz) * 0.00005);
	col.rgb -= d * 0.22;
	// col *= factor_base;

	// col *= 1.1 * e_colourident;

	gl_FragColor = col;
}
#endif

