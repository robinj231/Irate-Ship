shader_type spatial;

uniform float wave_height = 0.2;
uniform sampler2D example_texture : hint_albedo;

void vertex()
{
	VERTEX.y += sin(TIME * 5.0 + VERTEX.x * 10.0) * wave_height;
}

void fragment()
{
	vec3 wave_color;
	wave_color.r = (sin(TIME * 6.0 + VERTEX.x * 10.0) + 1.0) * 0.5;
	wave_color.g = (sin(TIME * 7.0 + VERTEX.x * 10.0) + 1.0) * 0.5;
	wave_color.b = (sin(TIME * 8.0 + VERTEX.x * 10.0) + 1.0) * 0.5;
	vec3 texture_color = texture(example_texture, UV).rgb;
	vec3 out_color = wave_color * texture_color;
	ALBEDO = out_color;
}