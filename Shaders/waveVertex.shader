shader_type spatial;
//render_mode async_visible,blend_mix,depth_draw_opaque,cull_back,unshaded;
render_mode async_visible,blend_mix,depth_draw_always,cull_back,diffuse_burley,specular_schlick_ggx;

uniform float roughness : hint_range(0,1) = 0.2;
uniform float metallic : hint_range(0,1) = 1.0;
uniform float specular : hint_range(0,1) = 1.0;

const float pi = 3.14159265358979323846;

uniform vec4 albedo : hint_color = vec4(1,1,1,1);
uniform sampler2D texture_albedo : hint_albedo;
uniform sampler2D edge_noise : hint_white;
uniform sampler2D texture_noise : hint_white;

uniform vec4 ambientColor : hint_color = vec4(0.4,0.4,0.4,1);

uniform sampler2D diffuseCurve : hint_white;

uniform vec3 uv1_scale = vec3(1,1,1);
uniform vec3 uv1_offset;

uniform vec3 lightDir = vec3(1,1,1);
uniform vec4 lightColor : hint_color = vec4(1, 1, 1, 1);

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
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	vec3 tangent = vec3(1,0,0);
	vec3 binormal = vec3(0,0,1);
	VERTEX.y = gerstnerWave(waveADir, waveASteepness, waveALength, VERTEX, tangent, binormal);
	VERTEX.y += gerstnerWave(waveBDir, waveBSteepness, waveBLength, VERTEX, tangent, binormal);
	VERTEX.y += gerstnerWave(waveCDir, waveCSteepness, waveCLength, VERTEX, tangent, binormal);
	NORMAL = normalize(cross(binormal, tangent));
}

/*
void fragment() {
	vec3 viewLightDir = normalize((INV_CAMERA_MATRIX * vec4(lightDir, 0.0)).xyz);
	float NdotL = dot(NORMAL, viewLightDir);
	float lightIntensity = smoothstep(0, 0.01, NdotL);
	
	vec3 light = lightIntensity * lightColor.rgb;
	
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	
	vec3 lightingFinal = ambientColor.rgb + light;
	
	ALBEDO = albedo.rgb * albedo_tex.rgb * lightingFinal;
}
*/

void fragment() {
	// These calculate the distance between the water and whatever's behind it,
	// exactly at the pixel we are looking at with the depth texture. Because we
	// use it, we are sent to the transparent pipeline, meaning the sea doesn't
	// appear behind other transparent objects.
	float zdepth = linearize(texture(DEPTH_TEXTURE, SCREEN_UV).x, INV_PROJECTION_MATRIX, SCREEN_UV);
	float zpos = linearize(FRAGCOORD.z, INV_PROJECTION_MATRIX, SCREEN_UV);
	float diff = zdepth - zpos;
	
	vec2 turbidity = normalize(waveADir * max(waveASteepness, 0.5) + waveBDir * waveBSteepness + waveCDir * waveCSteepness);
	
	vec2 tex_displ = texture(texture_noise, UV / displacement_scale).rg;
	tex_displ = (2.0 * tex_displ - 1.0) * texture_displacement;
	tex_displ += objTime * .05 * turbidity;
	
	vec2 base_uv = UV + tex_displ;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	if(diff < foamDistance)
	{
		ALBEDO = vec3(1,1,1);
	}
	else
	{
		ALBEDO = albedo.rgb * albedo_tex.rgb;
	}
	ROUGHNESS = roughness;
	SPECULAR = specular;
	METALLIC = metallic;
}