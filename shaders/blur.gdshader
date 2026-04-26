shader_type canvas_item;

// hint_screen_texture allows us to access the background
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float blur_amount : hint_range(0.0, 5.0) = 2.0;
uniform bool enabled = true;

void fragment() {
    if (enabled) {
        // textureLod samples the screen with the specified blur amount (mip level)
        COLOR = textureLod(screen_texture, SCREEN_UV, blur_amount);
    } else {
        // If disabled, just output the normal screen texture
        COLOR = texture(screen_texture, SCREEN_UV);
    }
}