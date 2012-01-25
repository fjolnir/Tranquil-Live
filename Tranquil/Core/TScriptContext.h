// A Lua context


@class TScriptContext, TScriptError;

@protocol TScriptContextDelegate <NSObject>
- (void)scriptContext:(TScriptContext *)aContext encounteredError:(TScriptError *)aError;
@end

__attribute__((visibility("default"))) @interface TScriptContext : NSObject {
	id<TScriptContextDelegate> _delegate;
}

@property(readwrite, assign) id<TScriptContextDelegate> delegate;
+ (TScriptContext *)sharedContext;

- (BOOL)executeScript:(NSString *)source error:(TScriptError **)aoErr;
- (BOOL)callGlobalFunction:(NSString *)aFunction withArguments:(NSArray *)aArguments;
@end

typedef enum {
	kTScriptSyntaxError = 1,
	kTScriptRuntimeError = 2,
	kTScriptAllocationError = 3,
	kTScriptUnknownError = 4
} TScriptErrorType;

__attribute__((visibility("default"))) @interface TScriptError : NSObject
@property(readonly) TScriptErrorType type;
@property(readonly) NSString *message;

+ (TScriptError *)errorWithType:(TScriptErrorType)aType message:(NSString *)aMessage;
- (id)initWithType:(TScriptErrorType)aType message:(NSString *)aMessage;
@end