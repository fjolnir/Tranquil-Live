#import "ScriptContext.h"
#import <RubyCocoa/RBObject.h>
#import <Ruby/Ruby.h>

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

- (BOOL)executeFile:(NSString *)aPath error:(NSError **)aoErr
{
    int err = 0;
    ruby_script([aPath UTF8String]);
    rb_load_file([aPath UTF8String]);
    err = ruby_exec();

    if(err) {
        VALUE exception = rb_gv_get("$!");
        char *buffer = RSTRING(rb_obj_as_string(exception))->ptr;
        NSString *errMsg = [NSString stringWithUTF8String:buffer];
        NSError *err = [NSError errorWithDomain:@"ScriptError" 
										   code:0 
									   userInfo:[NSDictionary dictionaryWithObject:errMsg
																			forKey:@"description"]];
        [self _reportError:err];
        if(aoErr) *aoErr = err;
        return NO;
    }
    return YES;
}
- (id)executeScript:(NSString *)aSource error:(NSError **)aoErr
{
    int err;
    VALUE result = rb_eval_string_protect([aSource UTF8String], &err);
    if(err) {
        VALUE exception = rb_gv_get("$!");
        char *buffer = RSTRING(rb_obj_as_string(exception))->ptr;
        NSString *errMsg = [NSString stringWithUTF8String:buffer];
        NSError *err = [NSError errorWithDomain:@"ScriptError" 
										   code:0 
									   userInfo:[NSDictionary dictionaryWithObject:errMsg
																			forKey:@"description"]];
        [self _reportError:err];
        if(aoErr) *aoErr = err;
        
        return nil;
    }
    return [[[RBObject alloc] initWithRubyObject:result] autorelease];
}

#pragma mark - Delegate

- (void)_reportError:(NSError *)aError {
	if(_delegate) [_delegate scriptContext:self encounteredError:aError];
}
@end
