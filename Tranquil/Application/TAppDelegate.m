#import <TranquilCore/TranquilCore.h>
#import "TAppDelegate.h"
#import "ScriptContext.h"
#import "PluginManager.h"

@implementation TAppDelegate
@synthesize glView;

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
	NSString *path = [[NSBundle mainBundle] pathForResource:@"startup" ofType:@"rb" inDirectory:@"Scripts"];
    // Add the script dir to the load path
    NSString *scriptDir = [path stringByDeletingLastPathComponent];
    [[ScriptContext sharedContext] executeScript:[NSString stringWithFormat:@"$LOAD_PATH.push '%@'", scriptDir]
                                           error:nil];
    
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
