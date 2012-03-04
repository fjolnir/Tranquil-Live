#import <TranquilCore/TranquilCore.h>
#include <portaudio.h>
#import "TranquilAudioPlugin.h"
#import "AudioProcessor.h"

@implementation TranquilAudioPlugin
+ (BOOL)loadPlugin
{
	assert(Pa_Initialize() == paNoError);
	return YES;
}
@end
