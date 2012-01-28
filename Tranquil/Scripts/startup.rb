$LOAD_PATH.push File.dirname(__FILE__)
require "glmath"

# Shorthands
@scene = Scene.globalScene


@currentState = nil
def currentState
	@currentState || @scene.currentState
end
def pushState
	@scene.pushState
	yield
	@scene.popState
end

def withState(state)
	@currentState = state
	yield
	@currentState = nil
end

def scale(vec)
	currentState.transform *= Matrix4.scaleWithX(vec.x, y:vec.y, z:vec.z)
end
def translate(vec)
	currentState.transform *= Matrix4.translationWithX(vec.x, y:vec.y, z:vec.z)
end
def rotate(angle, vec)
	currentState.transform *= Matrix4.rotationWithAngle(angle, x:vec.x, y:vec.y, z:vec.z)
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

# Frame callback
@userFrameCallback = nil
def _frameCallback
	@audio.update unless @audio.nil?
	@userFrameCallback.call unless @userFrameCallback.nil?
end

def everyFrame(&callback)
	@userFrameCallback = callback
end
