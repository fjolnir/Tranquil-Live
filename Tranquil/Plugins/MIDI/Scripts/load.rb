def midi
    MIDIClock.globalClock
end

class MIDIClock
    def syncSource=(aSource)
        self.setMIDISyncSource aSource
    end
    
    def didStart
        @onStart.call unless @onStart.nil?
    end
    def didPulse
        @onPulse.call unless @onPulse.nil?
    end
    def didStop
        @onStop.call unless @onStop.nil?
    end
        
    def onStart(&blk)
        @onStart = blk
    end
    def onPulse(&blk)
        @onPulse = blk
    end
    def onStop(&blk)
        @onStop = blk
    end
end

midi.syncSource = "IAC Driver Bus 1"
midi.arm