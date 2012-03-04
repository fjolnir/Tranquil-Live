# Audio stuff
$audio = AudioProcessor.alloc.init
def audio
    $audio
end

class AudioProcessor
    def open(aDeviceName)
        deviceId = AudioProcessor.deviceIndexForName(aDeviceName)
        if deviceId == -1
            p "No such device"
            return
        end
        openDevice(deviceId)
        start
    end

    def mag(aBand)
        magnitudeForBand(aBand)
    end
end

#audio.open "Built-in Microphone"
audio.open "Soundflower (2ch)"
_registerFrameCallback do
	$audio.update
    # printf "%+09.04f, %+09.04f, %+09.04f, %+09.04f\n", audio.magnitudeForBand(1), audio.magnitudeForBand(6), audio.magnitudeForBand(10), audio.magnitudeForBand(14)
end
