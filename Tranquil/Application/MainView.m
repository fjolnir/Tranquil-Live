#import <OpenGL/gl.h>
#import <OpenGL/OpenGL.h>
#import <TranquilCore/TranquilCore.h>
#import "MainView.h"
#import "TAppDelegate.h"
#import "OpenGLLayer.h"

@interface MainView () {
	NSMutableArray *_renderables;
}
@end

@implementation MainView

- (CALayer *)makeBackingLayer
{
	OpenGLLayer *layer = [OpenGLLayer layer];
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

	vec4_t pos = [Scene globalScene].camera.position.vec;
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
	GlobalScene().camera.position.vec = pos; 
	[GlobalScene().camera updateMatrix];
}
@end
