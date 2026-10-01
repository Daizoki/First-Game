shader_type canvas_item;
// Darkens the screen except for up to 8 soft-edged rounded "holes" (the tutorial's light).
// Works on the Compatibility renderer. Holes are in pixels of the overlay: x, y, width, height.

const int MAX_HOLES = 8;

uniform vec2 area_size = vec2(1920.0, 1080.0);
uniform int hole_count = 0;
uniform vec4 holes[MAX_HOLES];
uniform float softness = 30.0;
uniform float corner = 22.0;
uniform float dim : hint_range(0.0, 1.0) = 0.66;
uniform vec4 tint : source_color = vec4(0.02, 0.024, 0.04, 1.0);

float rounded_box(vec2 p, vec2 half_size, float r) {
	vec2 q = abs(p) - half_size + vec2(r);
	return length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0) - r;
}

void fragment() {
	vec2 p = UV * area_size;
	float light = 0.0;
	for (int i = 0; i < MAX_HOLES; i++) {
		if (i >= hole_count) {
			break;
		}
		vec4 h = holes[i];
		float d = rounded_box(p - (h.xy + h.zw * 0.5), h.zw * 0.5, min(corner, min(h.z, h.w) * 0.5));
		light = max(light, 1.0 - smoothstep(-softness * 0.25, softness, d));
	}
	COLOR = vec4(tint.rgb, dim * (1.0 - light));
}
