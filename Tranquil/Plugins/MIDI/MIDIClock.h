#import <Cocoa/Cocoa.h>
#import <AudioToolbox/CoreAudioClock.h>
#import <CoreMIDI/CoreMIDI.h>

@interface MIDIClock : NSObject {
	CAClockRef _caClock;
	
	MIDIClientRef _clientRef;
	MIDIPortRef _inputPortRef;
	MIDIEndpointRef _srcPointRef;
	
	void (^_beatCheckBlock)(void);
		
	BOOL _running;
}
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
