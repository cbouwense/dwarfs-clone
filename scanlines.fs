#version 330

in vec2 fragTexCoord;
in vec4 fragColor;

uniform sampler2D texture0;
uniform vec4 colDiffuse;

out vec4 finalColor;

void main()
{
    vec4 color = texture(texture0, fragTexCoord) * colDiffuse * fragColor;

    // Horizontal scanlines, repeating every 3 screen pixels
    float y = gl_FragCoord.y;
    // float scanline = 0.97 + 0.00 * (0.5 + 0.5 * sin(y * 2.094395));
    float brightness = 0.75;

    color.rgb *= brightness;

    finalColor = color;
}