#import "TAudioPlugin.h"
#import "TAudioProcessor.h"
#include <portaudio.h>

@implementation TAudioPlugin
+ (BOOL)loadPlugin
{
	PaError err = paNoError;
	err = Pa_Initialize();
	assert(err == paNoError);
	
	NSLog(@"Load audio");
	NSLog(@"Devices: %d", Pa_GetDeviceCount());
	//NSLog(@"%@", [TAudioDevice allDevicesOfType:kTAudioDeviceInput]);
	TAudioProcessor *processor = [[TAudioProcessor alloc] initWithDevice:Pa_GetDefaultInputDevice()];
	[processor start];
	
	return YES;
}
@end
