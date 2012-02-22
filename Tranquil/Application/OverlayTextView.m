#import <TranquilCore/TranquilCore.h>
#include "OverlayTextView.h"
#import <OpenGL/gl.h>
#import <OpenGL/OpenGL.h>

@interface OverlayTextView () {
	NSRect _insertionPointRect;
}
@end

@implementation OverlayTextView

- (void)_init
{
	self.drawsBackground = NO;
	self.textColor = [NSColor whiteColor];
	self.font = [NSFont fontWithName:@"Monaco" size:16];
	self.insertionPointColor = [NSColor whiteColor];
	NSShadow *shadow = [[NSShadow alloc] init];
	shadow.shadowBlurRadius = 2.0;
	shadow.shadowOffset = NSMakeSize(0, -1);
	shadow.shadowColor = [NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:0.7];
	self.shadow = shadow;
}

- (id)initWithFrame:(NSRect)aFrame
{
    self = [super initWithFrame:aFrame];
	if(self) [self _init];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) [self _init];
    return self;
}

- (void)viewWillMoveToSuperview:(NSView *)aSuperview
{
	((NSScrollView *)aSuperview).drawsBackground = NO;
}

#pragma mark - Events

- (void)scrollWheel:(NSEvent *)aEvent
{
	Class obsClass = NSClassFromString(@"TranquilMouseObserver");
	[[obsClass instance] performRubySelector:@selector(scroll:) withArguments:[Vector2 vectorWithX:aEvent.scrollingDeltaX y:aEvent.scrollingDeltaY], NULL];
}

- (void)mouseEntered:(NSEvent *)aEvent
{
	//[NSCursor hide];
	return;
}

- (void)mouseExited:(NSEvent *)aEvent
{
	//[NSCursor unhide];
	return;
}

- (void)mouseMoved:(NSEvent *)aEvent
{
	return; // Prevent the pointer from changing
}

- (void)mouseDown:(NSEvent *)aEvent
{
	Class obsClass = NSClassFromString(@"TranquilMouseObserver");
	[[obsClass instance] performRubySelector:@selector(leftClick:) withArguments:[Vector2 vectorWithX:aEvent.locationInWindow.x y:aEvent.locationInWindow.y], NULL];
}

- (void)mouseDragged:(NSEvent *)aEvent
{
	Class obsClass = NSClassFromString(@"TranquilMouseObserver");
	[[obsClass instance] performRubySelector:@selector(leftDrag:) withArguments:[Vector2 vectorWithX:aEvent.locationInWindow.x y:aEvent.locationInWindow.y], NULL];
}

@end
