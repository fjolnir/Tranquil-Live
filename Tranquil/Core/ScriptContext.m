#import <lua.h>
#import <lauxlib.h>
#import "ScriptContext.h"
#import <objc/runtime.h>

static ScriptContext *sharedContext;

void LuaObjectBridge_pushunboxednsnumber(lua_State* lua_state, NSNumber* the_number);
void LuaObjectBridge_pushunboxednsstring(lua_State* lua_state, NSString* the_string);
void LuaObjectBridge_pushunboxednsarray(lua_State* lua_state, NSArray* the_array);
void LuaObjectBridge_pushunboxednsdictionary(lua_State* lua_state, NSDictionary* the_dictionary);
void LuaObjectBridge_pushunboxedpropertylist(lua_State* lua_state, id the_object);

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
        LuaObjectBridge_pushunboxedpropertylist(_luaState, arg);

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
    [self executeScript:[NSString stringWithFormat:@"package.path = package.path .. ';%@/?.lua'", aPath]
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

void LuaObjectBridge_pushunboxednsnumber(lua_State* lua_state, NSNumber* the_number)
{
	lua_checkstack(lua_state, 1);
	if(nil == the_number)
	{
		lua_pushnil(lua_state);
	}
	const char* objc_type = [the_number objCType];
	switch(objc_type[0])
	{
		case _C_BOOL:
		{
			lua_pushboolean(lua_state, [the_number boolValue]);		
			break;
		}
		case _C_CHR:
		case _C_UCHR:
		{
			// booleans in NSNumber are returning 'c' as the type and not 'B'.
			// The class type is NSCFBoolean, but I've read it is a private class so I don't want to reference it directly.
			// So I'll create an instance of it and compare to it.
			// (I've read it is a singleton.)
			if([[NSNumber numberWithBool:YES] class] == [the_number class])
			{
				lua_pushboolean(lua_state, [the_number boolValue]);		
			}
			else
			{
				lua_pushinteger(lua_state, (lua_Integer)[the_number integerValue]);		
			}
			break;
		}
		case _C_SHT:
		case _C_USHT:
		case _C_INT:
		case _C_UINT:
		case _C_LNG:
		case _C_ULNG:
		case _C_LNG_LNG:
		case _C_ULNG_LNG:
		{
			lua_pushinteger(lua_state, (lua_Integer)[the_number integerValue]);		
			break;
		}
		case _C_FLT:
		case _C_DBL:
		default:
		{
			lua_pushinteger(lua_state, (lua_Number)[the_number doubleValue]);		
			break;			
		}
	}
}

void LuaObjectBridge_pushunboxednsstring(lua_State* lua_state, NSString* the_string)
{
	lua_checkstack(lua_state, 1);
	if(nil == the_string)
	{
		lua_pushnil(lua_state);
	}
	else if([the_string length] == 0)
	{
		lua_pushnil(lua_state);		
	}
	else
	{
		lua_pushstring(lua_state, [the_string UTF8String]);
	}
}

void LuaObjectBridge_pushunboxednsarray(lua_State* lua_state, NSArray* the_array)
{
	if([the_array isKindOfClass:[NSArray class]])
	{
		lua_checkstack(lua_state, 3); // is it really 3? table+key+value?
		lua_newtable(lua_state);
		int table_index = lua_gettop(lua_state);
		int current_lua_array_index = 1;
		for(id an_element in the_array)
		{
			// recursively add elements
			LuaObjectBridge_pushunboxedpropertylist(lua_state, an_element);
			lua_rawseti(lua_state, table_index, current_lua_array_index);
			current_lua_array_index++;
		}
	}
	else
	{
		lua_checkstack(lua_state, 1);
		lua_pushnil(lua_state);
	}
	
}


void LuaObjectBridge_pushunboxednsdictionary(lua_State* lua_state, NSDictionary* the_dictionary)
{
	if([the_dictionary isKindOfClass:[NSDictionary class]])
	{
		lua_checkstack(lua_state, 3); // is it really 3? table+key+value?
		lua_newtable(lua_state);
		int table_index = lua_gettop(lua_state);
		for(id a_key in the_dictionary)
		{
			// recursively add elements
			LuaObjectBridge_pushunboxedpropertylist(lua_state, a_key); // push key
			LuaObjectBridge_pushunboxedpropertylist(lua_state, [the_dictionary valueForKey:a_key]); // push value
			lua_rawset(lua_state, table_index);
		}
	}
	else
	{
		lua_checkstack(lua_state, 1);
		lua_pushnil(lua_state);
	}
	
}

void LuaObjectBridge_pushunboxedpropertylist(lua_State* lua_state, id the_object)
{
	if(nil == the_object)
	{
		lua_checkstack(lua_state, 1);
		lua_pushnil(lua_state);
	}
	if([the_object isKindOfClass:[NSNull class]])
	{
		lua_checkstack(lua_state, 1);
		lua_pushnil(lua_state);
	}
	else if([the_object isKindOfClass:[NSNumber class]])
	{
		LuaObjectBridge_pushunboxednsnumber(lua_state, the_object);
	}
	else if([the_object isKindOfClass:[NSString class]])
	{
		LuaObjectBridge_pushunboxednsstring(lua_state, the_object);
	}
	else if([the_object isKindOfClass:[NSArray class]])
	{
		LuaObjectBridge_pushunboxednsarray(lua_state, the_object);
	}
	else if([the_object isKindOfClass:[NSDictionary class]])
	{
		LuaObjectBridge_pushunboxednsdictionary(lua_state, the_object);
	}
	else if([the_object isKindOfClass:[NSValue class]] && !strcmp([the_object objCType], @encode(SEL)))
	{
		SEL return_selector;
		[the_object getValue:&return_selector];
		lua_pushstring(lua_state, [NSStringFromSelector(return_selector) UTF8String]);
	}
	else
	{
		lua_checkstack(lua_state, 1);
		lua_pushnil(lua_state);
	}
}
