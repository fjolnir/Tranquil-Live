#import "ScriptContext.h"
#import <MacRuby/MacRuby.h>

static ScriptContext *sharedContext;

@interface ScriptContext ()
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

- (BOOL)executeScript:(NSString *)aSource error:(NSError **)aoErr
{
	@try {
		[[MacRuby sharedRuntime] evaluateString:aSource];
	} @catch (NSException *e) {
		NSError *err = [NSError errorWithDomain:@"ScriptError" 
										   code:0 
									   userInfo:[NSDictionary dictionaryWithObject:[e description] 
																			forKey:@"description"]];
		[self _reportError:err];
		if(aoErr) *aoErr = err;
	}
	return YES;
}

#pragma mark - Delegate

- (void)_reportError:(NSError *)aError {
	if(_delegate) [_delegate scriptContext:self encounteredError:aError];
}
@end
