vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{
    vec4 vertex = Texel(tex, texture_coords);

    return vertex;
}