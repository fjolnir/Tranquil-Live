#import "MIDIClock.h"
#import <mach/mach_time.h>
#import <objc/objc-auto.h>

MIDIClock *sharedInstance;

@interface MIDIClock ()
- (void)_clockListener:(CAClockMessage)message parameter:(const void *)param;
- (void)_receivedClockPulseWithTimestamp:(MIDITimeStamp)aTimestamp;
@end

static void MIDIInputProc(const MIDIPacketList *pktlist, void *readProcRefCon, void *srcConnRefCon);
static void clockListener(void *userData, CAClockMessage message, const void *param);
@implementation MIDIClock
@synthesize pulseInterval=_pulseInterval, caClock=_caClock, pulseCallback=_pulseCallback, startCallback=_startCallback, stopCallback=_stopCallback;

+ (MIDIClock *)globalClock
{
	@synchronized(self) {
		if(!sharedInstance)
			sharedInstance = [[self alloc] init];
	}
	return sharedInstance;
}

- (id)init
{
	if(!(self = [super init]))
		return nil;
		
	OSErr err = 0;
	
	NSString *clientName = @"Tranquil";
	err = MIDIClientCreate((CFStringRef)clientName, NULL, NULL, &_clientRef);
	if (err != noErr)
		NSLog(@"MIDIClientCreate err = %d", err);
	
	[self setMIDISyncSource:nil];	
	
	
	// Set up the CoreAudio Clock
	CAClockNew(0, &_caClock);
	
	CAClockAddListener(_caClock, clockListener, self);
		
	CAClockTimebase timebase = kCAClockTimebase_HostTime;
	err = CAClockSetProperty(_caClock, kCAClockProperty_InternalTimebase, sizeof(CAClockTimebase), &timebase);
	if(err)
		NSLog(@"Error setting clock timebase");
	
	// Enable MIDI syncing by default
	[self setSyncMode:kCAClockSyncMode_MIDIClockTransport];

	
	UInt32 SMPTEType = kSMPTETimeType24;
	err = CAClockSetProperty(_caClock, kCAClockProperty_SMPTEFormat, sizeof(CAClockSMPTEFormat), &SMPTEType);
	if(err)
		NSLog(@"Error setting clock SMPTE type");
	
	// Create a midi port
	NSString *inputPortName = @"Tranquil in";
	err = MIDIInputPortCreate(_clientRef, (CFStringRef)inputPortName, 
														MIDIInputProc, self, &_inputPortRef);
	if (err != noErr) {
		NSLog(@"MIDIInputPortCreate err = %d", err);
	}
	
	// Connect the endpoint to our port
	err = MIDIPortConnectSource(_inputPortRef, _srcPointRef, NULL);
	if (err)
		NSLog(@"MIDIPortConnectSource err = %d", err);
		
	// Not running at the start now are we?
	_running = NO;
	
	_pulseInterval = 0.25; // default to 1/4
	
	return self;
}


#pragma mark -

- (void)arm
{
	// Arm the clock and go!
	OSErr err = 0;
	err = CAClockArm(_caClock);
	if(err)
		NSLog(@"Couldn't arm clock!");
}
- (void)disarm
{
	OSErr err = 0;
	err = CAClockDisarm(_caClock);
	if(err)
		NSLog(@"Couldn't disarm clock!");
}

- (void)setSyncMode:(CAClockSyncMode)syncMode
{
	OSErr err;
	err = CAClockSetProperty(_caClock, kCAClockProperty_SyncMode, sizeof(CAClockSyncMode), &syncMode);
	if(err)
		NSLog(@"Error setting clock syncmode");	
}
- (void)setMIDISyncSource:(NSString *)name
{
	OSErr err;
	CFStringRef srcDisplayName;
	unsigned numberOfSources = MIDIGetNumberOfSources();
	if(numberOfSources == 0) {
		NSLog(@"No MIDI sources found!");
		return;
	}
	
	// if no source name is passed, just use the first one
	MIDIEndpointRef currPoint;
	if(!name) {
		_srcPointRef = MIDIGetSource(0);
		return;
	}
	
	currPoint = (MIDIEndpointRef)NULL;
	for(int i = 0; i < numberOfSources; ++i) {
		currPoint = MIDIGetSource(i);
		err = MIDIObjectGetStringProperty(currPoint, kMIDIPropertyDisplayName, &srcDisplayName);
		if (err) 
			NSLog(@"MIDI Get sourceName err = %d", err);
				
		if([(NSString *)srcDisplayName isEqualToString:name]) {
			// Tell the CoreAudio clock to use the source
			_srcPointRef = currPoint;
			err = CAClockSetProperty(_caClock, kCAClockProperty_SyncSource, sizeof(_srcPointRef), &_srcPointRef);
			if(err)
				NSLog(@"Error setting clock midi sync source %d", err);	
			NSLog(@"connect = %@", srcDisplayName);
            CFRelease(srcDisplayName);
			break;
		}
		CFRelease(srcDisplayName);
	}
	// If we dont find the wanted one fall back on the first one
	if(!currPoint)
		_srcPointRef = MIDIGetSource(0);
}

