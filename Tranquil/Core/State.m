#import "State.h"
#import "Scene.h"
#import "Shader.h"
#import "Light.h"
#import "Texture.h"
#import <OpenGL/gl.h>
#import <TranquilCore/TranquilCore.h>
#import "GLErrorChecking.h"

@interface State () {
}
@end

@implementation State
@synthesize transform=_transform, ambientLight=_ambientLight, color=_color, shininess=_shininess, opacity=_opacity, lineWidth=_lineWidth, pointRadius=_pointRadius, shader=_shader;
@synthesize drawWireframe=_drawWireframe, drawNormals=_drawNormals, drawPoints=_drawPoints, antiAlias=_antiAlias, drawOrigin=_drawOrigin, ignoreDepth=_ignoreDepth, noZWrite=_noZWrite, cullBackFace=_cullBackFace;
@synthesize unlit=_unlit, texture=_texture;


- (id)init
{
	self = [super init];
	if(!self) return nil;

	_pointRadius = 1;
	_lineWidth = 1;
	_shininess = 0;
	_opacity = 1;
	_color = vec4_create(1, 1, 1, 1);
    _transform = GLMMat4_identity;
	_shader = nil;
    _texture = nil;

	return self;
}

- (void)applyToScene:(Scene *)aScene
{
    matrix_stack_push(aScene.projMatStack);
    matrix_stack_push(aScene.worldMatStack);
    matrix_stack_mul_mat4(aScene.worldMatStack, _transform);

	glLineWidth(_lineWidth);
	glPointSize(_pointRadius);

	if(_noZWrite)
		glDepthMask(false);
    else
        glDepthMask(true);
	if(_cullBackFace)
		glEnable(GL_CULL_FACE);
	else
		glDisable(GL_CULL_FACE);
	if(_drawWireframe) {
		glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
        if(_antiAlias) glEnable(GL_LINE_SMOOTH);
        else glDisable(GL_LINE_SMOOTH);
    } else if(_drawPoints) {
		glPolygonMode(GL_FRONT_AND_BACK, GL_POINT);
    } else {
        glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
        if(_antiAlias) glEnable(GL_POLYGON_SMOOTH);
        else glDisable(GL_POLYGON_SMOOTH);
    }
    if(_ignoreDepth)
        glDisable(GL_DEPTH_TEST);
    else
        glEnable(GL_DEPTH_TEST);

	TCheckGLError();

	Shader *shader = _shader;
	if(shader) {
		[_shader makeActive];
        if(_texture) {
            [shader withUniform:@"u_texture" do:^(GLuint loc) {
                glActiveTexture(GL_TEXTURE0);
                glBindTexture(GL_TEXTURE_2D, _texture.texId);
                glUniform1i(loc, 0);
            }];
        }

        [shader withUniform:@"u_textureMask" do:^(GLuint loc) {
            glUniform1f(loc, (_texture ? 1.0f : 0.0f));
        }];
		[shader withUniform:@"u_projMatrix" do:^(GLuint loc) {
            mat4_t projMat = matrix_stack_get_mat4(aScene.projMatStack);
			glUniformMatrix4fv(loc, 1, GL_FALSE, GLM_FCAST(projMat));
		}];
		[shader withUniform:@"u_worldMatrix" do:^(GLuint loc) {
            mat4_t worldMat = matrix_stack_get_mat4(aScene.worldMatStack);
			glUniformMatrix4fv(loc, 1, GL_FALSE, GLM_FCAST(worldMat));
		}];
		[shader withUniform:@"u_cameraPosition" do:^(GLuint loc) {
            vec4_t camPos = aScene.camera.position;
			glUniform4fv(loc, 1, GLM_FCAST(camPos));
		}];
		[shader withUniform:@"u_globalAmbientColor" do:^(GLuint loc) {
            vec4_t ambient = aScene.ambientLight;
            GLMFloat white[] = {1,1,1,1};
			glUniform4fv(loc, 1, _unlit ? white : GLM_FCAST(ambient));
		}];
		[shader withUniform:@"u_lightPositions" do:^(GLuint loc) {
			vec4_t positions[[aScene.lights count]];
			for(int i = 0; i < [aScene.lights count]; ++i)
                positions[i] = [(Light*)[aScene.lights objectAtIndex:i] position];
			glUniform4fv(loc, (int)[aScene.lights count], (float*)positions);
		}];
		[shader withUniform:@"u_ambientColors" do:^(GLuint loc) {
			vec4_t colors[[aScene.lights count]];
			for(int i = 0; i < [aScene.lights count]; ++i)
                colors[i] = [(Light*)[aScene.lights objectAtIndex:i] ambientColor];
			glUniform4fv(loc, (int)[aScene.lights count], (float*)colors);
		}];
		[shader withUniform:@"u_diffuseColors" do:^(GLuint loc) {
			vec4_t colors[[aScene.lights count]];
			for(int i = 0; i < [aScene.lights count]; ++i)
                colors[i] = [(Light*)[aScene.lights objectAtIndex:i] diffuseColor];
			glUniform4fv(loc, (int)[aScene.lights count], (float*)colors);
		}];
		[shader withUniform:@"u_specularColors" do:^(GLuint loc) {
			vec4_t colors[[aScene.lights count]];
			for(int i = 0; i < [aScene.lights count]; ++i)
                colors[i] = [(Light*)[aScene.lights objectAtIndex:i] specularColor];
			glUniform4fv(loc, (int)[aScene.lights count], (float*)colors);
		}];
		[shader withUniform:@"u_lightCount" do:^(GLuint loc) {
			glUniform1i(loc, (int)(_unlit ? 0 : [aScene.lights count]));
		}];
	}
	TCheckGLError();
}
- (void)unapplyToScene:(Scene *)aScene
{
    if(_texture) {
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, 0);
    }
	if(_shader) [_shader makeInactive];
    matrix_stack_pop(aScene.worldMatStack);
    matrix_stack_pop(aScene.projMatStack);
}

#pragma mark -
- (id)copyWithZone:(NSZone *)aZone
{
	NSZone *zone = aZone ? aZone : NSDefaultMallocZone();
	State *copy = [[[self class] allocWithZone:zone] init];
	copy.transform = _transform;
	copy.shininess = _shininess;
	copy.opacity = _opacity;
	copy.lineWidth = _lineWidth;
	copy.shininess = _shininess;
	copy.pointRadius = _pointRadius;
	copy.shader = [_shader retain];
	copy.color = _color;
    copy.drawWireframe = _drawWireframe;
    copy.drawNormals = _drawNormals;
    copy.drawPoints = _drawPoints;
    copy.antiAlias = _antiAlias;
    copy.drawOrigin = _drawOrigin;
    copy.ignoreDepth = _ignoreDepth;
    copy.noZWrite = _noZWrite;
    copy.cullBackFace = _cullBackFace;
    copy.unlit = _unlit;
    copy.texture = [_texture retain];

    return copy;
}

@end
