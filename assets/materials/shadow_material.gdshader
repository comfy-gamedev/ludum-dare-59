shader_type canvas_item;

uniform sampler2D color_ramp : filter_nearest, hint_default_white;

uniform float scroll_speed = 0.01;
uniform float scale = 8.0;
uniform int octaves = 5;
uniform float ping_pong_strength = 4.0;

uniform float pixel_size : hint_range(1.0, 32.0, 1.0) = 3.0;
uniform float fps_limit : hint_range(1.0, 60.0, 1.0) = 15.0;
uniform int dithering_strength = 3;

// 1. 3D Hash function to generate random feature points
vec3 hash33(vec3 p) {
    p = vec3(dot(p, vec3(127.1, 311.7, 74.7)),
             dot(p, vec3(269.5, 183.3, 246.1)),
             dot(p, vec3(113.5, 271.9, 124.6)));
    return fract(sin(p) * 43758.5453123);
}

// 2. Cellular Noise using Manhattan Distance
float cellular_manhattan(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);

    float min_dist = 99999.0;

    for(int k = -1; k <= 1; k++) {
        for(int j = -1; j <= 1; j++) {
            for(int l = -1; l <= 1; l++) {
                vec3 neighbor = vec3(float(l), float(j), float(k));
                vec3 feature_point = hash33(i + neighbor);

                vec3 diff = neighbor + feature_point - f;

                // MANHATTAN DISTANCE: |x| + |y| + |z|
                float dist = abs(diff.x) + abs(diff.y) + abs(diff.z);

                min_dist = min(min_dist, dist);
            }
        }
    }
    
    return min_dist * 0.5; 
}

// 3. Ping-Pong Fold Function
float pingpong(float x) {
    return 1.0 - abs(1.0 - mod(x, 2.0));
}

// 4. Fractal Loop
float fractal_ping_pong_cellular(vec3 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;

    for (int i = 0; i < octaves; i++) {
        float n = cellular_manhattan(p * frequency);
        n = pingpong(n * ping_pong_strength);
        value += n * amplitude;
        
        frequency *= 2.0; 
        amplitude *= 0.5; 
    }
    return value;
}

void fragment() {
	vec2 screen_dims = 1.0 / SCREEN_PIXEL_SIZE;
    vec2 block_count = screen_dims / pixel_size;
    vec2 pixelated_uv = floor(SCREEN_UV * block_count) / block_count;
	if(int(FRAGCOORD.x + FRAGCOORD.y) % dithering_strength == 0){
		discard;
	}
	
	float stepped_time = floor(TIME * fps_limit) / fps_limit;
	vec3 noise_coords = vec3(pixelated_uv.x + (stepped_time * scroll_speed), pixelated_uv.y, stepped_time * scroll_speed) * scale;
	float final_noise = fractal_ping_pong_cellular(noise_coords);
	
	vec3 final_color = texture(color_ramp, vec2(final_noise, 0.5)).rgb;
	COLOR = vec4(final_color.x, final_color.y, final_color.z, 1);
}
