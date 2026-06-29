shader_type canvas_item;

uniform float chromatic_aberration : hint_range(0.0, 20.0) = 0.0;
uniform float glitch_intensity : hint_range(0.0, 1.0) = 0.0;
uniform float glitch_frequency : hint_range(0.0, 100.0) = 10.0;
uniform vec2 uv_min = vec2(0.0, 0.0);
uniform vec2 uv_max = vec2(1.0, 1.0);

// Simple random function
float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 uv = UV;
	
	// Scanline glitch
	if (glitch_intensity > 0.0) {
		float time_val = floor(TIME * glitch_frequency);
		// Split vertical space into rows
		float row = floor(uv.y * 30.0);
		// Check if this row is glitched
		if (rand(vec2(row, time_val)) < glitch_intensity * 0.4) {
			// Offset horizontally
			float shift = (rand(vec2(time_val, row)) - 0.5) * glitch_intensity * 0.08;
			uv.x = clamp(uv.x + shift, uv_min.x, uv_max.x);
		}
	}
	
	vec4 col;
	if (chromatic_aberration > 0.0) {
		// Calculate pixel-based offset
		vec2 offset = vec2(chromatic_aberration * TEXTURE_PIXEL_SIZE.x, 0.0);
		
		vec2 uv_r = clamp(uv - offset, uv_min, uv_max);
		vec2 uv_g = clamp(uv, uv_min, uv_max);
		vec2 uv_b = clamp(uv + offset, uv_min, uv_max);
		
		float r = texture(TEXTURE, uv_r).r;
		float g = texture(TEXTURE, uv_g).g;
		float b = texture(TEXTURE, uv_b).b;
		
		float a_r = texture(TEXTURE, uv_r).a;
		float a_g = texture(TEXTURE, uv_g).a;
		float a_b = texture(TEXTURE, uv_b).a;
		
		col = vec4(r, g, b, max(a_g, max(a_r, a_b)));
	} else {
		col = texture(TEXTURE, uv);
	}
	
	COLOR = col;
}
