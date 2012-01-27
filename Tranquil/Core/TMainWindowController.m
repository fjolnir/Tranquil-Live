#import "TMainWindowController.h"
#import "TMainView.h"
#import "TOverlayTextView.h"
#import "TScriptContext.h"

@implementation TMainWindowController

@synthesize mainView=_mainView, scriptView=_scriptView;


- (void)awakeFromNib
{
	_scriptView.enclosingScrollView.frame = _mainView.bounds;
	[_mainView addSubview:_scriptView.enclosingScrollView];
	self.window.aspectRatio = NSMakeSize(1.65, 1);
}

- (IBAction)runActiveScript:(id)sender
{
	NSError *err = nil;
	[[TScriptContext sharedContext] executeScript:[[_scriptView textStorage] string] error:&err];
	if(err)
		TLog(@"%@", [err.userInfo objectForKey:@"description"]);
}

- (IBAction)runSelection:(id)sender
{
	NSRange range = [_scriptView selectedRange];
	if(range.length <= 0) return;
	NSString *script = [[[_scriptView textStorage] string] substringWithRange:range];
	NSError *err = nil;
	[[TScriptContext sharedContext] executeScript:script error:&err];
	if(err)
		TLog(@"%@", [err.userInfo objectForKey:@"description"]);
}
@end
