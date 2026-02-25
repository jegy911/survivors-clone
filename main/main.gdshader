shader_type canvas_item;

uniform vec4 bg_color : source_color = vec4(0.04, 0.06, 0.04, 1.0);
uniform vec4 grid_color : source_color = vec4(0.12, 0.20, 0.12, 1.0);
uniform vec4 grid_color2 : source_color = vec4(0.18, 0.30, 0.18, 1.0);
uniform float grid_size = 64.0;
uniform float grid_size2 = 256.0;
uniform float line_width = 1.5;
uniform vec2 offset = vec2(0.0, 0.0);

void fragment() {
	vec2 world_pos = VERTEX + offset;
	
	// Küçük grid
	vec2 grid1 = mod(world_pos, grid_size);
	float line1 = step(grid_size - line_width, grid1.x) + step(grid_size - line_width, grid1.y);
	line1 = clamp(line1, 0.0, 1.0);
	
	// Büyük grid
	vec2 grid2 = mod(world_pos, grid_size2);
	float line2 = step(grid_size2 - line_width * 2.5, grid2.x) + step(grid_size2 - line_width * 2.5, grid2.y);
	line2 = clamp(line2, 0.0, 1.0);
	
	vec4 color = bg_color;
	color = mix(color, grid_color, line1 * 0.9);
	color = mix(color, grid_color2, line2);
	
	COLOR = color;
}