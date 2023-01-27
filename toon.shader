shader_type spatial;
render_mode async_visible,blend_mix,depth_draw_opaque,cull_back,unshaded;

uniform bool specular = false;
uniform bool rim = false;

uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;

uniform vec4 ambientColor : hint_color = vec4(0.4,0.4,0.4,1);
uniform vec4 specularColor : hint_color = vec4(0.9,0.9,0.9,1);
uniform float glossiness = 32;

uniform sampler2D diffuseCurve : hint_white;

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;

uniform vec3 lightDir;
uniform vec4 lightColor : hint_color = vec4(1, 1, 1, 1);

uniform vec4 rimColor : hint_color = vec4(1,1,1,1);
uniform float rimAmount : hint_range(0,1) = 0.716;
uniform float rimThreshold : hint_range(0,1) = 0.1;

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
}

void fragment() {
	vec3 viewLightDir = normalize((INV_CAMERA_MATRIX * vec4(lightDir, 0.0)).xyz);
	float NdotL = dot(NORMAL, viewLightDir);
	float lightIntensity = smoothstep(0, 0.01, NdotL);
	
	vec3 light = lightIntensity * lightColor.rgb;
	
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	
	vec3 lightingFinal = ambientColor.rgb + light;
	
	if(specular)
	{
		vec3 halfVector = normalize(lightDir + VIEW);
		float NdotH = dot(NORMAL, halfVector);
		float specularIntensity = pow(NdotH * lightIntensity, glossiness * glossiness);
		float specularIntensitySmooth = smoothstep(0.005, 0.01, specularIntensity);
		vec4 specularFinal = specularIntensitySmooth * specularColor;
		lightingFinal += specularFinal.rgb;
	}
	
	if(rim)
	{
		float rimDot = 1.0 - dot(VIEW, NORMAL);
		float rimIntensity = rimDot * pow(NdotL, rimThreshold);
		rimIntensity = smoothstep(rimAmount - 0.01, rimAmount + 0.01, rimIntensity);
		vec4 rimFinal = rimIntensity * rimColor;
		lightingFinal += rimFinal.rgb;
	}
	
	ALBEDO = albedo.rgb * albedo_tex.rgb * lightingFinal;
}