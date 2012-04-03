#import <lua.h>
#import <lauxlib.h>
#import <lualib.h>
#import "ScriptContext.h"
#import <objc/runtime.h>

static ScriptContext *sharedContext;

int objcToLua(lua_State *L, const char *typeDescription, void *buffer);
int sizeOfTypeDescription(const char *aTypeDescription);
void instanceToLua(lua_State *L, id instance);

@interface ScriptContext () {
    lua_State *_luaState;
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
    
    _luaState = lua_open();
    luaL_openlibs(_luaState);
    
    return self;
}

- (void)dealloc
{
    lua_close(_luaState);
    [super dealloc];
}

- (BOOL)executeFile:(NSString *)aPath error:(NSError **)aoErr
{
    int err = 0;
    err = luaL_loadfile(_luaState, [aPath fileSystemRepresentation]);

    if(err) {
        [self _reportErrorWithMessage:(char*)lua_tostring(_luaState, -1) errorOut:aoErr];
        lua_pop(_luaState, 1);
        return NO;
    }
    err = lua_pcall(_luaState, 0, 0, 0);
    if(err) {
        [self _reportErrorWithMessage:(char*)lua_tostring(_luaState, -1) errorOut:aoErr];
        lua_pop(_luaState, 1);
        return NO;
    }
    return YES;
}
- (id)executeScript:(NSString *)aSource error:(NSError **)aoErr
{
    int err = 0;
    err = luaL_loadstring(_luaState, [aSource UTF8String]);
    if(err) {
        [self _reportErrorWithMessage:(char*)lua_tostring(_luaState, -1) errorOut:aoErr];
        lua_pop(_luaState, 1);
        return nil;
    }
    err = lua_pcall(_luaState, 0, 0, 0);
    if(err) {
        [self _reportErrorWithMessage:(char*)lua_tostring(_luaState, -1) errorOut:aoErr];
        lua_pop(_luaState, 1);
        return nil;
    }
    return nil;
}
- (id)executeFunction:(NSString *)aFunction withObjects:(NSArray *)aArgs error:(NSError **)aoErr
{
    int err = 0;
    lua_getglobal(_luaState, [aFunction UTF8String]);
    for(id arg in aArgs)
        instanceToLua(_luaState, arg);

    err = lua_pcall(_luaState, [aArgs count], 0, 0);
    if(err) {
        [self _reportErrorWithMessage:(char*)lua_tostring(_luaState, -1) errorOut:aoErr];
        lua_pop(_luaState, 1);
        return nil;
    }
    return nil;
}

