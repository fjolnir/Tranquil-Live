// A simple multi-light per-vertex Phong shader/

#define MAX_LIGHTS 8
uniform mat4 u_worldMatrix;
uniform mat4 u_projMatrix;
uniform vec4 u_cameraPosition;
uniform vec4 u_globalAmbientColor;
// Lights
uniform int u_lightCount;
uniform vec4 u_lightPositions[MAX_LIGHTS];
uniform vec4 u_ambientColors[MAX_LIGHTS];
uniform vec4 u_diffuseColors[MAX_LIGHTS];
uniform vec4 u_specularColors[MAX_LIGHTS];

attribute vec4 a_position;
attribute vec4 a_normal;
attribute vec4 a_texCoord;
attribute vec4 a_color;
attribute float a_shininess;

varying vec4 v_color;

void main()
{
	vec4 worldPos = u_worldMatrix * a_position;
	vec4 projectedPos = u_projMatrix * worldPos;
	
	vec4 normal = u_worldMatrix * a_normal;
	vec4 vertColor = u_globalAmbientColor * a_color;
	int i;
	for(i = 0; i < u_lightCount; ++i) {
		vec3 lightDir = u_lightPositions[i].xyz - worldPos.xyz;
		float lightDistSq = length(lightDir);
		lightDistSq = lightDistSq*lightDistSq; // For attenuation
		lightDir = normalize(lightDir);

		// Diffuse component
		float lambert = max(dot(normal.xyz, lightDir), 0.0);
		vec4 diffuse = lambert * u_diffuseColors[i];

		// Specular component
		vec3 eyeDir = normalize(worldPos.xyz - u_cameraPosition.xyz);
		vec3 reflected = reflect(lightDir, normal.xyz);
		float specular = pow( max(dot(reflected, eyeDir), 0.0), a_shininess);

		vertColor += (u_ambientColors[i]+diffuse)*a_color + specular*u_specularColors[i];
	}
	v_color = vertColor;

	gl_Position = projectedPos;
}
