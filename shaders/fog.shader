shader_type spatial;
render_mode depth_draw_always, specular_schlick_ggx, cull_disabled;

// Caustics
uniform bool debug = false;
uniform vec4 color : hint_color = vec4(1.0);
uniform float strength = 1.0;
uniform vec2 deep_fade = vec2(3.0, 5.0);
uniform vec2 distance_fade = vec2(0.0, 1.0);

varying mat4 inv_mvp; 


void vertex() {
	inv_mvp = inverse(PROJECTION_MATRIX * MODELVIEW_MATRIX);
}

void fragment() {
	// Depthtest
	float depth_tex = textureLod(DEPTH_TEXTURE, SCREEN_UV, 0.0).r;
	float depth_tex_unpacked = depth_tex * 2.0 - 1.0;
	float surface_dist = PROJECTION_MATRIX[3][2] / (depth_tex_unpacked + PROJECTION_MATRIX[2][2]);
	float water_depth = surface_dist + VERTEX.z;
	
	// Caustic
	float depth_blend = exp(water_depth * -2.0); // -2.0 == Beer's law
	vec4 caustic_screenPos = vec4(SCREEN_UV*2.0-1.0, depth_tex_unpacked, 1.0);
	vec4 caustic_localPos = inv_mvp * caustic_screenPos;
	caustic_localPos = vec4(caustic_localPos.xyz/caustic_localPos.w, caustic_localPos.w);
	float caustic_depth_fade = smoothstep(deep_fade.x, deep_fade.y, water_depth);
	caustic_depth_fade = 1.0 - caustic_depth_fade;
	caustic_depth_fade = clamp(caustic_depth_fade, 0.0, 1.0);
	float fog = caustic_depth_fade * strength;

	// Fade
	float distance = length(UV.xy - vec2(0.5, 0.5));
	float fade = 1.0-smoothstep(distance_fade.x, distance_fade.y, distance);

	ALBEDO *= 0.0;
	if (debug) {
		ALPHA = 1.0;
	}
	else {
		ALPHA = fog;
	}
	SPECULAR = 0.0;
	ROUGHNESS = 1.0;
	EMISSION += mix(texture(SCREEN_TEXTURE, SCREEN_UV).rgb, color.rgb * vec3(fog), vec3(fade));
}