#import "TCamera.h"

@implementation TCamera
@synthesize position=_position, orientation=_orientation, matrix=_matrix, fov=_fov, zoom=_zoom, aspectRatio=_aspectRatio;
- (id)init
{
	self = [super init];
	
	if(!self) return nil;
	_position = vec4_create(0, 0, 5, 0);
	_orientation = quat_createv(vec3_create(0, 1, 0), radToDeg(0));
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
	// Then apply the projection
	float near = 1;
	float far = 10000;
	float top = tanf(0.5*_fov/_aspectRatio)*near;
	float bottom = -top;
	float left = _aspectRatio*bottom;
	float right = _aspectRatio*top;
	mat4_t projection = mat4_frustum(left*_zoom, right*_zoom, bottom*_zoom, top*_zoom, near, far);
	_matrix = mat4_mul(projection, mat4_mul(rotation,translation));
	//_matrix = mat4_transpose(mat4_mul(mat4_mul(translation, rotation), projection));
	//_matrix = mat4_mul(translation, rotation);
	//_matrix = mat4_mul(mat4_create_scale(0.5*1/aspect, 0.5, 0.5), mat4_mul(translation, mat4_create_rotation(45, 0, 1, 0)));
}
@end
