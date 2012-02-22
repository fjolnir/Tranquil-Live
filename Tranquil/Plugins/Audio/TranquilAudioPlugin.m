#import "TranquilAudioPlugin.h"
#import "AudioProcessor.h"
#include <portaudio.h>
#import <TranquilCore/TranquilCore.h>

@implementation TranquilAudioPlugin
+ (BOOL)loadPlugin
{
	assert(Pa_Initialize() == paNoError);
//	Class ScriptContext = NSClassFromString(@"ScriptContext");
/*	lua_State *state = [ScriptContext sharedContext].luaState;
	lua_register(state, "audio_start", &lua_audio_start);
	lua_register(state, "audio_stop", &lua_audio_stop);
	lua_register(state, "audio_setNumberOfBands", &lua_audio_setNumberOfBands);
	lua_register(state, "audio_getBand", &lua_audio_getBand);
	lua_register(state, "_audio_updateSpectrum", &lua__audio_updateSpectrum);
	*/
	return YES;
}
@end
