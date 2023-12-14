#version 330

layout (location = 0) in vec3 aPos;

uniform mat4 proj;
// uniform mat4 model;
uniform mat4 view;

out float height;


void main()
{
    gl_Position = proj * view * mat4(1.0f) * vec4(aPos, 1.0);
    height = aPos.y;
    /*proj * view * model **/ 
}