#import "TMainWindowController.h"
#import "TOpenGLView.h"
#import "TOverlayTextView.h"
#import "TScriptContext.h"
#import "TSCene.h"

@implementation TMainWindowController

@synthesize mainView=_mainView, scriptView=_scriptView, scene=_scene;


- (void)awakeFromNib
{
	_scriptView.enclosingScrollView.frame = _mainView.bounds;
	[_mainView addSubview:_scriptView.enclosingScrollView];
	_scene = [[TScene alloc] init];
	[_mainView addRenderable:_scene];
}

- (IBAction)runActiveScript:(id)sender
{
	TScriptError *err = nil;
	[[TScriptContext sharedContext] executeScript:[[_scriptView textStorage] string] error:&err];
	if(err)
		NSLog(@"%@", err);
}
@end
