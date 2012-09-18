#import "Camera.h"
#import <OpenGL/gl.h>

@implementation Camera
@synthesize position=_position, orientation=_orientation, matrix=_matrix, fov=_fov, zoom=_zoom, aspectRatio=_aspectRatio;

+ (Vec4 *)viewportSize
{
	vec4_t viewport;
#ifdef GLM_USE_DOUBLE
	glGetDoublev(GL_VIEWPORT, GLM_FCAST(viewport));
#else
    glGetFloatv(GL_VIEWPORT, GLM_FCAST(viewport));
#endif
    return [Vec4 withVec:viewport];
}

- (id)init
{
	if(!(self = [super init]))
        return nil;
    
	self.position    = [Vec3 zero];
	self.orientation = [Quat withQuat:quat_createf(0, 1, 0, 0)];
	_zoom = 1;
	_fov  = degToRad(45.0);
	_aspectRatio = 1.65;
	
	[self updateMatrix];
	
	return self;
}

- (void)updateMatrix
{   
	// First we must translate & rotate the world into place
	vec3_t t = [_position negate].vec;
	mat4_t translation = mat4_create_translation(t.x, t.y, t.z);
	mat4_t rotation    = quat_to_ortho([[_orientation inverse] quat]);
    
    // Implement zooming just by translating in the view direction
    vec4_t p = (vec4_t){ 0, 0, -_zoom, 1 };
    p = quat_rotatePoint(_orientation.quat, p);
    translation = mat4_mul(translation, mat4_create_translation(p.x, p.y, p.z));

	// Then apply the projection
	GLMFloat near = 1;
	GLMFloat far = 1000;
	GLMFloat top = tanf(0.5 * _fov/_aspectRatio)*near;
	GLMFloat bottom = -top;
	GLMFloat left = _aspectRatio*bottom;
	GLMFloat right = _aspectRatio*top;

	mat4_t projection = mat4_frustum(left, right, bottom, top, near, far);
	self.matrix = [Mat4 withMat:mat4_mul(projection, mat4_mul(rotation, translation))];
}

- (Vec3 *)unProjectPoint:(Vec3 *)aPoint
{
	bool succ = NO;
    vec4_t p = vec4_create(aPoint.vec.x, aPoint.vec.y, aPoint.vec.z, 1);
	p = vec4_mul_mat4(p, mat4_inverse(_matrix.mat, &succ));
	assert(succ);
	p = vec4_scalarDiv(p, p.w);
    return [Vec3 withVec:(vec3_t){ p.x, p.y, p.z }];
}

@end
