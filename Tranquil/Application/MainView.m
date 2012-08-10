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

- (void)drawRect:(NSRect)dirtyRect
{
    
}
- (BOOL)canBecomeKeyView
{
	return NO;
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

//- (void)keyDown:(NSEvent *)aEvent
//{
//	NSString *characters;
//	characters = [aEvent characters];
//
//	unichar character;
//	character = [characters characterAtIndex:0];
//}
@end
