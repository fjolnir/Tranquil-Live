#import "ScriptContext.h"
#import <RubyCocoa/RBObject.h>

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

- (id)executeFile:(NSString *)aPath error:(NSError **)aoErr
{
	@try {
        return [RBObject RBObjectWithRubyScriptString:[NSString stringWithContentsOfFile:aPath usedEncoding:NULL error:nil]];
	} @catch (NSException *e) {
		NSError *err = [NSError errorWithDomain:@"ScriptError" 
										   code:0 
									   userInfo:[NSDictionary dictionaryWithObject:[e description] 
																			forKey:@"description"]];
		[self _reportError:err];
		if(aoErr) *aoErr = err;
	}
	return nil;
}
- (id)executeScript:(NSString *)aSource error:(NSError **)aoErr
{
	@try {
		return [RBObject RBObjectWithRubyScriptString:aSource];
	} @catch (NSException *e) {
		NSError *err = [NSError errorWithDomain:@"ScriptError" 
										   code:0 
									   userInfo:[NSDictionary dictionaryWithObject:[e description] 
																			forKey:@"description"]];
		[self _reportError:err];
		if(aoErr) *aoErr = err;
	}
	return nil;
}

#pragma mark - Delegate

- (void)_reportError:(NSError *)aError {
	if(_delegate) [_delegate scriptContext:self encounteredError:aError];
}
@end
