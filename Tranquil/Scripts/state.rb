@objectStack = []

# Returns the current state object, be it the scene state or of an object in it.
def currState
	o = @objectStack.last
	o.nil? ? scene.currentState : o.state
end

# Creates a copy of the current scene state and makes it the current state for the duration of the passed block
def pushState
	scene.pushState
	yield
	scene.popState
end

# Makes the state manipulation functions apply to the state of the passed primitive
def withPrimitive(primitive)
	@objectStack.push primitive
	yield
	@objectStack.pop
end

def scale(vec)
	currState.transform *= Matrix4.scale(vec)
end
def translate(vec)
	currState.transform *= Matrix4.translation(vec)
end
def rotate(angle, vec)
	currState.transform *= Matrix4.rotation(angle, vec)
end
def color(color)
	currState.color = color
end
