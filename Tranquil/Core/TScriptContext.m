#import "TScriptContext.h"

static TScriptContext *sharedContext;

@interface TScriptContext ()
- (void)_reportError:(TScriptError *)aError;
@end

// TODO: Throws an error if the app has been unresponsive for too long (usually because of out of control recursion)
static void escapeHook(lua_State *state, lua_Debug *ar)
{
	NSLog(@"1000 instr");
}

@implementation TScriptContext
@synthesize delegate=_delegate;

+ (TScriptContext *)sharedContext
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedContext = [[self alloc] init];
	});
	return sharedContext;
}

- (id)init
{
	self = [super init];
	if(!self) return nil;
	
	_state = luaL_newstate();
	luaL_openlibs(_state);
	//lua_sethook(_state, escapeHook, LUA_MASKCOUNT, 1000);

	return self;
}

- (BOOL)executeScript:(NSString *)aSource error:(TScriptError **)aoErr
{
	int loadResult = luaL_loadstring(_state, [aSource UTF8String]);
	if(loadResult) {
		const char *errMsg = lua_tostring(_state, -1);
		TScriptError *error = [TScriptError errorWithType:loadResult message:[NSString stringWithUTF8String:errMsg]];
		[self _reportError:error];
		if(aoErr) *aoErr = error;
		
		return NO;
	}
	
	int runResult = lua_pcall(_state, 0, LUA_MULTRET, 0);
	if(runResult) {
		const char *errMsg = lua_tostring(_state, -1);
		TScriptError *error = [TScriptError errorWithType:runResult message:[NSString stringWithUTF8String:errMsg]];
		[self _reportError:error];
		if(aoErr) *aoErr = error;
		
		return NO;
	}
	return YES;
}

- (BOOL)callGlobalFunction:(NSString *)aFunction withArguments:(NSArray *)aArguments
{
	lua_getglobal(_state, [aFunction UTF8String]);
	if(lua_pcall(_state, 0, 0, 0) != 0)
		return NO;
	return YES;
}

#pragma mark - Delegate

- (void)_reportError:(TScriptError *)aError {
	if(_delegate) [_delegate scriptContext:self encounteredError:aError];
}
@end

@implementation TScriptError
@synthesize type=_type, message=_message;
+ (TScriptError *)errorWithType:(TScriptErrorType)aType message:(NSString *)aMessage
{
	return [[[self alloc] initWithType:aType message:aMessage] autorelease];
}
- (id)initWithType:(TScriptErrorType)aType message:(NSString *)aMessage
{
	if(!(self = [super init])) return nil;
	_type = aType;
	_message = [aMessage copy];
	return self;
}
- (NSString *)description {
	return [NSString stringWithFormat:@"%@ <0x%x> %@", NSStringFromClass([self class]), self, _message];
}
- (void)dealloc
{
	[_message release];
	[super dealloc];
}
@end