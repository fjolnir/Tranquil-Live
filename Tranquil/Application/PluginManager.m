#import "PluginManager.h"
#import <TranquilCore/TranquilCore.h>

static PluginManager *sharedInstance;

@implementation PluginManager
+ (PluginManager *)sharedManager
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

- (void)loadAllPlugins
{
	[self loadPluginInDirectory:[[NSBundle mainBundle] builtInPlugInsPath]];
}

- (void)loadPluginInDirectory:(NSString *)aPath
{ 
	NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:aPath error:nil];
	if(!contents) return;
	
	for(NSString *entry in contents) {
		if(![[entry pathExtension] isEqualToString:@"bundle"]) continue;
		[self loadPluginAtPath:[aPath stringByAppendingPathComponent:entry]];
	}
}

- (BOOL)loadPluginAtPath:(NSString *)aPath
{
	NSBundle *bundle = [NSBundle bundleWithPath:aPath];
	if(!bundle) return NO;
	NSError *err = nil;
	[bundle loadAndReturnError:&err];
	if(err) {
		TLog(@"Error loading plugin %@: %@", [aPath lastPathComponent], err);
		return NO;
	}
	Class pluginLoader = [bundle principalClass];
	if(![pluginLoader conformsToProtocol:@protocol(TranquilPlugin)]) {
		TLog(@"Invalid plugin (%@)", [aPath lastPathComponent]);
		return NO;
	}


	BOOL result = [pluginLoader loadPlugin];
	if(result) {
		NSString *loadScriptPath = [[NSBundle bundleForClass:pluginLoader] pathForResource:@"load" 
																					ofType:@"lua" 
																			   inDirectory:@"Scripts"];
        if(loadScriptPath) {
            // Add the script dir to the load path
            NSString *scriptDir = [loadScriptPath stringByDeletingLastPathComponent];
            
//            [[ScriptContext sharedContext] addSearchPath:scriptDir];
//            [[ScriptContext sharedContext] executeFile:loadScriptPath error:nil];
        }
	}
	return YES;
}
@end
