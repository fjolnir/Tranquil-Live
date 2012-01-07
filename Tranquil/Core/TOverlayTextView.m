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

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
	if(self) [self _init];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) [self _init];
    return self;
}

- (void)viewWillMoveToSuperview:(NSView *)newSuperview
{
	((NSScrollView *)newSuperview).drawsBackground = NO;
}

- (BOOL)isOpaque
{
	return NO;
}

- (void)scrollWheel:(NSEvent *)theEvent
{
	// Do nothing, doesn't look good
}
@end
