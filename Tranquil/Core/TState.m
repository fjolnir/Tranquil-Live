#import "TState.h"
#import "TScene.h"
#import "TShader.h"
#import "TLight.h"
#import <OpenGL/gl.h>
#import "TGLErrorChecking.h"

@interface TState () {
}
@end

@implementation TState
@synthesize transform=_transform, ambientLight=_ambientLight, shininess=_shininess, opacity=_opacity, lineWidth=_lineWidth, pointRadius=_pointRadius, shader=_shader, renderHint=_renderHint;

- (id)init
{
	self = [super init];
	if(!self) return nil;
	
	_pointRadius = 1;
	_lineWidth = 1;
	_shininess = 0;
	_opacity = 1;
	_renderHint = 0;
	_transform = kMat4_identity;
		
	return self;
}
- (void)dealloc
{
	[_shader release];
	[super dealloc];
}

- (void)applyToScene:(TScene *)aScene
{
	matrix_stack_push(aScene.worldMatStack);
	matrix_stack_mul_mat4(aScene.worldMatStack, _transform);
	
	glLineWidth(_lineWidth);
	glPointSize(_pointRadius);
	
	//glPolygonMode(GL_FRONT_AND_BACK,GL_LINE);

	if(_renderHint & kTRenderHintNoZWrite)
		glDepthMask(false);
	if(_renderHint & kTRenderHintCullBack)
		glEnable(GL_CULL_FACE);
	else
		glDisable(GL_CULL_FACE);
	TCheckGLError();
	
	if(_shader) [_shader makeActive];
	TShader *shader = [TShader activeShader];
	if(shader) {
		[shader withUniform:@"u_projMatrix" do:^(GLint loc) {
			glUniformMatrix4fv(loc, 1, GL_FALSE, matrix_stack_get_mat4(aScene.projMatStack).f);
		}];
		[shader withUniform:@"u_worldMatrix" do:^(GLint loc) {
			glUniformMatrix4fv(loc, 1, GL_FALSE, matrix_stack_get_mat4(aScene.worldMatStack).f);
		}];
		[shader withUniform:@"u_cameraPosition" do:^(GLint loc) {
			glUniform4fv(loc, 1, aScene.camera.position.f);
		}];
		[shader withUniform:@"u_globalAmbientColor" do:^(GLint loc) {
			glUniform4fv(loc, 1, aScene.ambientLight.f);
		}];
		[shader withUniform:@"u_lightPositions" do:^(GLint loc) {
			vec4_t positions[[aScene.lights count]];
			for(int i = 0; i < [aScene.lights count]; ++i) positions[i] = [(TLight*)[aScene.lights objectAtIndex:i] position];
			glUniform4fv(loc, (int)[aScene.lights count], (float*)positions);
		}];
		[shader withUniform:@"u_ambientColors" do:^(GLint loc) {
			vec4_t colors[[aScene.lights count]];
			for(int i = 0; i < [aScene.lights count]; ++i) colors[i] = [(TLight*)[aScene.lights objectAtIndex:i] ambientColor];
			glUniform4fv(loc, (int)[aScene.lights count], (float*)colors);
		}];
		[shader withUniform:@"u_diffuseColors" do:^(GLint loc) {
			vec4_t colors[[aScene.lights count]];
			for(int i = 0; i < [aScene.lights count]; ++i) colors[i] = [(TLight*)[aScene.lights objectAtIndex:i] diffuseColor];
			glUniform4fv(loc, (int)[aScene.lights count], (float*)colors);
		}];
		[shader withUniform:@"u_specularColors" do:^(GLint loc) {
			vec4_t colors[[aScene.lights count]];
			for(int i = 0; i < [aScene.lights count]; ++i) colors[i] = [(TLight*)[aScene.lights objectAtIndex:i] specularColor];
			glUniform4fv(loc, (int)[aScene.lights count], (float*)colors);
		}];
		[shader withUniform:@"u_lightCount" do:^(GLint loc) {
			glUniform1i(loc, (int)[aScene.lights count]);
		}];
	}
	TCheckGLError();
}
- (void)unapplyToScene:(TScene *)aScene
{	
	glLineWidth(_lineWidth);
	glPointSize(_pointRadius);
	
	if(_renderHint & kTRenderHintNoZWrite)
		glDepthMask(true);
	if(_shader) [_shader makeInactive];
	matrix_stack_pop(aScene.worldMatStack);
}



#pragma mark -
- (id)copyWithZone:(NSZone *)aZone
{
	NSZone *zone = aZone ? aZone : NSDefaultMallocZone();
	TState *copy = [[[self class] allocWithZone:zone] init];
	copy.transform = _transform;
	copy.shininess = _shininess;
	copy.opacity = _opacity;
	copy.lineWidth = _lineWidth;
	copy.shininess = _shininess;
	copy.pointRadius = _pointRadius;
	copy.shader = _shader;
	copy.renderHint = _renderHint;
	
	return copy;
}
@end
