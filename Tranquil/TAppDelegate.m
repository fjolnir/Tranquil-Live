#import "TAppDelegate.h"
#import "MainWindowController.h"
#import "ScriptContext.h"
#import "PluginManager.h"
#import "Scene.h"
#import "Shader.h"
#import "State.h"
#import "GLErrorChecking.h"
#import "OpenGLLayer.h"

@implementation TAppDelegate
@synthesize glView;

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
	NSString *path = [[NSBundle mainBundle] pathForResource:@"startup" ofType:@"rb" inDirectory:@"Scripts"];
	NSError *err = nil;
	[[ScriptContext sharedContext] executeFile:path error:&err];
	if(err) {
		TLog(@"Error executing startup script: %@", err);
		[NSApp terminate:nil];
	}
	[[PluginManager sharedManager] loadAllPlugins];
	
	[[ScriptContext sharedContext] executeScript:@"_setup" error:nil];
}

@end
