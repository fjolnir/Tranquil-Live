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
	currentState.transform *= Matrix4.scale(vec)
end
def translate(vec)
	currentState.transform *= Matrix4.translation(vec)
end
def rotate(angle, vec)
	currentState.transform *= Matrix4.rotation(vec)
end
def color(color)
	currentState.color = color
end
