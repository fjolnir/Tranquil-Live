#import "PluginManager.h"
#import "TranquilPlugin.h"

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
	return [pluginLoader loadPlugin];
}
@end
