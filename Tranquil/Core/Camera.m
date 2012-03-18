#import "Camera.h"
#import <OpenGL/gl.h>

@implementation Camera
@synthesize position=_position, orientation=_orientation, matrix=_matrix, fov=_fov, zoom=_zoom, aspectRatio=_aspectRatio;
+ (vec4_t)viewportSize
{
	vec4_t viewport;
	glGetFloatv(GL_VIEWPORT, viewport.f);
    return viewport;
}

- (id)init
{
	self = [super init];
	if(!self) return nil;
	_position = vec4_create(0, 0, 0, 1);
	_orientation = quat_createf(0, 1, 0, 0);
	_zoom = 1;
	_fov = degToRad(45.0);
	_aspectRatio = 1.65;
	
	[self updateMatrix];
	
	return self;
}

- (void)updateMatrix
{   
	// First we must translate & rotate the world into place
	vec4_t t = vec4_negate(_position);
	mat4_t translation = mat4_create_translation(t.x, t.y, t.z);
	mat4_t rotation = quat_to_ortho(quat_inverse(_orientation));
    
    // Implement zooming just by translating in the view direction
    vec4_t p = (vec4_t){ 0,0,-_zoom,1 };
    p = quat_rotatePoint(_orientation, p);
   // translation = mat4_mul(translation, mat4_create_translation(p.x, p.y, p.z));
    
	// Then apply the projection
	GLMFloat near = 1;
	GLMFloat far = 1000;
	GLMFloat top = tanf(0.5*_fov/_aspectRatio)*near;
	GLMFloat bottom = -top;
	GLMFloat left = _aspectRatio*bottom;
	GLMFloat right = _aspectRatio*top;
//    GLMFloat left = -1.0;
//	GLMFloat right = -left;
//    GLMFloat top = 1.0f/_aspectRatio;
//	GLMFloat bottom = -top;
	
//	mat4_t projection = mat4_frustum(left*_zoom, right*_zoom, bottom*_zoom, top*_zoom, near, far);
	mat4_t projection = mat4_frustum(left, right, bottom, top, near, far);
	_matrix = mat4_mul(projection, mat4_mul(rotation,translation));
}

- (vec4_t)unProjectPoint:(vec4_t)aPoint
{
	bool succ = NO;
	vec4_t p = vec4_mul_mat4(aPoint, mat4_inverse(_matrix, &succ));
	assert(succ);
	p = vec4_scalarDiv(p, p.w);
    return p;
}

@end
