#import "TScriptContext.h"

static TScriptContext *sharedContext;

@interface TScriptContext ()
- (void)_reportError:(TScriptError *)aError;
@end


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
	

	return self;
}

- (BOOL)executeScript:(NSString *)aSource error:(TScriptError **)aoErr
{

	return YES;
}

- (BOOL)callGlobalFunction:(NSString *)aFunction withArguments:(NSArray *)aArguments
{

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