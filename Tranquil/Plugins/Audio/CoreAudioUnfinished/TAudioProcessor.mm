#import "TAudioProcessor.h"
#import <CoreAudio/CoreAudio.h>
#import <AudioUnit/AudioUnit.h>
#import "CAStreamBasicDescription.h"
#import "TAudioDevice.h"

@interface TAudioProcessor () {
	AudioUnit _inputUnit;
	TAudioDevice *_inputDevice;
	AudioBufferList *_inputBuffer;
	Float64 _firstInputTime;
}

- (BOOL)_initAUHAL:(AudioDeviceID)aDevice;
- (BOOL)_enableInput;
- (BOOL)setInputDevice:(AudioDeviceID)aDeviceId;
- (void)_initCallback;
- (BOOL)_initBuffers;
- (OSStatus)_handleInputWithTimeStamp:(const AudioTimeStamp *)aTimeStamp 
						  actionFlags:(AudioUnitRenderActionFlags *)aoActionFlags
							busNumber:(UInt32)aBusNumber
					   numberOfFrames:(UInt32)aNumberOfFrames;
@end

static OSStatus InputProc(void *inRefCon,
								  AudioUnitRenderActionFlags *ioActionFlags,
								  const AudioTimeStamp *inTimeStamp,
								  UInt32 inBusNumber,
								  UInt32 inNumberFrames,
								  AudioBufferList * ioData)
{	
	TAudioProcessor *processor = (TAudioProcessor *)inRefCon;
	return [processor _handleInputWithTimeStamp:inTimeStamp
									actionFlags:ioActionFlags
									  busNumber:inBusNumber
								 numberOfFrames:inNumberFrames];
}


@implementation TAudioProcessor

@synthesize inputDevice=_inputDevice, isRunning=_isRunning;

- (OSStatus)_handleInputWithTimeStamp:(const AudioTimeStamp *)aTimeStamp 
						  actionFlags:(AudioUnitRenderActionFlags *)aoActionFlags
							busNumber:(UInt32)aBusNumber
					   numberOfFrames:(UInt32)aNumberOfFrames
{
	OSStatus err;
	if(_firstInputTime < 0.0)
		_firstInputTime = aTimeStamp->mSampleTime;
	
	//Get the new audio data
	err = AudioUnitRender(_inputUnit,
						  aoActionFlags,
						  aTimeStamp, 
						  aBusNumber,     
						  aNumberOfFrames, //# of frames requested
						  _inputBuffer);// Audio Buffer List to hold data
	NSLog(@"%d", *((int*)_inputBuffer->mBuffers[0].mData+1));
	__Verify_noErr(err);
	return err;
}

- (id)initWithInputDevice:(TAudioDevice *)aInputDevice
{
	self = [super init];
	if(!self) return nil;
	
	_isRunning = NO;
	_inputDevice = [aInputDevice retain];
	
	assert([self _initAUHAL:_inputDevice.deviceId]);
	assert([self _initBuffers]);
	
	return self;
}

- (void)start
{
	if(!_isRunning) {
		__Verify_noErr(AudioOutputUnitStart(_inputUnit));
		_firstInputTime = -1;
	}
}
- (void)stop
{
	if(_isRunning) {
		__Verify_noErr(AudioOutputUnitStop(_inputUnit));
		_firstInputTime = -1;
	}
}

- (BOOL)_initAUHAL:(AudioDeviceID)aDevice
{
	OSStatus err = noErr;
	
	Component comp;
	ComponentDescription desc;
	
	//There are several different types of Audio Units.
	//Some audio units serve as Outputs, Mixers, or DSP
	//units. See AUComponent.h for listing
	desc.componentType = kAudioUnitType_Output;
	
	//Every Component has a subType, which will give a clearer picture
	//of what this components function will be.
	desc.componentSubType = kAudioUnitSubType_HALOutput;
	
	//all Audio Units in AUComponent.h must use 
	//"kAudioUnitManufacturer_Apple" as the Manufacturer
	desc.componentManufacturer = kAudioUnitManufacturer_Apple;
	desc.componentFlags = 0;
	desc.componentFlagsMask = 0;
	
	//Finds a component that meets the desc spec's
	comp = FindNextComponent(NULL, &desc);
	if(comp == NULL) return NO;
	
	//gains access to the services provided by the component
	OpenAComponent(comp, &_inputUnit);  
	
	//AUHAL needs to be initialized before anything is done to it
	err = AudioUnitInitialize(_inputUnit);
	__Verify_noErr(err);
	
	assert([self _enableInput]);
	assert([self setInputDevice:aDevice]);
	[self _initCallback];
	
	err = AudioUnitInitialize(_inputUnit);
	
	return err == 0;
}

