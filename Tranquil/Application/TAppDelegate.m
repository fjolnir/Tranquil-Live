#import <TranquilCore/TranquilCore.h>
#import <Tranquil/CodeGen/TQProgram.h>
#import "TAppDelegate.h"
#import "PluginManager.h"

@implementation TAppDelegate
@synthesize glView;

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
//    [[TQProgram sharedProgram] setShouldShowDebugInfo:YES];
	NSString *path = [[NSBundle mainBundle] pathForResource:@"startup" ofType:@"tq" inDirectory:@"Scripts"];
    // Add the script dir to the load path
    NSString *scriptDir = [path stringByDeletingLastPathComponent];
    [[[TQProgram sharedProgram] searchPaths] addObject:scriptDir];
    [[[TQProgram sharedProgram] searchPaths] addObject:[[NSBundle mainBundle] privateFrameworksPath]];
    
	NSError *err = nil;
    [[TQProgram sharedProgram] executeScriptAtPath:path error:&err];
	if(err) {
		TLog(@"Error executing startup script: %@", err);
		[NSApp terminate:nil];
	}
	[[PluginManager sharedManager] loadAllPlugins];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTranquilFinishedLaunching object:nil];
}

@end
