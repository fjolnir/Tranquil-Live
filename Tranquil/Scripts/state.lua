objc_loadClass("NSMutableArray")
_objectStack = NSMutableArray.array()

-- Returns the current state object, be it the scene state or of an object in it.
function currState()
    if _objectStack.count() > 0 then
        return _objectStack.lastObject().state()
    else
        return scene.currentState()
    end
end

-- Creates a copy of the current scene state and makes it the current state for the duration of the passed block
function pushState(lambda)
	scene.pushState()
	lambda()
	scene.popState()
end

-- Makes the state manipulation functions apply to the state of the passed primitive
function withPrimitive(primitive, lambda)
	_objectStack.addObject_(primitive)
	lambda()
	_objectStack.removeLastObject()
end

function scale(vec)
    local state = currState()
	state.setTransform_(state.transform() * mat4_create_scale(vec.x,vec.y,vec.z))
end
function translate(vec)
    local state = currState()
	state.setTransform_(state.transform() * mat4_create_translation(vec.x,vec.y,vec.z))
end
function rotate(angle, vec)
    local state = currState()
	state.setTransform_(state.transform() * mat4_create_rotation(angle, vec.x,vec.y,vec.z))
end
function color(color)
	currState().setColor_(color)
end
