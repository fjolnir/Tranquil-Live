-- Called at the end of each frame (beginning of the next)
_frameCallbacks = {}
function _frameCallback()
	for i,callback in ipairs(_frameCallbacks) do
		callback()
	end
end
function everyFrame(aCallback)
	_frameCallbacks[#_frameCallbacks + 1] = aCallback
end