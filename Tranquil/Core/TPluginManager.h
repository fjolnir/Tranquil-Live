@interface TPluginManager : NSObject
+ (TPluginManager *)sharedManager;

- (void)loadAllPlugins;
- (void)loadPluginInDirectory:(NSString *)aPath;
- (BOOL)loadPluginAtPath:(NSString *)aPath;
@end
