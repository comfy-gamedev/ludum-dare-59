shader_type canvas_item;

uniform sampler2D noise;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	float noiseValue = texture(noise, SCREEN_UV).x;
    COLOR = vec4(noiseValue - 0.5, noiseValue - 0.5, noiseValue - 0.5, noiseValue);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
