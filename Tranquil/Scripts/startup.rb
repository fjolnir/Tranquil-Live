include Math

def scene
    Scene.globalScene
end

$LOAD_PATH.push File.dirname(__FILE__)
require "glmath"
require "state"
require "mouse"

# Setup
def _setup
	scene.clearColor = vec4(0,0,0,1)
	
	scene.camera.position = vec4(0, 0, 5, 1)
	scene.camera.orientation = quat(0, 1, 0, 0)
    scene.camera.fov = Math::PI/2.0
	scene.camera.updateMatrix
	
	light = Light.new
	light.position = vec4(0,10,0,1)
	light.ambientColor = vec4(0.2, 0.2, 0.2, 1)
	light.specularColor = vec4(0.1, 0.1, 0.1, 1)
	light.diffuseColor = vec4(0.7, 0.7, 0.7, 1)
	scene.addLight light
end

# Frame callback
@@userFrameCallback = nil
@@internalFrameCallbacks = []
# This is meant for use by plugins that need to perform operations on each frame
def _registerFrameCallback(&callback)
	@@internalFrameCallbacks.push callback
end

class TranquilFrameHandler
    def handleFrame
        @@internalFrameCallbacks.each { |c| c.call }
        @@userFrameCallback.call unless @@userFrameCallback.nil?
    end
end

def everyFrame(&callback)
	@@userFrameCallback = callback
end
