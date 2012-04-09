# Audio stuff
audio = AudioProcessor:alloc():init()

objc.addMethod(AudioProcessor, SEL("open:"), function(self, sel, aDeviceName)
	local deviceId = AudioProcessor:deviceIndexForName(aDeviceName)
	if deviceId == -1 then
		print("No such audio device")
		return false
	end
	self:openDevice(deviceId)
	self:start()
	return true
end, "B@:@")

objc.instanceMethodCache["AudioProcessor"] = objc.instanceMethodCache["AudioProcessor"] or {}
objc.instanceMethodCache["AudioProcessor"]["mag_"] = function(self, band)
	return self:magnitudeForBand(band)
end

--audio:open(NSStr("Built-in Microphone"))
audio:open(NSStr("Soundflower (2ch)"))
_registerFrameCallback(function()
	audio:update()
    -- printf "%+09.04f, %+09.04f, %+09.04f, %+09.04f\n", audio.magnitudeForBand(1), audio.magnitudeForBand(6), audio.magnitudeForBand(10), audio.magnitudeForBand(14)
end)
