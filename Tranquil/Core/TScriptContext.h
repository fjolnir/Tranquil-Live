// A Lua context

/*#include <Lua/lua.h>
#include <Lua/lauxlib.h>
#include <Lua/lualib.h>*/
#include <lua.h>
#include <luajit.h>
#include <lauxlib.h>
#include <lualib.h>

@class TScriptContext, TScriptError;

@protocol TScriptContextDelegate <NSObject>
- (void)scriptContext:(TScriptContext *)aContext encounteredError:(TScriptError *)aError;
@end

__attribute__((visibility("default"))) @interface TScriptContext : NSObject {
	lua_State *_state;
	id<TScriptContextDelegate> _delegate;
}

@property(readwrite, assign) id<TScriptContextDelegate> delegate;
@property(readonly) lua_State *luaState;
+ (TScriptContext *)sharedContext;

- (BOOL)executeScript:(NSString *)source error:(TScriptError **)aoErr;
- (BOOL)callGlobalFunction:(NSString *)aFunction withArguments:(NSArray *)aArguments;
@end

typedef enum {
	kTScriptSyntaxError = LUA_ERRSYNTAX,
	kTScriptRuntimeError = LUA_ERRRUN,
	kTScriptAllocationError = LUA_ERRMEM,
	kTScriptUnknownError = LUA_ERRERR
} TScriptErrorType;

__attribute__((visibility("default"))) @interface TScriptError : NSObject
@property(readonly) TScriptErrorType type;
@property(readonly) NSString *message;

+ (TScriptError *)errorWithType:(TScriptErrorType)aType message:(NSString *)aMessage;
- (id)initWithType:(TScriptErrorType)aType message:(NSString *)aMessage;
@end