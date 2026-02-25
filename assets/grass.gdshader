shader_type canvas_item;

uniform vec2 offset = vec2(0.0, 0.0);

float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));
    
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    for (int i = 0; i < 5; i++) {
        value += amplitude * noise(p * frequency);
        amplitude *= 0.5;
        frequency *= 2.0;
    }
    return value;
}

void fragment() {
    vec2 uv = (FRAGCOORD.xy + offset * 0.05) / 200.0;
    
    float n = fbm(uv);
    float n2 = fbm(uv * 2.5 + vec2(5.3, 9.1));
    float n3 = fbm(uv * 6.0 + vec2(2.1, 4.7));
    
    // Temel yeşil tonları
    vec3 dark_green = vec3(0.12, 0.28, 0.08);
    vec3 mid_green = vec3(0.18, 0.38, 0.10);
    vec3 light_green = vec3(0.22, 0.45, 0.13);
    vec3 pale_green = vec3(0.26, 0.50, 0.16);
    
    vec3 color = mix(dark_green, mid_green, n);
    color = mix(color, light_green, n2 * 0.6);
    color = mix(color, pale_green, n3 * 0.3);
    
    // Küçük çimen detayları
    float detail = noise(uv * 20.0 + offset * 0.002);
    color += vec3(0.0, detail * 0.05, 0.0);
    
    COLOR = vec4(color, 1.0);
}