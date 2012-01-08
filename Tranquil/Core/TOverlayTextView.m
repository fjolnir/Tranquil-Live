#include "TOverlayTextView.h"

@interface TOverlayTextView () {
	NSRect _insertionPointRect;
}
@end

@implementation TOverlayTextView

- (void)_init
{
	self.drawsBackground = NO;
	self.textColor = [NSColor whiteColor];
	self.font = [NSFont fontWithName:@"Monaco" size:16];
	self.insertionPointColor = [NSColor whiteColor];
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
	// Do nothing, doesn't look good
}

- (void)mouseEntered:(NSEvent *)aEvent
{
	[NSCursor hide];
	return;
}

- (void)mouseExited:(NSEvent *)aEvent
{
	[NSCursor unhide];
	return;
}

- (void)mouseMoved:(NSEvent *)aEvent
{
	return; // Prevent the pointer from changing
}
- (NSView *)hitTest:(NSPoint)aPoint
{
	return nil; // We want the OpenGL view to get the event
}
@end
