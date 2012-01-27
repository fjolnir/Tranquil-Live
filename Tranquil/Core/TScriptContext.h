// A Lua context


@class TScriptContext;

@protocol TScriptContextDelegate <NSObject>
- (void)scriptContext:(TScriptContext *)aContext encounteredError:(NSError *)aError;
@end

__attribute__((visibility("default"))) @interface TScriptContext : NSObject {
	id<TScriptContextDelegate> _delegate;
}

@property(readwrite, assign) id<TScriptContextDelegate> delegate;
+ (TScriptContext *)sharedContext;

- (BOOL)executeScript:(NSString *)source error:(NSError **)aoErr;
@end