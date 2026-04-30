shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;
uniform float blur_amount : hint_range(0.0, 5.0) = 2.0;
uniform bool enabled = true;

const int TAPS = 48;
const float GOLDEN_ANGLE = 2.39996323;
const float TWO_PI = 6.28318530;

// Jorge Jimenez's Interleaved Gradient Noise — perceptually smooth dither.
float ign(vec2 p) {
    return fract(52.9829189 * fract(0.06711056 * p.x + 0.00583715 * p.y));
}

void fragment() {
    if (!enabled || blur_amount <= 0.001) {
        COLOR = texture(screen_texture, SCREEN_UV);
    } else {
        vec2 radius = SCREEN_PIXEL_SIZE * blur_amount * 14.0;
        float rot = ign(FRAGCOORD.xy) * TWO_PI;
        float cr = cos(rot);
        float sr = sin(rot);
        mat2 R = mat2(vec2(cr, -sr), vec2(sr, cr));

        vec4 sum = vec4(0.0);
        float total = 0.0;
        for (int i = 0; i < TAPS; i++) {
            float a = float(i) * GOLDEN_ANGLE;
            float r = sqrt((float(i) + 0.5) / float(TAPS));
            vec2 dir = vec2(cos(a), sin(a));
            vec2 offset = R * (dir * r);
            float w = exp(-r * r * 1.5);
            sum += texture(screen_texture, SCREEN_UV + offset * radius) * w;
            total += w;
        }
        COLOR = sum / total;
    }
}