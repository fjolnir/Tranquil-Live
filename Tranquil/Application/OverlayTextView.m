#import <TranquilCore/TranquilCore.h>
#include "OverlayTextView.h"
#import <OpenGL/gl.h>
#import <OpenGL/OpenGL.h>
#import <MacRuby/MacRuby.h>
#import "TAppDelegate.h"

@interface OverlayTextView () {
	NSRect _insertionPointRect;
    id _rubyMouseObserver;
}
@end

@implementation OverlayTextView

- (void)_init
{
	self.drawsBackground = NO;
	self.textColor = [NSColor whiteColor];
	self.font = [NSFont fontWithName:@"Monaco" size:16];
	self.insertionPointColor = [NSColor whiteColor];
    self.alphaValue = 0.6;
	NSShadow *shadow = [[NSShadow alloc] init];
	shadow.shadowBlurRadius = 1;
	shadow.shadowOffset = NSMakeSize(0, -1);
	shadow.shadowColor = [NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:1];
	self.shadow = shadow;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishedLaunching:)
                                                 name:kTranquilFinishedLaunching
                                               object:nil];
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

- (void)finishedLaunching:(NSNotification *)aNotification
{
    _rubyMouseObserver = [[MacRuby sharedRuntime] evaluateString:@"TranquilMouseObserver.new"];
}

- (void)viewWillMoveToSuperview:(NSView *)aSuperview
{
	((NSScrollView *)aSuperview).drawsBackground = NO;
}

#pragma mark - Events

- (void)scrollWheel:(NSEvent *)aEvent
{
    [_rubyMouseObserver performRubySelector:@selector(scroll:) 
                              withArguments:[NSNumber numberWithDouble:aEvent.scrollingDeltaX],
                                            [NSNumber numberWithDouble:aEvent.scrollingDeltaY], nil];
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
	[_rubyMouseObserver performRubySelector:@selector(leftClick:)
                              withArguments:[NSNumber numberWithDouble:aEvent.locationInWindow.x],
                                            [NSNumber numberWithDouble:aEvent.locationInWindow.y], nil];
}

- (void)mouseDragged:(NSEvent *)aEvent
{
	[_rubyMouseObserver performRubySelector:@selector(leftDrag:)
                              withArguments:[NSNumber numberWithDouble:aEvent.locationInWindow.x],
                                            [NSNumber numberWithDouble:aEvent.locationInWindow.y], nil];
}

@end
