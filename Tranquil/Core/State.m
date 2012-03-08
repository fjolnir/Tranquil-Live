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
	_color = [Vector4 vectorWithX:1 y:1 z:1 w:1];
	_transform = [Matrix4 identity];
	_shader = nil;
    _texture = nil;

	return self;
}

- (void)applyToScene:(Scene *)aScene
{
	[aScene.projMatStack push];
	[aScene.worldMatStack push];
	[aScene.worldMatStack mul:_transform];

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
		[shader withUniform:@"u_projMatrix" do:^(GLuint loc) {
			glUniformMatrix4fv(loc, 1, GL_FALSE, aScene.projMatStack.top.mat.f);
		}];
		[shader withUniform:@"u_worldMatrix" do:^(GLuint loc) {
			glUniformMatrix4fv(loc, 1, GL_FALSE, aScene.worldMatStack.top.mat.f);
		}];
		[shader withUniform:@"u_cameraPosition" do:^(GLuint loc) {
			glUniform4fv(loc, 1, aScene.camera.position.vec.f);
		}];
		[shader withUniform:@"u_globalAmbientColor" do:^(GLuint loc) {
			glUniform4fv(loc, 1, _unlit ? vec4_create(1, 1, 1, 1).f : aScene.ambientLight.vec.f);
		}];
		[shader withUniform:@"u_lightPositions" do:^(GLuint loc) {
			vec4_t positions[[aScene.lights count]];
			for(int i = 0; i < [aScene.lights count]; ++i) positions[i] = [(Light*)[aScene.lights objectAtIndex:i] position].vec;
			glUniform4fv(loc, (int)[aScene.lights count], (float*)positions);
		}];
		[shader withUniform:@"u_ambientColors" do:^(GLuint loc) {
			vec4_t colors[[aScene.lights count]];
			for(int i = 0; i < [aScene.lights count]; ++i) colors[i] = [(Light*)[aScene.lights objectAtIndex:i] ambientColor].vec;
			glUniform4fv(loc, (int)[aScene.lights count], (float*)colors);
		}];
		[shader withUniform:@"u_diffuseColors" do:^(GLuint loc) {
			vec4_t colors[[aScene.lights count]];
			for(int i = 0; i < [aScene.lights count]; ++i) colors[i] = [(Light*)[aScene.lights objectAtIndex:i] diffuseColor].vec;
			glUniform4fv(loc, (int)[aScene.lights count], (float*)colors);
		}];
		[shader withUniform:@"u_specularColors" do:^(GLuint loc) {
			vec4_t colors[[aScene.lights count]];
			for(int i = 0; i < [aScene.lights count]; ++i) colors[i] = [(Light*)[aScene.lights objectAtIndex:i] specularColor].vec;
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
	if(_shader) [_shader makeInactive];
	[aScene.worldMatStack pop];
	[aScene.projMatStack pop];
}

#pragma mark -
- (id)copyWithZone:(NSZone *)aZone
{
	NSZone *zone = aZone ? aZone : NSDefaultMallocZone();
	State *copy = [[[self class] allocWithZone:zone] init];
	copy.transform = [_transform copy];
	copy.shininess = _shininess;
	copy.opacity = _opacity;
	copy.lineWidth = _lineWidth;
	copy.shininess = _shininess;
	copy.pointRadius = _pointRadius;
	copy.shader = _shader;
	copy.color = [_color copy];
    copy.drawWireframe = _drawWireframe;
    copy.drawNormals = _drawNormals;
    copy.drawPoints = _drawPoints;
    copy.antiAlias = _antiAlias;
    copy.drawOrigin = _drawOrigin;
    copy.ignoreDepth = _ignoreDepth;
    copy.noZWrite = _noZWrite;
    copy.cullBackFace = _cullBackFace;
    copy.unlit = _unlit;
    copy.texture = _texture;

    return copy;
}

@end
