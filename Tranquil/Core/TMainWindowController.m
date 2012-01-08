#import "TMainWindowController.h"
#import "TOpenGLView.h"
#import "TOverlayTextView.h"
#import "TScriptContext.h"

@implementation TMainWindowController

@synthesize mainView=_mainView, scriptView=_scriptView;


- (void)awakeFromNib
{
	_scriptView.enclosingScrollView.frame = _mainView.bounds;
	[_mainView addSubview:_scriptView.enclosingScrollView];
}

- (IBAction)runActiveScript:(id)sender
{
	TScriptError *err = nil;
	[[TScriptContext sharedContext] executeScript:[[_scriptView textStorage] string] error:&err];
	if(err)
		NSLog(@"%@", err);
}
@end
