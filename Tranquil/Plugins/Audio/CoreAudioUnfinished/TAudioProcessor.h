// Processes audio from a specified input device

@class TAudioDevice;

@interface TAudioProcessor : NSObject
@property(readonly) TAudioDevice *inputDevice;
@property(readonly) BOOL isRunning;

- (id)initWithInputDevice:(TAudioDevice *)aInputDevice;
- (void)start;
- (void)stop;
@end
