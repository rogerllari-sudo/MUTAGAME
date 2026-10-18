shader_type canvas_item;
render_mode unshaded, blend_add;

uniform vec4 glow_color : source_color = vec4(
	0.20,
	0.85,
	1.00,
	1.00
);

uniform float intensity : hint_range(0.0, 2.0) = 0.75;

void fragment() {
	vec2 p = UV - vec2(0.5);

	// Forma el·líptica, ampla i baixa
	float distance_from_center = length(
		vec2(
			p.x / 0.62,
			p.y / 0.42
		)
	);

	float glow = 1.0 - smoothstep(
		0.0,
		1.0,
		distance_from_center
	);

	glow = pow(glow, 1.5);

	COLOR = vec4(
		glow_color.rgb * glow * intensity,
		glow * intensity
	);
}