- (BOOL)_enableInput
{
	OSStatus err = noErr;
	UInt32 enableIO;
	
	///////////////
	//ENABLE IO (INPUT)
	//You must enable the Audio Unit (AUHAL) for input and disable output 
	//BEFORE setting the AUHAL's current device.
	
	//Enable input on the AUHAL
	enableIO = 1;
	err =  AudioUnitSetProperty(_inputUnit,
								kAudioOutputUnitProperty_EnableIO,
								kAudioUnitScope_Input,
								1, // input element
								&enableIO,
								sizeof(enableIO));
	__Verify_noErr(err);
	
	//disable Output on the AUHAL
	enableIO = 0;
	err = AudioUnitSetProperty(_inputUnit,
							   kAudioOutputUnitProperty_EnableIO,
							   kAudioUnitScope_Output,
							   0,   //output element
							   &enableIO,
							   sizeof(enableIO));
	return err == 0;

}

- (BOOL)setInputDevice:(AudioDeviceID)aDeviceId
{
	UInt32 size = sizeof(AudioDeviceID);
    OSStatus err = noErr;
	
	if(aDeviceId == kAudioDeviceUnknown) { //get the default input device if device is unknown  
		err = AudioHardwareGetProperty(kAudioHardwarePropertyDefaultInputDevice,
									   &size,  
									   &aDeviceId);
		__Verify_noErr(err);
	}
	
	[_inputDevice release];
	_inputDevice = [[TAudioDevice alloc] initWithDeviceId:aDeviceId isInput:YES];
	
	//Set the Current Device to the AUHAL.
	//this should be done only after IO has been enabled on the AUHAL.
    err = AudioUnitSetProperty(_inputUnit,
							   kAudioOutputUnitProperty_CurrentDevice, 
							   kAudioUnitScope_Global, 
							   0, 
							   &aDeviceId, 
							   sizeof(aDeviceId));
	__Verify_noErr(err);
	return err == 0;

}

- (void)_initCallback
{
	OSStatus err = noErr;
    AURenderCallbackStruct input;
	
    input.inputProc = InputProc;
    input.inputProcRefCon = self;
	
	//Setup the input callback. 
	err = AudioUnitSetProperty(_inputUnit, 
							   kAudioOutputUnitProperty_SetInputCallback, 
							   kAudioUnitScope_Global,
							   0,
							   &input, 
							   sizeof(input));
	__Verify_noErr(err);
}

- (BOOL)_initBuffers
{
	OSStatus err = noErr;
	UInt32 bufferSizeFrames, bufferSizeBytes, propertySize;
	
	
	propertySize = sizeof(bufferSizeFrames);
	err = AudioUnitGetProperty(_inputUnit, kAudioDevicePropertyBufferFrameSize, kAudioUnitScope_Global, 0, &bufferSizeFrames, &propertySize);
	bufferSizeBytes = bufferSizeFrames * sizeof(Float32);
	
	CAStreamBasicDescription inputStreamFormat;
	propertySize = sizeof(inputStreamFormat);
	err = AudioUnitGetProperty(_inputUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &inputStreamFormat, &propertySize);
	
	// We must get the sample rate of the input device and set it to the stream format of AUHAL
	Float64 sampleRate = 0;
	propertySize = sizeof(Float64);
	AudioDeviceGetProperty(_inputDevice.deviceId, 0, 1, kAudioDevicePropertyNominalSampleRate, &propertySize, &sampleRate);
	inputStreamFormat.mSampleRate = sampleRate;
	
	propertySize = sizeof(inputStreamFormat);
	err = AudioUnitSetProperty(_inputUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &inputStreamFormat, propertySize);
	__Verify_noErr(err);
	
	propertySize = offsetof(AudioBufferList, mBuffers[0]) + (sizeof(AudioBuffer) * inputStreamFormat.mChannelsPerFrame);
	
	// Allocate the input buffer
	_inputBuffer = (AudioBufferList *)malloc(propertySize);
	_inputBuffer->mNumberBuffers = inputStreamFormat.mChannelsPerFrame;
	
	for(int i = 0; i < _inputBuffer->mNumberBuffers; ++i) {
		_inputBuffer->mBuffers[i].mNumberChannels = 1;
		_inputBuffer->mBuffers[i].mDataByteSize = bufferSizeBytes;
		_inputBuffer->mBuffers[i].mData = malloc(bufferSizeBytes);
	}
	return YES;
}
@end
