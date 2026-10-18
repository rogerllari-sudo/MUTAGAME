shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.4, 0.9, 1.0, 1.0);
uniform float intensity : hint_range(0.0, 2.0) = 0.0;
uniform float softness : hint_range(0.1, 3.0) = 1.4;

void fragment() {
	vec2 centered_uv = UV - vec2(0.5);

	float distance_from_center = length(
		centered_uv * vec2(1.0, 1.25)
	);

	float glow = 1.0 - smoothstep(
		0.0,
		0.43,
		distance_from_center
	);

	glow = pow(glow, softness);

	float safe_intensity = clamp(
		intensity,
		0.0,
		2.0
	);

	COLOR = vec4(
		glow_color.rgb,
		glow * safe_intensity
	);
}
