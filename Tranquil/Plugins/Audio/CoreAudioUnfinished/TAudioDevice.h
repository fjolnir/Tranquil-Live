#include <CoreAudio/CoreAudio.h>

typedef enum {
	kTAudioDeviceInput = 0,
	kTAudioDeviceOutput
} TAudioDeviceType;

@interface TAudioDevice : NSObject
@property(readwrite, assign) AudioDeviceID deviceId;
@property(readwrite, assign) bool isInput;
@property(readwrite, assign) UInt32	safetyOffset;
@property(readwrite, assign) UInt32	bufferFrameSize;
@property(readwrite, assign) AudioStreamBasicDescription format;
@property(readonly) BOOL isValid;
@property(readonly) NSInteger channelCount;
@property(readonly) NSString *name;

+ (NSArray *)allDevicesOfType:(TAudioDeviceType)aType;
- (id)initWithDeviceId:(AudioDeviceID)aDeviceId isInput:(BOOL)aIsInput;
@end
