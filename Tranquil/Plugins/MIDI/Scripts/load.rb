def midi
    MIDIClock.globalClock
end

class MIDIClock
    def syncSource=(aSource)
        self.setMIDISyncSource aSource
    end
end

#midi.syncSource = "IAC Driver Bus 1"
#midi.arm
#midi.pulseCallback = -> {
    #p midi.currentBeat
    #p midi.currentBPM
#}