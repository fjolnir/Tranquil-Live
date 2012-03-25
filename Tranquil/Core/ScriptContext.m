#import <LuaCocoa/LuaCocoa.h>
#import "ScriptContext.h"

static ScriptContext *sharedContext;

@interface ScriptContext () {
    LuaCocoa *_luaCocoa;
}
- (void)_reportErrorWithMessage:(char *)aMessage errorOut:(NSError **)aoErr;
- (void)_reportError:(NSError *)aError;
@end


@implementation ScriptContext
@synthesize delegate=_delegate;

+ (ScriptContext *)sharedContext
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedContext = [[self alloc] init];
	});
	return sharedContext;
}

- (id)init
{
    if(!(self = [super init]))
        return nil;
    
    _luaCocoa = [[LuaCocoa alloc] init];
    
    return self;
}

- (BOOL)executeFile:(NSString *)aPath error:(NSError **)aoErr
{
    int err = 0;
    lua_State *luaState = [_luaCocoa luaState];
    err = luaL_loadfile(luaState, [aPath fileSystemRepresentation]);

    if(err) {
        [self _reportErrorWithMessage:(char*)lua_tostring(luaState, -1) errorOut:aoErr];
        lua_pop(luaState, 1);
        return NO;
    }
    err = lua_pcall(luaState, 0, 0, 0);
    if(err) {
        [self _reportErrorWithMessage:(char*)lua_tostring(luaState, -1) errorOut:aoErr];
        lua_pop(luaState, 1);
        return NO;
    }
    return YES;
}
- (id)executeScript:(NSString *)aSource error:(NSError **)aoErr
{
    int err = 0;
    lua_State *luaState = [_luaCocoa luaState];
    err = luaL_loadstring(luaState, [aSource UTF8String]);
    if(err) {
        [self _reportErrorWithMessage:(char*)lua_tostring(luaState, -1) errorOut:aoErr];
        lua_pop(luaState, 1);
        return nil;
    }
    err = lua_pcall(luaState, 0, 0, 0);
    if(err) {
        [self _reportErrorWithMessage:(char*)lua_tostring(luaState, -1) errorOut:aoErr];
        lua_pop(luaState, 1);
        return nil;
    }
    return nil;
}
- (id)executeFunction:(NSString *)aFunction withObjects:(NSArray *)aArgs error:(NSError **)aoErr
{
    int err = 0;
    lua_State *luaState = [_luaCocoa luaState];
    lua_getglobal(luaState, [aFunction UTF8String]);
    for(id arg in aArgs)
        LuaCocoa_PushUnboxedPropertyList(luaState, arg);

    err = lua_pcall(luaState, [aArgs count], 0, 0);
    if(err) {
        [self _reportErrorWithMessage:(char*)lua_tostring(luaState, -1) errorOut:aoErr];
        lua_pop(luaState, 1);
        return nil;
    }
    return nil;
}

- (void)addSearchPath:(NSString *)aPath
{
    [self executeScript:[NSString stringWithFormat:@"package.path = package.path .. ';%@/?.lua'", aPath]
                  error:nil];
}

- (BOOL)loadBridgeSupport:(NSString *)aPath
{
    return [_luaCocoa loadFrameworkWithBaseName:[[aPath lastPathComponent] stringByDeletingPathExtension]
                                       hintPath:[aPath stringByDeletingLastPathComponent]
                            searchHintPathFirst:YES skipDLopen:YES];
}
#pragma mark - Delegate

- (void)_reportErrorWithMessage:(char *)aMessage errorOut:(NSError **)aoErr
{
    NSString *errMsg = [NSString stringWithUTF8String:aMessage];
    NSError *err = [NSError errorWithDomain:@"ScriptError" 
                                       code:0 
                                   userInfo:[NSDictionary dictionaryWithObject:errMsg
                                                                        forKey:@"description"]];
    [self _reportError:err];
    if(aoErr) *aoErr = err;
}
- (void)_reportError:(NSError *)aError {
	if(_delegate) [_delegate scriptContext:self encounteredError:aError];
}
@end
