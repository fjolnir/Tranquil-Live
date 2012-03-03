#import <TranquilCore/TranquilCore.h>
#import "TAppDelegate.h"
#import "ScriptContext.h"
#import "PluginManager.h"

@implementation TAppDelegate
@synthesize glView;

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTranquilFinishedLaunching object:nil];
}

@end
