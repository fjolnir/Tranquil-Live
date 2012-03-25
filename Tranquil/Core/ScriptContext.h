// A Lua context


@class ScriptContext;

@protocol ScriptContextDelegate <NSObject>
- (void)scriptContext:(ScriptContext *)aContext encounteredError:(NSError *)aError;
@end

@interface ScriptContext : NSObject {
	id<ScriptContextDelegate> _delegate;
}

@property(readwrite, assign) id<ScriptContextDelegate> delegate;
+ (ScriptContext *)sharedContext;

- (id)executeScript:(NSString *)aSource error:(NSError **)aoErr;
- (BOOL)executeFile:(NSString *)aPath error:(NSError **)aoErr;
- (id)executeFunction:(NSString *)aFunction withObjects:(NSArray *)aArgs error:(NSError **)aoErr;

- (void)addSearchPath:(NSString *)aPath;

- (BOOL)loadBridgeSupport:(NSString *)aPath;
@end