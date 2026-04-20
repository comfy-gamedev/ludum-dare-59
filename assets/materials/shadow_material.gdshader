shader_type canvas_item;

uniform sampler2D noise;
uniform sampler2D color_ramp : filter_nearest, hint_default_white;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	float noiseValue = texture(noise, SCREEN_UV).x;
	vec3 final_color = texture(color_ramp, vec2(noiseValue, 0.5)).rgb;
    COLOR = vec4(final_color.x, final_color.y, final_color.z, .5);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
