#import "Camera.h"
#import <OpenGL/gl.h>

@implementation Camera
@synthesize position=_position, orientation=_orientation, matrix=_matrix, fov=_fov, zoom=_zoom, aspectRatio=_aspectRatio;
+ (Vector4 *)viewportSize
{
	vec4_t viewport;
	glGetFloatv(GL_VIEWPORT, viewport.f);
	return [Vector4 vectorWithVec:viewport];
}

- (id)init
{
	self = [super init];
	
	if(!self) return nil;
	_position = [Vector4 vectorWithX:0 y:0 z:5 w:1];
	_orientation = [Quaternion quaternionWithAngle:0 x:0 y:1 z:0];
	_zoom = 1;
	_fov = degToRad(45.0);
	_aspectRatio = 1.65;
	
	[self updateMatrix];
	
	return self;
}

- (void)updateMatrix
{
	// First we must translate & rotate the world into place
	vec4_t t = [_position negate].vec;
	mat4_t translation = mat4_create_translation(t.x, t.y, t.z);
	mat4_t rotation = quat_to_ortho(quat_inverse(_orientation.quat));
	// Then apply the projection
	float near = 1;
	float far = 10000;
	float top = tanf(0.5*_fov/_aspectRatio)*near;
	float bottom = -top;
	float left = _aspectRatio*bottom;
	float right = _aspectRatio*top;
	mat4_t projection = mat4_frustum(left*_zoom, right*_zoom, bottom*_zoom, top*_zoom, near, far);
	_matrix = [Matrix4 matrixWithMat:mat4_mul(projection, mat4_mul(rotation,translation))];
}

- (Vector4 *)unProjectPoint:(Vector4 *)aPoint
{
	bool succ = NO;
	vec4_t p = vec4_mul_mat4(aPoint.vec, mat4_inverse(_matrix.mat, &succ));
	assert(succ);
	p = vec4_scalarDiv(p, p.w);
	return [Vector4 vectorWithVec:p];
}

@end
