
shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap; 
void fragment(){
	vec4 color = texture(SCREEN_TEXTURE, UV);
	COLOR = vec4(1.0 - color.rgb, color.a);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
