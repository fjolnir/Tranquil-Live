#import "TMainView.h"
#import <OpenGL/gl.h>
#import <OpenGL/OpenGL.h>
#import "TScene.h"
#import "TAppDelegate.h"
#import "TOpenGLLayer.h"
#import "TCamera.h"

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


- (vec4_t)mapToSphere:(vec2_t)aWindowCoord // http://www.tommyhinks.com/docs/shoemake92_arcball.pdf
{
	// normalize window coordinates
	vec4_t viewport;
	glGetFloatv(GL_VIEWPORT, viewport.f);
	vec3_t p = { 2.0*aWindowCoord.x/viewport.z - 1.0, 2.0*aWindowCoord.y/viewport.w - 1.0, 0 };
	
	// Map to sphere
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
	lastMouseLoc = [self mapToSphere:vec2_create(aEvent.locationInWindow.x, aEvent.locationInWindow.y)];
}

- (void)mouseDragged:(NSEvent *)aEvent
{
	vec4_t mouseLoc = [self mapToSphere:vec2_create(aEvent.locationInWindow.x, aEvent.locationInWindow.y)];
	
	TCamera *cam = [TScene globalScene].camera;

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