#pragma mark - Status query methods

- (CAClockBeats)currentBeat
{
	CAClockTime beatTime;
	CAClockGetCurrentTime(_caClock, kCAClockTimeFormat_Beats, &beatTime);
	
	return beatTime.time.beats;
}

- (CAClockTempo)currentBPM
{
	CAClockTempo tempo; // Internal tempo
	CAClockTime  timestamp;
	CAClockGetCurrentTempo(_caClock, &tempo, &timestamp);
	// We have to multiply the internal BPM with the playback rate to get the actual playback BPM
	Float64 playrate;
	CAClockGetPlayRate(_caClock, &playrate);
	tempo *= playrate; // The synced tempo
	
	return tempo;
}

#pragma mark -
// CoreAudio Clock handling

// Receives status change notifications from the CoreAudio Clock
- (void)_clockListener:(CAClockMessage)message parameter:(const void *)param {
    static BOOL didRegisterWithCollector = NO;
	// Register the audio thread with the garbage collector
    if(!didRegisterWithCollector) {
    	objc_registerThreadWithCollector();
        didRegisterWithCollector = YES;
    }
	
	switch (message) {
		case kCAClockMessage_Started:
			NSLog(@"Clock started");
			_running = YES;            
            if(_startCallback)
                _startCallback();
			break;
		case kCAClockMessage_Stopped:
			NSLog(@"Clock stopped");
			_running = NO;
            if(_stopCallback)
                _stopCallback();
			break;
		case kCAClockMessage_Armed:
			NSLog(@"Clock armed");
			break;
		case kCAClockMessage_Disarmed:
			NSLog(@"Clock disarmed");
			break;
		case kCAClockMessage_WrongSMPTEFormat:
			NSLog(@"Clock received wrong SMPTE format");
			break;
		case kCAClockMessage_StartTimeSet:
			NSLog(@"Clock start time set");
			break;
		default: {
            CFStringRef str = UTCreateStringForOSType(message);
			NSLog(@"Unknown clock message received: %@", [(NSString *)str autorelease]);
            CFRelease(str); }
			break;
	}
}

- (void)_receivedClockPulseWithTimestamp:(MIDITimeStamp)aTimestamp
{
    if(_running && _pulseCallback)
        dispatch_async(dispatch_get_main_queue(), _pulseCallback);
}


#pragma mark -
// Singleton stuff
+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (sharedInstance == nil) {
			sharedInstance = [super allocWithZone:zone];
			return sharedInstance;  // assignment and return on first allocation
		}
	}
	return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (void)finalize
{
	OSStatus err;
	
	err = MIDIPortDisconnectSource(_inputPortRef, _srcPointRef);
	if (err != noErr) NSLog(@"MIDIPortDisconnectSource Err"); 
	err = MIDIPortDispose(_inputPortRef);
	if (err != noErr) NSLog(@"MIDIPortDispose Err");
	err = MIDIClientDispose(_clientRef);
	if (err != noErr) NSLog(@"MIDIClientDispose Err");
	
	err = CAClockDisarm(_caClock);
	if (err != noErr) NSLog(@"clock disarm Err");
	err = CAClockDispose(_caClock);
	if (err != noErr) NSLog(@"CAClockDispose err");
    
    [super finalize];
}
@end

static void MIDIInputProc(const MIDIPacketList *pktlist, void *readProcRefCon, void *srcConnRefCon)
{
    static BOOL didRegisterWithCollector = NO;
	// Register the audio thread with the garbage collector
    if(!didRegisterWithCollector) {
    	objc_registerThreadWithCollector();
        didRegisterWithCollector = YES;
    }
    
	// Make a pointer to the first packet
	MIDIPacket *packet = (MIDIPacket *)&(pktlist->packet[0]);
	UInt32 packetCount = pktlist->numPackets;
	
	for (NSInteger i = 0; i < packetCount; i++) {
//        NSLog(@"--%lld %d", packet->timeStamp, packet->length);
//        NSLog(@"0x%x %x %x %x", packet->data[0], packet->data[1], packet->data[2], packet->data[3]);
        
        // If it's a clock message, handle it
        if(packet->data[0] == 0xf8)
            [(id)readProcRefCon _receivedClockPulseWithTimestamp:packet->timeStamp];

		// Onto the next packet
		packet = MIDIPacketNext(packet);
	}
}

// Just forwards the message to the instance method
static void clockListener(void *userData, CAClockMessage message, const void *param)
{
	[(id)userData _clockListener:message parameter:param];
}