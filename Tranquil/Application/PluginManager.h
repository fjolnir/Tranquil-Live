@interface PluginManager : NSObject
+ (PluginManager *)sharedManager;

- (void)loadAllPlugins;
- (void)loadPluginInDirectory:(NSString *)aPath;
- (BOOL)loadPluginAtPath:(NSString *)aPath;
@end
