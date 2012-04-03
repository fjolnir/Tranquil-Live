#import "MainWindowController.h"
#import "MainView.h"
#import "OverlayTextView.h"
#import <TranquilCore/TranquilCore.h>

@implementation MainWindowController
@synthesize mainView=_mainView, consoleView=_consoleView, tabView=_tabView;

- (void)awakeFromNib
{
    [[ScriptContext sharedContext] setDelegate:self];
    // Use the same aspect ratio as the display
//	self.window.aspectRatio = NSMakeSize(1.65, 1);
    [Logger sharedLogger].delegate = self;
}

- (IBAction)switchScriptView:(id)sender
{
    if(!([sender isKindOfClass:[NSMenuItem class]]))
        return;
    NSMenuItem *menuItem = sender;
    [_tabView selectTabViewItemAtIndex:menuItem.tag];
}

- (OverlayTextView *)_activeScriptView
{
    OverlayTextView *ret = [_tabView selectedTabViewItem].initialFirstResponder;
    if(![ret isKindOfClass:[OverlayTextView class]])
        return nil;
    return ret;
}

- (IBAction)runActiveScript:(id)sender
{
	NSError *err = nil;
    OverlayTextView *scriptView = [self _activeScriptView];
    if(!scriptView)
        return;
    [[ScriptContext sharedContext] executeScript:[[scriptView textStorage] string] error:&err];
}

- (IBAction)runSelection:(id)sender
{
    OverlayTextView *scriptView = [self _activeScriptView];
    if(!scriptView)
        return;
	NSRange range = [scriptView selectedRange];
	if(range.length <= 0) return;
	NSString *script = [[[scriptView textStorage] string] substringWithRange:range];
	NSError *err = nil;
	[[ScriptContext sharedContext] executeScript:script error:&err];
}

#pragma mark - Script context delegate

- (void)scriptContext:(ScriptContext *)aContext encounteredError:(NSError *)aError
{
    NSString *message = [aError.userInfo objectForKey:@"description"];
    //NSRange evalRange = [message rangeOfString:@"/(eval):"];
    // If it's a message from eval (most likely case, get rid of the pwd)
    //if(evalRange.location != NSNotFound) {
    //    message = [message substringFromIndex:evalRange.location+1];
    //}
    NSLog(@"%@", message);
    // Append to the console view
    message = [message stringByAppendingString:@"\n"];
    NSAttributedString *consoleOutput = [[NSAttributedString alloc] initWithString:message attributes:_consoleView.typingAttributes];

    [[_consoleView textStorage] appendAttributedString:consoleOutput];
    [consoleOutput release];
}

- (void)logger:(Logger *)aLogger receivedMessage:(NSString *)aMessage
{
    NSAttributedString *consoleOutput = [[NSAttributedString alloc] initWithString:aMessage
                                                                        attributes:_consoleView.typingAttributes];
    
    [[_consoleView textStorage] appendAttributedString:consoleOutput];
    [consoleOutput release];
}
@end
