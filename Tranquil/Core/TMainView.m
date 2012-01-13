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
    if (character == NSRightArrowFunctionKey) {
		pos.x += 0.1;
		
    } else if (character == NSLeftArrowFunctionKey) {
		pos.x -= 0.1;
    } else if (character == NSUpArrowFunctionKey) {
		pos.y += 0.1;
    } else if (character == NSDownArrowFunctionKey) {
		pos.y -= 0.1;
    } else if (character == NSPageUpFunctionKey) {
		pos.z += 0.1;
	} else if (character == NSPageDownFunctionKey) {
		pos.z -= 0.1;
	}
	[TScene globalScene].camera.position = pos; 
	[[TScene globalScene].camera updateMatrix];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	quat_t xQuat = quat_createf(1, 0, 0, -[theEvent deltaY]/70.0);
	quat_t yQuat = quat_createf(0, 1, 0, -[theEvent deltaX]/70.0);
	quat_t deltaQuat = quat_multQuat(xQuat, yQuat);
	[TScene globalScene].camera.orientation = quat_multQuat(deltaQuat, [TScene globalScene].camera.orientation);
	[[TScene globalScene].camera updateMatrix];
}

@end
