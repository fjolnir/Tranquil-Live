@objectStack = []
def currentState
	o = @objectStack.last 
	o.nil? ? @scene.currentState : o.state
end
def pushState
	@scene.pushState
	yield
	@scene.popState
end

def withPrimitive(primitive)
	@objectStack.push primitive
	yield
	@objectStack.pop
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

# Frame callback
@userFrameCallback = nil
@internalFrameCallbacks = []
def _frameCallback
	@audio.update unless @audio.nil?
	@userFrameCallback.call unless @userFrameCallback.nil?
end

def everyFrame(&callback)
	@userFrameCallback = callback
end
