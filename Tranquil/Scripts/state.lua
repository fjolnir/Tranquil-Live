_objectStack = NSMutableArray:array()

-- Returns the current state object, be it the scene state or of an object in it.
function currState()
    if _objectStack:count() > 0 then
        return _objectStack:lastObject()
    else
        return scene:currentState()
    end
end

-- Creates a copy of the current scene state and makes it the current state for the duration of the passed block
function pushState(lambda)
	scene:pushState()
	lambda()
	scene:popState()
end

-- Makes the state manipulation functions apply to the state of the passed primitive
function withPrimitive(primitive, lambda)
	_objectStack:addObject(primitive)
	lambda()
	_objectStack:removeLastObject()
end

function scale(vec)
    state = currState()
	state:setTransform(state:transform() * Mat4.scale(vec))
end
function translate(vec)
    state = currState()
	state:setTransform(state:transform() * Mat4.translation(vec))
end
function rotate(angle, vec)
    state = currState()
	state:setTransform(state:transform() * Mat4.rotation(angle, vec))
end
function color(color)
	currState():setColor(color)
end
