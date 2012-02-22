# Audio stuff
@audio = nil
def startAudio(deviceName)
	return unless @audio.nil?
	deviceId = AudioProcessor.deviceIndexForName(deviceName)
	if deviceId == -1
		p "No such device"
		return
	end
	@audio = AudioProcessor.alloc.initWithDevice(deviceId)
	unless @audio.nil?
		@audio.start
	else
		p "Couldn't start audio"
	end
end

def stopAudio
	unless @audio.nil?
		@audio.stop
		@audio.close
		@audio = nil
	end
end

#startAudio "Built-in Microphone"
startAudio "Soundflower (2ch)"

_registerFrameCallback do
	@audio.update unless @audio.nil?
 #   printf "%+09.04f, %+09.04f, %+09.04f, %+09.04f\n", @audio.magnitudeForBand(1), @audio.magnitudeForBand(6), @audio.magnitudeForBand(10), @audio.magnitudeForBand(14)
end
