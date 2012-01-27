# Shorthands
@scene = TScene.globalScene

def vec2(aX,aY)
	Vector2.vectorWithX(aX, y:aY)
end
def vec3(aX,aY,aZ)
	Vector3.vectorWithX(aX, y:aY, z:aZ)
end
def vec4(aX,aY,aZ,aW)
	Vector4.vectorWithX(aX, y:aY, z:aZ, w:aW)
end
def quat(aAngle,aX,aY,aZ)
	Quaternion.quaternionWithAngle(aAngle, x:aX, y:aY, z:aZ)
end

# Setup
def _setup
	@scene.clearColor = vec4(0,0,0,1)
	
	@scene.camera.position = vec4(0, 0, 10, 1)
	@scene.camera.orientation = quat(0, 1, 0, 0)
	@scene.camera.updateMatrix
	
	light = Light.new
	light.position = vec4(0,2,0,1)
	light.ambientColor = vec4(0.2, 0.2, 0.2, 1)
	light.specularColor = vec4(0.1, 0.1, 0.1, 1)
	light.diffuseColor = vec4(0.7, 0.7, 0.7, 1)
	@scene.addLight light
end

# Audio stuff
@audio = nil
def startAudio(deviceName)
	return unless @audio.nil?
	deviceId = TAudioProcessor.deviceIndexForName(deviceName)
	if deviceId == -1
		p "No such device"
		return
	end
	@audio = TAudioProcessor.alloc.initWithDevice(deviceId)
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

# Frame callback
@userFrameCallback = nil
def _frameCallback
	@audio.update unless @audio.nil?
	@userFrameCallback.call unless @userFrameCallback.nil?
end

def everyFrame(&callback)
	@userFrameCallback = callback
end