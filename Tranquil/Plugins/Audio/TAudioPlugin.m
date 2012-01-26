#import "TAudioPlugin.h"
#import "TAudioProcessor.h"
#import "TScriptContext.h"
#include <portaudio.h>
/*#include <lua.h>
#include <lauxlib.h>

// The script can only access a single processor at a time
static TAudioProcessor *_GlobalProcessor = nil;

static int lua_audio_stop(lua_State *aState)
{
	if(_GlobalProcessor) {
		[_GlobalProcessor stop];
		[_GlobalProcessor release];
		_GlobalProcessor = nil;
	}
	return 0;
}

static int lua_audio_start(lua_State *aState)
{
	// Get the device id off the stack
	int deviceId = luaL_checkint(aState, 1);
	
	if(!_GlobalProcessor) {
		_GlobalProcessor = [[TAudioProcessor alloc] initWithDevice:deviceId];
		if(!_GlobalProcessor)
			luaL_error(aState, "Couldn't open audio device (id: %d)", deviceId);
		[_GlobalProcessor start];
		lua_pushboolean(aState, _GlobalProcessor != nil);
	} else
		lua_pushboolean(aState, 1);
	
	return 1;
}

static int lua_audio_setNumberOfBands(lua_State *aState)
{
	int count = luaL_checkint(aState, 1);
	if(_GlobalProcessor)
		_GlobalProcessor.numberOfFrequencyBands = count;
	
	return 0;
}

static int lua_audio_getBand(lua_State *aState)
{
	lua_Number result = 0.0;
	int bandIndex = luaL_checkint(aState, 1);
	if(_GlobalProcessor)
		result = [_GlobalProcessor magnitudeForBand:bandIndex];
	lua_pushnumber(aState, result);
	
	return 1;
}

static int lua__audio_updateSpectrum(lua_State *aState)
{
	if(_GlobalProcessor)
		[_GlobalProcessor update];
	return 0;
}*/

@implementation TAudioPlugin
+ (BOOL)loadPlugin
{
	assert(Pa_Initialize() == paNoError);
//	Class TScriptContext = NSClassFromString(@"TScriptContext");
/*	lua_State *state = [TScriptContext sharedContext].luaState;
	lua_register(state, "audio_start", &lua_audio_start);
	lua_register(state, "audio_stop", &lua_audio_stop);
	lua_register(state, "audio_setNumberOfBands", &lua_audio_setNumberOfBands);
	lua_register(state, "audio_getBand", &lua_audio_getBand);
	lua_register(state, "_audio_updateSpectrum", &lua__audio_updateSpectrum);
	*/
	return YES;
}
@end
