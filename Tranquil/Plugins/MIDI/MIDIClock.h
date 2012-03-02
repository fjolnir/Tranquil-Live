#import <Cocoa/Cocoa.h>
#import <AudioToolbox/CoreAudioClock.h>
#import <CoreMIDI/CoreMIDI.h>

//@class SMVirtualInputStream, MIDIClock;

typedef void (^MIDIClockCallback)(void);

@interface MIDIClock : NSObject {
	// CoreAudio clock
	CAClockRef _caClock;
	
	MIDIClientRef _clientRef;
	MIDIPortRef _inputPortRef;
	MIDIEndpointRef _srcPointRef;
	
	// The interval between clock pulses. Specified in beats (Default: 0.25 => 4 times per beat)
	CAClockBeats _pulseInterval;
	
	void (^_beatCheckBlock)(void);
		
	BOOL _running;
}
@property(readwrite, assign) CAClockBeats pulseInterval;
@property(readwrite, copy) MIDIClockCallback pulseCallback, startCallback, stopCallback;
@property(readonly) CAClockRef caClock;

+ (MIDIClock *)globalClock;

- (void)arm;
- (void)disarm;

// See CoreAudioClock.h for syncmodes
- (void)setSyncMode:(CAClockSyncMode)syncMode;
- (void)setMIDISyncSource:(NSString *)name;

// Returns the current beat number. (CAClockBeats = Float64)
- (CAClockBeats)currentBeat;
// Returns the current synced BPM
- (CAClockTempo)currentBPM;
@end
