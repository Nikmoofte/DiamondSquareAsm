// #version 330

// out vec4 FragColor;

// in float height;

// const float coef = 0.10f;
// const float minColor = 0.1f;           

// void main()
// {
//     float colorIntensity = height * coef;
//     FragColor = vec4(1.0f * colorIntensity + minColor, 0.5f * colorIntensity + minColor, 0.2f * colorIntensity + minColor, 0.0f);
// }

#version 330

out vec4 FragColor;

in float height;

uniform float fMaxHeight;
uniform float waterLevel;
uniform float mountainsHeight;

void main()
{ 
    float coef = 30;
    if (height > mountainsHeight * 0.8)
    {
        float minColor = 0.4f;
        float col = (height - mountainsHeight) / coef;
        FragColor = vec4(col + minColor, col + minColor, col + minColor, 1.0f);
    }
    else if(height > waterLevel)
    {
        float grassCol = (height - waterLevel)/coef;
        float minColor = 0.2f; 
        FragColor = vec4(0.58 * grassCol + minColor, 0.7 * grassCol + minColor, 0.41 * grassCol + minColor, 1.0f);
    }
    else
    {
        float underWaterCol = (height - waterLevel)/coef * 0.8;
        FragColor = vec4(0, 0, -underWaterCol + 0.1, 1.0f);
    }
}
