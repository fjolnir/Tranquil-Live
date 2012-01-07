// Processes audio from a specified input device
#import <portaudio.h>

@interface TAudioProcessor : NSObject 
@property(readonly) BOOL isRunning;
@property(readonly) float *frequencyBands;
@property(readwrite, assign, nonatomic) int numberOfFrequencyBands;
@property(readwrite, assign) float gain, smoothingBias;

+ (PaDeviceIndex)deviceIndexForName:(NSString *)aName;

- (id)initWithDevice:(PaDeviceIndex)aDevice;

- (void)start;
- (void)stop;

- (void)update;
- (float)magnitudeForBand:(int)aBand;
@end
