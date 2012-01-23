#import "TMainView.h"
#import <OpenGL/gl.h>
#import <OpenGL/OpenGL.h>
#import "TScene.h"
#import "TAppDelegate.h"
#import "TOpenGLLayer.h"
#import "TCamera.h"

static vec3_t vec3_orthonormalize(vec3_t normal, vec3_t tangent)
{
	normal = vec3_normalize(normal);
	tangent = vec3_normalize(tangent);
	vec3_t proj = vec3_scalarMul(normal, vec3_dot(normal, tangent));
	tangent = vec3_sub(tangent, proj);
	
	return vec3_normalize(tangent);
}
static quat_t quat_lookRotation(vec3_t forward, vec3_t up)
{
	up = vec3_orthonormalize(forward, up);
	vec3_t right = vec3_cross(up, forward);
	quat_t ret;
	ret.w = sqrtf(1.0f + right.x + up.y + forward.z) * 0.5f;
	float w4_recip = 1.0f / (4.0f*ret.w);
	ret.x = (up.z - forward.y) * w4_recip;
	ret.y = (forward.x - right.z) * w4_recip;
	ret.z = (right.y - up.x) * w4_recip;
	
	return ret;
}
@interface TMainView () {
	NSMutableArray *_renderables;
}
@end

@implementation TMainView

- (CALayer *)makeBackingLayer
{
	TOpenGLLayer *layer = [TOpenGLLayer layer];
	layer.asynchronous = YES;
	return layer;
}

- (void)awakeFromNib
{
	NSMethodSignature *signature = [self methodSignatureForSelector:@selector(setNeedsDisplay:)];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	invocation.selector = @selector(setNeedsDisplay:);
	invocation.target = self;
	BOOL arg = YES;
	[invocation setArgument:&arg atIndex:2];
}

- (void)dealloc
{
	[_renderables release];
	
	[super dealloc];
}

- (BOOL)canBecomeKeyView
{
	return NO;
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void)keyDown:(NSEvent *)aEvent
{
	NSString *characters;
    characters = [aEvent characters];
	
    unichar character;
    character = [characters characterAtIndex: 0];
	
	vec4_t pos = [TScene globalScene].camera.position;
    if(character == NSRightArrowFunctionKey)
		pos.x += 0.1;
    else if (character == NSLeftArrowFunctionKey)
		pos.x -= 0.1;
	else if (character == NSUpArrowFunctionKey)
		pos.y += 0.1;
    else if (character == NSDownArrowFunctionKey)
		pos.y -= 0.1;
    else if (character == NSPageUpFunctionKey)
		pos.z += 0.1;
	else if (character == NSPageDownFunctionKey)
		pos.z -= 0.1;
	TGlobalScene().camera.position = pos; 
	[TGlobalScene().camera updateMatrix];
}


- (vec4_t)mapToSphere:(vec4_t)aViewportCoord // http://www.tommyhinks.com/docs/shoemake92_arcball.pdf
{
	vec3_t p = aViewportCoord.xyz;
	float mag = p.x*p.x + p.y*p.y;
	if(mag > 1.0) {
		float scale = 1.0 / sqrtf(mag);
		p.x *= scale;
		p.y *= scale;
		p.z = 0.0;
	} else
		p.z = -sqrtf(1.0f - mag);
	vec4_t out = { .xyz = p, .andW = 1.0f };
	return out;
}

static vec4_t lastMouseLoc;
- (void)mouseDown:(NSEvent *)aEvent
{
	NSSize s = self.bounds.size;
	vec4_t mouseLoc = { 2.0*aEvent.locationInWindow.x/s.width - 1.0, 2.0*aEvent.locationInWindow.y/s.height - 1.0, 0, 1 };
	lastMouseLoc = [self mapToSphere:mouseLoc];
}

- (void)mouseDragged:(NSEvent *)aEvent
{
	TCamera *cam = [TScene globalScene].camera;
	// Transform the mouse location into world space
	NSSize s = self.bounds.size;
	vec4_t mouseLoc = { 2.0*aEvent.locationInWindow.x/s.width - 1.0, 2.0*aEvent.locationInWindow.y/s.height - 1.0, 0, 1 };
	mouseLoc = [self mapToSphere:mouseLoc];
	
	quat_t rotation;
	rotation.vec = vec3_cross(lastMouseLoc.xyz, mouseLoc.xyz);
	rotation.scalar = vec3_dot(lastMouseLoc.xyz, mouseLoc.xyz);
	rotation = quat_normalize(rotation);
	
	cam.orientation = quat_multQuat(rotation, cam.orientation);
	cam.position = quat_rotatePoint(rotation, cam.position);

	[cam updateMatrix];
	lastMouseLoc = mouseLoc;
}

@end
