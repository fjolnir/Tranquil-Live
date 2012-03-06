@class Logger;
@protocol LoggerDelegate
- (void)logger:(Logger *)aLogger receivedMessage:(NSString *)aMessage;
@end

@interface Logger : NSObject
@property(readwrite, assign, nonatomic) id<LoggerDelegate> delegate;

+ (Logger *)sharedLogger;
- (void)log:(NSString *)aStr;
@end
