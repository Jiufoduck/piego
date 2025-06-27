
shader_type canvas_item;

uniform float speed = 50.0;
uniform float dash_size = 60.0;
uniform float gap_size = 60.0;
const vec2 texture_size = vec2(500,33);

void fragment() {
    float pattern_length = dash_size + gap_size;
    float pos = UV.x * TEXTURE_PIXEL_SIZE.x * texture_size.x;
    float moving_pos = pos - TIME * speed;
    float mod_pos = mod(moving_pos, pattern_length);

    if (mod_pos > dash_size) {
        discard;
    }
    COLOR = texture(TEXTURE, UV);
}