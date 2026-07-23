shader_type canvas_item;

uniform vec4 target_color : source_color = vec4(0.0, 1.0, 0.0, 1.0);
uniform float precision : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 current_colo = texture(TEXTURE, UV);
	vec4 modulate = COLOR;
	float color_distance = distance(current_colo.rgb, target_color.rgb);
	if (color_distance < precision) {
		current_colo.a = 0.0;
	}
	
	COLOR = current_colo.a * modulate;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
