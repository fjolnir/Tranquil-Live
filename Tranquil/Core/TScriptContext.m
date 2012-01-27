#import "TScriptContext.h"
#import <MacRuby/MacRuby.h>

static TScriptContext *sharedContext;

@interface TScriptContext ()
- (void)_reportError:(NSError *)aError;
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