- (void)addSearchPath:(NSString *)aPath
{
    [self executeScript:[NSString stringWithFormat:@"package.path = package.path .. ';%@/?.lua;%@/?/init.lua'", aPath, aPath]
                  error:nil];
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

#pragma mark - ObjC -> Lua object bridging

int sizeOfTypeDescription(const char *aTypeDescription)
{
    int i = 0;
    int size = 0;
    while(aTypeDescription[i]) {
        switch(aTypeDescription[i]) {
            case _C_PTR:
            case _C_CHARPTR:
                size += sizeof(void*);
                break;
            case _C_CHR:
            case _C_UCHR:
                size += sizeof(char);
                break;
            case _C_INT:
            case _C_UINT:
                size += sizeof(int);
                break;
            case _C_SHT:
            case _C_USHT:
                size += sizeof(short);
                break;
            case _C_LNG:
            case _C_ULNG:
                size += sizeof(long);
                break;
            case _C_LNG_LNG:
            case _C_ULNG_LNG:
                size += sizeof(long long);
                break;
            case _C_FLT:
                size += sizeof(float);
                break;
            case _C_DBL:
                size += sizeof(double);
                break;
            case _C_BOOL:
                size += sizeof(_Bool);
                break;
            case _C_VOID:
                size += sizeof(char);
                break;
            case _C_ID:
                size += sizeof(id);
                break;
            case _C_CLASS:
                size += sizeof(Class);
                break;
            case _C_SEL:
                size += sizeof(SEL);
                break;
            default:
                [NSException raise:@"Tranquil Error" format:@"Unsupported type %c", aTypeDescription[i]];
        }
        ++i;
    }
    return size;
}
#define BEGIN_STACK_MODIFY(L) int __startStackIndex = lua_gettop((L));

#define END_STACK_MODIFY(L, i) while(lua_gettop((L)) > (__startStackIndex + (i))) lua_remove((L), __startStackIndex + 1);

int objcToLua(lua_State *L, const char *typeDescription, void *buffer) {
    BEGIN_STACK_MODIFY(L)
    
    int size = sizeOfTypeDescription(typeDescription);
    
    switch (typeDescription[0]) {
        case _C_VOID:
            lua_pushnil(L);
            break;
            
        case _C_PTR:
            lua_pushlightuserdata(L, *(void **)buffer);
            break;                        
            
        case _C_CHR: {
            char c = *(char *)buffer;
            if (c <= 1) lua_pushboolean(L, c); // If it's 1 or 0, then treat it like a bool
            else lua_pushinteger(L, c);
            break;
        }
            
        case _C_SHT:
            lua_pushinteger(L, *(short *)buffer);            
            break;
            
        case _C_INT:
            lua_pushnumber(L, *(int *)buffer);
            break;
            
        case _C_UCHR:
            lua_pushnumber(L, *(unsigned char *)buffer);
            break;
            
        case _C_UINT:
            lua_pushnumber(L, *(unsigned int *)buffer);
            break;
            
        case _C_USHT:
            lua_pushinteger(L, *(short *)buffer);
            break;
            
        case _C_LNG:
            lua_pushnumber(L, *(long *)buffer);
            break;
            
        case _C_LNG_LNG:
            lua_pushnumber(L, *(long long *)buffer);
            break;
            
        case _C_ULNG:
            lua_pushnumber(L, *(unsigned long *)buffer);
            break;
            
        case _C_ULNG_LNG:
            lua_pushnumber(L, *(unsigned long long *)buffer);
            break;
            
        case _C_FLT:
            lua_pushnumber(L, *(float *)buffer);
            break;
            
        case _C_DBL:
            lua_pushnumber(L, *(double *)buffer);
            break;
            
        case _C_BOOL:
            lua_pushboolean(L, *(BOOL *)buffer);
            break;
            
        case _C_CHARPTR:
            lua_pushstring(L, *(char **)buffer);
            break;
            
        case _C_ID: {
            id instance = *(id *)buffer;
            instanceToLua(L, instance);
            break;
        }
            
      /*  case _C_STRUCT_B: {
            wax_fromStruct(L, typeDescription, buffer);
            break;
        }*/
            
        case _C_SEL:
            lua_pushstring(L, sel_getName(*(SEL *)buffer));
            break;            
            
        default:
            luaL_error(L, "Unable to convert Obj-C type with type description '%s'", typeDescription);
            break;
    }
    
    END_STACK_MODIFY(L, 1)
    
    return size;
}

void instanceToLua(lua_State *L, id instance) {
    BEGIN_STACK_MODIFY(L)
    
    if(instance) {
        if([instance isKindOfClass:[NSString class]]) {    
            lua_pushstring(L, [(NSString *)instance UTF8String]);
        }
        else if([instance isKindOfClass:[NSNumber class]]) {
            lua_pushnumber(L, [instance doubleValue]);
        }
        else if([instance isKindOfClass:[NSArray class]]) {
            lua_newtable(L);
            for (id obj in instance) {
                int i = lua_objlen(L, -1);
                instanceToLua(L, obj);
                lua_rawseti(L, -2, i + 1);
            }
        }
        else if([instance isKindOfClass:[NSDictionary class]]) {
            lua_newtable(L);
            for (id key in instance) {
                instanceToLua(L, key);
                instanceToLua(L, [instance objectForKey:key]);
                lua_rawset(L, -3);
            }
        }                
        else if([instance isKindOfClass:[NSValue class]]) {
            void *buffer = malloc(sizeOfTypeDescription([instance objCType]));
            [instance getValue:buffer];
            objcToLua(L, [instance objCType], buffer);
            free(buffer);
        }
        else {
            assert(0);
        }
    }
    else {
        lua_pushnil(L);
    }
    
    END_STACK_MODIFY(L, 1)
}