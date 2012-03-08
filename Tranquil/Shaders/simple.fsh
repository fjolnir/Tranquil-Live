uniform float u_textureMask;
uniform sampler2D u_texture;
varying vec4 v_color;
varying vec2 v_texCoord;

void main()
{
	vec4 color = v_color;
	vec4 texColor = mix(vec4(1,1,1,1), texture2D(u_texture, v_texCoord), u_textureMask);
    color *= texColor;

	gl_FragColor = color;
}
