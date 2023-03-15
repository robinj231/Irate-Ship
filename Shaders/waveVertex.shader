shader_type spatial;
render_mode async_visible,blend_mix,depth_draw_always,cull_back,unshaded;
//render_mode async_visible,blend_mix,depth_draw_always,cull_back,diffuse_burley,specular_schlick_ggx;

const float pi = 3.14159265358979323846;

uniform float fogStart;
uniform float fogEnd;
uniform vec4 fogColor : hint_color = vec4(1,1,1,1);
uniform sampler2D fogCurve;

uniform vec4 albedo : hint_color = vec4(1,1,1,1);
uniform sampler2D foam_texture : hint_albedo;
uniform sampler2D edge_noise : hint_white;
uniform sampler2D texture_noise : hint_white;

uniform vec4 ambientColor : hint_color = vec4(0.4,0.4,0.4,1);

uniform sampler2D diffuseCurve : hint_white;

uniform vec3 uv1_scale = vec3(1,1,1);
uniform vec3 uv1_offset;

// wave(dir.x, dir.y, steepness, wavelength)
uniform vec2 waveADir;
uniform float waveASteepness;
uniform float waveALength;
uniform vec2 waveBDir;
uniform float waveBSteepness;
uniform float waveBLength;
uniform vec2 waveCDir;
uniform float waveCSteepness;
uniform float waveCLength;
uniform float objTime = 0;

uniform float foamDistance = 0.4;

uniform float texture_displacement = 0.075;
uniform vec2 displacement_scale = vec2(5,5);

uniform vec4 edge_color : hint_color = vec4(1.0);
uniform float edge_smoothness = 0.05;
uniform float edge_max_threshold = 0.5;
uniform float edge_displacement = 0.6;

uniform vec3 playerPos;

float linearize(float depth, mat4 inv_proj, vec2 screen_uv) {
	vec4 view_pos = inv_proj * vec4(vec3(screen_uv, depth) * 2.0 - 1.0, 1.0);
	return -view_pos.z / view_pos.w;
}


float gerstnerWave(vec2 waveDir, float waveSteepness, float waveLength, vec3 vertex, inout vec3 tangent, inout vec3 binormal)
{
    float k = 2.0 * pi / waveLength;
	float c = sqrt(9.8 / k);
	vec2 d = normalize(waveDir);
	float f = k * (dot(d, vertex.xz) - c * objTime);
	float a = waveSteepness / k;
	
	//p.x += d.x * (a * cos(f));
	//p.y = a * sin(f);
	//p.z += d.y * (a * cos(f));

	tangent += vec3(
		-d.x * d.x * (waveSteepness * sin(f)),
		d.x * (waveSteepness * cos(f)),
		-d.x * d.y * (waveSteepness * sin(f))
	);
	binormal += vec3(
		-d.x * d.y * (waveSteepness * sin(f)),
		d.y * (waveSteepness * cos(f)),
		-d.y * d.y * (waveSteepness * sin(f))
	);
	return a * sin(f);
}

void vertex() {
	UV=(WORLD_MATRIX*vec4(UV.x,1,UV.y,1)).xz;
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	vec3 tangent = vec3(1,0,0);
	vec3 binormal = vec3(0,0,1);
	vec3 worldVertexPos = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz;
	VERTEX.y = gerstnerWave(waveADir, waveASteepness, waveALength, worldVertexPos, tangent, binormal);
	VERTEX.y += gerstnerWave(waveBDir, waveBSteepness, waveBLength, worldVertexPos, tangent, binormal);
	VERTEX.y += gerstnerWave(waveCDir, waveCSteepness, waveCLength, worldVertexPos, tangent, binormal);
	NORMAL = normalize(cross(binormal, tangent));
}

void fragment() {
	// These calculate the distance between the water and whatever's behind it,
	// exactly at the pixel we are looking at with the depth texture. Because we
	// use it, we are sent to the transparent pipeline, meaning the sea doesn't
	// appear behind other transparent objects.
	float zdepth = linearize(texture(DEPTH_TEXTURE, SCREEN_UV).x, INV_PROJECTION_MATRIX, SCREEN_UV);
	float zpos = linearize(FRAGCOORD.z, INV_PROJECTION_MATRIX, SCREEN_UV);
	float diff = zdepth - zpos;
	
	// These randomize the difference calculated previously using the displacement
	// texture and amount. The second to last line checks if the pixel is not in
	// in front of the water. Try commenting it out and see some pesky 1 pixel
	// wide outline around anything in front of the sea.
	float edge_displ = texture(edge_noise, UV - objTime / 60.0).r;
	edge_displ = ((edge_displ * 2.0) - 1.0) * edge_displacement;
	float t = diff < 0.0 ? 1.0 : diff + edge_displ;
	float smoothness = smoothstep(edge_max_threshold, edge_max_threshold + edge_smoothness, t);
	
	vec2 turbidity = normalize(waveADir * max(waveASteepness, 0.5) + waveBDir * waveBSteepness + waveCDir * waveCSteepness);
	
	vec2 tex_displ = texture(texture_noise, UV / displacement_scale).rg;
	tex_displ = (2.0 * tex_displ - 1.0) * texture_displacement;
	tex_displ += objTime * .05 * turbidity;
	
	vec2 base_uv = UV + tex_displ;
	vec4 albedo_tex = albedo + texture(foam_texture,base_uv)*edge_color;
	
	ALBEDO = mix(edge_color, albedo_tex, smoothness).rgb;
	if(zpos > fogStart)
	{
		float fogCurveVal = texture(fogCurve, vec2((zpos-fogStart)/(fogEnd-fogStart),0)).r;
		ALBEDO = mix(ALBEDO, fogColor.rgb, fogCurveVal);
	}
	
}