#version 330

layout (location = 0) in vec3 aPos;

uniform mat4 proj;
//uniform mat4 model;
uniform mat4 view;

uniform float waterLevel;

void main()
{
    gl_Position = proj * view * mat4(1) * vec4(aPos.x, waterLevel, aPos.z, 1.0f);
}