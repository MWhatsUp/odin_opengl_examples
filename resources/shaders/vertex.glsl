#version 330 core

layout (location = 0) in vec2 vertex_position;
layout (location = 1) in vec2 texture_coordinates;

out vec2 fragment_coordinates;

void main() {
        fragment_coordinates = texture_coordinates;

        gl_Position = vec4(vertex_position, 0, 1);
}
