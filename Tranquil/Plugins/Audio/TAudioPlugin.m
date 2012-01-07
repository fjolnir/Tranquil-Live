#import "TAudioPlugin.h"
#import "TAudioProcessor.h"
#include <portaudio.h>


@implementation TAudioPlugin
+ (BOOL)loadPlugin
{
	assert(Pa_Initialize() == paNoError);

	TAudioProcessor *processor = [[TAudioProcessor alloc] initWithDevice:[TAudioProcessor deviceIndexForName:@"Built-in Input"]];
	[processor start];
	
	return YES;
}
@end
