#import "Logger.h"

static Logger *_SharedInstance;

@implementation Logger
@synthesize delegate=_delegate;

+ (Logger *)sharedLogger
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _SharedInstance = [[self alloc] init];
    });
    return _SharedInstance;
}
- (void)log:(NSString *)aStr
{
    [_delegate logger:self receivedMessage:aStr];
}
@end
