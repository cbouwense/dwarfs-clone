#version 330

in vec2 fragTexCoord;
in vec4 fragColor;

uniform sampler2D texture0;
uniform vec2 resolution;

out vec4 finalColor;

void main()
{
    vec4 color = texture(texture0, fragTexCoord) * fragColor;

    // Count rows in the render texture, not the window.
    float row = floor(fragTexCoord.y * resolution.y);
    float isLine = 1.0 - step(0.5, mod(row, 4.0));

    float strength = 0.07; // 0 = off; try 0.04–0.10
    color.rgb *= 1.0 - strength * isLine;

    finalColor = color;
}
