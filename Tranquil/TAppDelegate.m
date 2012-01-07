#import "TAppDelegate.h"
#import "TMainWindowController.h"
#import "TScriptContext.h"

@implementation TAppDelegate

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSString *path = [[NSBundle mainBundle] pathForResource:@"startup" ofType:@"lua" inDirectory:@"Scripts"];
	NSString *bootScript = [NSString stringWithContentsOfFile:path usedEncoding:NULL error:nil];
	TScriptError *err = nil;
	[[TScriptContext sharedContext] executeScript:bootScript error:&err];
	if(err) {
		NSLog(@"Error executing startup script: %@", err);
		[NSApp terminate:nil];
	}
}

@end
