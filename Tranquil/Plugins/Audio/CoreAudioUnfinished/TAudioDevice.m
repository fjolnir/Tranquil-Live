#import "TAudioDevice.h"

@implementation TAudioDevice
@synthesize deviceId=_deviceId, isInput=_isInput, safetyOffset=_safetyOffset, bufferFrameSize=_bufferFrameSize, format=_format;
@dynamic isValid, channelCount, name;

+ (NSArray *)allDevicesOfType:(TAudioDeviceType)aType
{
	BOOL getInputs = aType == kTAudioDeviceInput;
	
	UInt32 propsize;
	
	__Verify_noErr(AudioHardwareGetPropertyInfo(kAudioHardwarePropertyDevices, &propsize, NULL));
	int deviceCount = propsize / sizeof(AudioDeviceID);	
	AudioDeviceID deviceIds[deviceCount];
	__Verify_noErr(AudioHardwareGetProperty(kAudioHardwarePropertyDevices, &propsize, deviceIds));
	
	NSMutableArray *out = [NSMutableArray arrayWithCapacity:deviceCount];
	for (int i = 0; i < deviceCount; ++i) {
		TAudioDevice *device = [[self alloc] initWithDeviceId:deviceIds[i] isInput:getInputs];
		if(device.channelCount > 0)
			[out addObject:device];
		else
			[device release];
	}
	return out;
}

- (id)initWithDeviceId:(AudioDeviceID)aDeviceId isInput:(BOOL)aIsInput
{
	self = [super init];
	if(!self) return nil;
	
	_deviceId = aDeviceId;
	_isInput = aIsInput;
	if(_deviceId == kAudioDeviceUnknown) {
		[self release];
		return nil;
	}
	
	UInt32 propSize = sizeof(UInt32);
	__Verify_noErr(AudioDeviceGetProperty(_deviceId, 0, _isInput, kAudioDevicePropertySafetyOffset, &propSize, &_safetyOffset));

	propSize = sizeof(UInt32);
	__Verify_noErr(AudioDeviceGetProperty(_deviceId, 0, _isInput, kAudioDevicePropertyBufferFrameSize, &propSize, &_bufferFrameSize));
	
	propSize = sizeof(UInt32);
	__Verify_noErr(AudioDeviceGetProperty(_deviceId, 0, _isInput, kAudioDevicePropertyStreamFormat, &propSize, &_format));
	
	return self;
}

- (void)setBufferFrameSize:(UInt32)aBufferFrameSize
{
	UInt32 propsize = sizeof(UInt32);
	__Verify_noErr(AudioDeviceSetProperty(_deviceId, NULL, 0, _isInput, kAudioDevicePropertyBufferFrameSize, propsize, &aBufferFrameSize));
	
	propsize = sizeof(UInt32);
	__Verify_noErr(AudioDeviceGetProperty(_deviceId, 0, _isInput, kAudioDevicePropertyBufferFrameSize, &propsize, &_bufferFrameSize));
}

- (NSInteger)channelCount
{
	OSStatus err;
	UInt32 propSize;
	int result = 0;
	
	err = AudioDeviceGetPropertyInfo(_deviceId, 0, _isInput, kAudioDevicePropertyStreamConfiguration, &propSize, NULL);
	if(err) return 0;
	
	AudioBufferList *bufList = (AudioBufferList *)malloc(propSize);
	err = AudioDeviceGetProperty(_deviceId, 0, _isInput, kAudioDevicePropertyStreamConfiguration, &propSize, bufList);
	if (!err) {
		for (UInt32 i = 0; i < bufList->mNumberBuffers; ++i) {
			result += bufList->mBuffers[i].mNumberChannels;
		}
	}
	free(bufList);
	
	return result;
}

- (NSString *)name
{
	int maxLen = 256;
	char buf[maxLen];
	__Verify_noErr(AudioDeviceGetProperty(_deviceId, 0, _isInput, kAudioDevicePropertyDeviceName, &maxLen, buf));
	
	return [NSString stringWithUTF8String:buf];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ <0x%x> %@", NSStringFromClass([self class]), self, self.name];
}
@end
