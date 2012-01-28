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
		@audio = nil
	end
end

_registerFrameCallback do
	@audio.update unless @audio.nil?
end
