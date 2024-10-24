shader_type canvas_item;

uniform sampler2D mask;

void fragment() {
	// set alpha to 1 if the mask has any color
	COLOR.a = 1.0 - texture(mask, UV).a;
}
