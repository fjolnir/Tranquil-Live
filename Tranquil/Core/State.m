#import "State.h"
#import "Scene.h"
#import "Shader.h"
#import "Light.h"
#import <OpenGL/gl.h>
#import "GLErrorChecking.h"

@interface State () {
}
@end

@implementation State
@synthesize transform=_transform, ambientLight=_ambientLight, color=_color, shininess=_shininess, opacity=_opacity, lineWidth=_lineWidth, pointRadius=_pointRadius, shader=_shader, renderHint=_renderHint;

- (id)init
{
	self = [super init];
	if(!self) return nil;
	
	_pointRadius = 1;
	_lineWidth = 1;
	_shininess = 0;
	_opacity = 1;
	_color = [Vector4 vectorWithX:1 y:1 z:1 w:1];
	_renderHint = kTRenderHintNone;
	_transform = [Matrix4 identity];
	_shader = nil;
		
	return self;
}

- (void)applyToScene:(Scene *)aScene
{
	[aScene.projMatStack push];
	[aScene.worldMatStack push];
	[aScene.worldMatStack mul:_transform];
	
	glLineWidth(_lineWidth);
	glPointSize(_pointRadius);
	
	//	glPolygonMode(GL_FRONT_AND_BACK,GL_LINE);

	if(_renderHint & kTRenderHintNoZWrite)
		glDepthMask(false);
	if(_renderHint & kTRenderHintCullBack)
		glEnable(GL_CULL_FACE);
	else
		glDisable(GL_CULL_FACE);
	TCheckGLError();
	
	Shader *shader = _shader;
	if(shader) {
		[_shader makeActive];
		[shader withUniform:@"u_projMatrix" do:^(GLint loc) {
			glUniformMatrix4fv(loc, 1, GL_FALSE, aScene.projMatStack.top.mat.f);
		}];
		[shader withUniform:@"u_worldMatrix" do:^(GLint loc) {
			glUniformMatrix4fv(loc, 1, GL_FALSE, aScene.worldMatStack.top.mat.f);
		}];
		[shader withUniform:@"u_cameraPosition" do:^(GLint loc) {
			glUniform4fv(loc, 1, aScene.camera.position.vec.f);
		}];
		[shader withUniform:@"u_globalAmbientColor" do:^(GLint loc) {
			glUniform4fv(loc, 1, aScene.ambientLight.vec.f);
		}];
		[shader withUniform:@"u_lightPositions" do:^(GLint loc) {
			vec4_t positions[[aScene.lights count]];
			for(int i = 0; i < [aScene.lights count]; ++i) positions[i] = [(Light*)[aScene.lights objectAtIndex:i] position].vec;
			glUniform4fv(loc, (int)[aScene.lights count], (float*)positions);
		}];
		[shader withUniform:@"u_ambientColors" do:^(GLint loc) {
			vec4_t colors[[aScene.lights count]];
			for(int i = 0; i < [aScene.lights count]; ++i) colors[i] = [(Light*)[aScene.lights objectAtIndex:i] ambientColor].vec;
			glUniform4fv(loc, (int)[aScene.lights count], (float*)colors);
		}];
		[shader withUniform:@"u_diffuseColors" do:^(GLint loc) {
			vec4_t colors[[aScene.lights count]];
			for(int i = 0; i < [aScene.lights count]; ++i) colors[i] = [(Light*)[aScene.lights objectAtIndex:i] diffuseColor].vec;
			glUniform4fv(loc, (int)[aScene.lights count], (float*)colors);
		}];
		[shader withUniform:@"u_specularColors" do:^(GLint loc) {
			vec4_t colors[[aScene.lights count]];
			for(int i = 0; i < [aScene.lights count]; ++i) colors[i] = [(Light*)[aScene.lights objectAtIndex:i] specularColor].vec;
			glUniform4fv(loc, (int)[aScene.lights count], (float*)colors);
		}];
		[shader withUniform:@"u_lightCount" do:^(GLint loc) {
			glUniform1i(loc, (int)[aScene.lights count]);
		}];
	}
	TCheckGLError();
}
- (void)unapplyToScene:(Scene *)aScene
{	
	glLineWidth(_lineWidth);
	glPointSize(_pointRadius);
	
	if(_renderHint & kTRenderHintNoZWrite)
		glDepthMask(true);
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
	copy.renderHint = _renderHint;
	copy.color = [_color copy];
	return copy;
}
@end
