#import "TAppDelegate.h"
#import "TMainWindowController.h"
#import "TScriptContext.h"
#import "TPluginManager.h"
#import "TScene.h"
#import "TShader.h"
#import "TState.h"
#import "TGLErrorChecking.h"
#import "TOpenGLLayer.h"

@implementation TAppDelegate
@synthesize glView;

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
	NSString *path = [[NSBundle mainBundle] pathForResource:@"startup" ofType:@"lua" inDirectory:@"Scripts"];
	NSString *bootScript = [NSString stringWithContentsOfFile:path usedEncoding:NULL error:nil];
	TScriptError *err = nil;
	[[TScriptContext sharedContext] executeScript:bootScript error:&err];
	if(err) {
		TLog(@"Error executing startup script: %@", err);
		[NSApp terminate:nil];
	}

	[[TPluginManager sharedManager] loadAllPlugins];
}

@end
