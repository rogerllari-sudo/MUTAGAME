shader_type canvas_item;


/*
TRANSICIÓ DE DIGITALITZACIÓ MOLECULAR

- progress = 0: invisible
- progress = 1: pantalla completament coberta
- els detalls digitals es concentren al front de l'ona
*/


uniform vec4 core_color : source_color = vec4(
	0.88,
	1.0,
	1.0,
	1.0
);

uniform vec4 energy_color : source_color = vec4(
	0.40,
	0.90,
	1.0,
	1.0
);

uniform vec4 electric_color : source_color = vec4(
	0.0,
	0.72,
	0.95,
	1.0
);

uniform vec4 deep_color : source_color = vec4(
	0.02,
	0.20,
	0.32,
	1.0
);

uniform vec2 center = vec2(0.5, 0.5);

uniform float progress : hint_range(
	0.0,
	1.0
) = 0.0;

uniform float aspect_ratio = 1.777778;

uniform float edge_softness : hint_range(
	0.001,
	0.15
) = 0.025;


float random_value(vec2 coordinate) {
	return fract(
		sin(
			dot(
				coordinate,
				vec2(12.9898, 78.233)
			)
		) * 43758.5453
	);
}


void fragment() {
	if (progress <= 0.001) {
		COLOR = vec4(0.0);
	} else {
		// ----------------------------------------------------
		// COORDENADES CORREGIDES PER LA PROPORCIÓ DE PANTALLA
		// ----------------------------------------------------

		vec2 delta = UV - center;
		delta.x *= aspect_ratio;

		float distance_from_center = length(delta);

		float maximum_radius = 1.25;
		float current_radius = progress * maximum_radius;

		float normalized_distance = (
			distance_from_center
			/ max(current_radius, 0.001)
		);


		// ----------------------------------------------------
		// MÀSCARA PRINCIPAL DE COBERTURA
		// ----------------------------------------------------

		float inside_mask = 1.0 - smoothstep(
			current_radius,
			current_radius + edge_softness,
			distance_from_center
		);


		// ----------------------------------------------------
		// FRONT BLANC D'ENERGIA
		// ----------------------------------------------------

		float distance_to_front = abs(
			distance_from_center - current_radius
		);

		float bright_front = 1.0 - smoothstep(
			0.0,
			0.022,
			distance_to_front
		);

		float outer_halo = 1.0 - smoothstep(
			0.015,
			0.090,
			distance_to_front
		);


		// ----------------------------------------------------
		// ANELL SEGMENTAT D'ESCANEIG
		// ----------------------------------------------------

		float angle = atan(
			delta.y,
			delta.x
		);

		float angular_pattern = (
			sin(
				angle * 36.0
				- progress * 18.0
			) * 0.5
			+ 0.5
		);

		float segmented_ring = smoothstep(
			0.58,
			0.82,
			angular_pattern
		);

		segmented_ring *= bright_front;


		// ----------------------------------------------------
		// CEL·LES DIGITALS AL VOLTANT DEL FRONT
		// ----------------------------------------------------

		vec2 digital_grid = floor(
			UV * vec2(72.0, 40.0)
		);

		float digital_random = random_value(
			digital_grid
		);

		float digital_cells = step(
			0.88,
			digital_random
		);

		digital_cells *= outer_halo;
		digital_cells *= 0.40;


		// ----------------------------------------------------
		// LÍNIES D'ESCANEIG SUBTILS
		// ----------------------------------------------------

		float scan_wave = (
			sin(
				UV.y * 720.0
				- progress * 45.0
			) * 0.5
			+ 0.5
		);

		float scan_lines = smoothstep(
			0.91,
			1.0,
			scan_wave
		);

		scan_lines *= inside_mask;
		scan_lines *= 0.055;


		// ----------------------------------------------------
		// COLOR INTERIOR
		// ----------------------------------------------------

		float radial_gradient = clamp(
			normalized_distance,
			0.0,
			1.0
		);

		vec3 final_color = mix(
			core_color.rgb,
			energy_color.rgb,
			smoothstep(
				0.0,
				0.42,
				radial_gradient
			)
		);

		final_color = mix(
			final_color,
			electric_color.rgb,
			smoothstep(
				0.42,
				1.0,
				radial_gradient
			)
		);

		// Una mica de profunditat perquè no sigui cian pla
		final_color = mix(
			deep_color.rgb,
			final_color,
			0.88
		);


		// ----------------------------------------------------
		// DETALLS DIGITALS
		// ----------------------------------------------------

		final_color += (
			core_color.rgb
			* bright_front
			* 1.15
		);

		final_color += (
			energy_color.rgb
			* segmented_ring
			* 0.65
		);

		final_color += (
			core_color.rgb
			* digital_cells
		);

		final_color += (
			energy_color.rgb
			* scan_lines
		);


		// ----------------------------------------------------
		// ALFA FINAL
		// ----------------------------------------------------

		float final_alpha = max(
			inside_mask,
			outer_halo * 0.22
		);

		COLOR = vec4(
			final_color,
			final_alpha
		);
	}
}