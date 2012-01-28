// A Lua context


@class ScriptContext;

@protocol ScriptContextDelegate <NSObject>
- (void)scriptContext:(ScriptContext *)aContext encounteredError:(NSError *)aError;
@end

__attribute__((visibility("default"))) @interface ScriptContext : NSObject {
	id<ScriptContextDelegate> _delegate;
}

@property(readwrite, assign) id<ScriptContextDelegate> delegate;
+ (ScriptContext *)sharedContext;

- (id)executeScript:(NSString *)aSource error:(NSError **)aoErr;
- (id)executeFile:(NSString *)aPath error:(NSError **)aoErr;
@end