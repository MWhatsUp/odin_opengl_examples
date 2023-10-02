#version 330 core

in vec2 fragment_coordinates;
uniform sampler2D texture_sampler;

out vec4 fragment_color;

vec4 normal_color;

void main() {
    normal_color = texture(texture_sampler, fragment_coordinates);
    fragment_color = vec4( normal_color.rgb, normal_color.a);
}
