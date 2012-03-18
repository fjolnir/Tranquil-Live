#import "PluginManager.h"
#import <TranquilCore/TranquilCore.h>
#import <RubyCocoa/RubyCocoa.h>
#import "ScriptContext.h"

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

    // Load a bridge support file if one is supplied
    NSString *bsPath = [bundle pathForResource:[[aPath lastPathComponent] stringByDeletingPathExtension]
                                        ofType:@"bridgesupport"];
    if(bsPath) {
        NSString *bsLoadScript;
        bsLoadScript = [NSString stringWithFormat:@"OSX.load_bridge_support_file('%@')", bsPath];
        [[ScriptContext sharedContext] executeScript:bsLoadScript error:nil];
    }
//    if(bsPath)
//        [[MacRuby sharedRuntime] loadBridgeSupportFileAtPath:bsPath];

	BOOL result = [pluginLoader loadPlugin];
	if(result) {
		NSString *loadScriptPath = [[NSBundle bundleForClass:pluginLoader] pathForResource:@"load" 
																					ofType:@"rb" 
																			   inDirectory:@"Scripts"];
        if(loadScriptPath) {
            // Add the script dir to the load path
            NSString *scriptDir = [loadScriptPath stringByDeletingLastPathComponent];
            [[ScriptContext sharedContext] executeScript:[NSString stringWithFormat:@"$LOAD_PATH.push '%@'", scriptDir]
                                                   error:nil];
            RBBundleInit([loadScriptPath UTF8String], pluginLoader, nil);
        }
//		[[ScriptContext sharedContext] executeFile:loadScriptPath error:nil];
	}
	return YES;
}
@end
