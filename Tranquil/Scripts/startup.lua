ffi = require("ffi")
C = ffi.C

---- Add math functions/constants to the global namespace
for k,v in pairs(math) do _G[k] = v end
Pi = pi -- It's not very obvious that 'pi' is a global constant

require "glmath"
objc = require "objc"
setmetatable(_G, {__index=objc})

Scene = objc.Scene
Camera = objc.Camera
Light = objc.Light

scene = Scene:globalScene()

ffi.cdef[[
uint64_t mach_absolute_time(void);
uint64_t AbsoluteToNanoseconds(uint64_t absoluteTime);
]]


function globalTime()
	return tonumber(C.AbsoluteToNanoseconds(C.mach_absolute_time()))/1000000000
end

local startTime = globalTime()
function time()
    return globalTime() - startTime
end

require "logging"
require "state"
require "mouse"

function _setup()
	scene:setClearColor_(vec4(0,0,0,1))
	
	scene:camera():setPosition_(vec4(0, 0, 5, 1))
	scene:camera():setOrientation_(quat(0, 1, 0, 0))
	scene:camera():setFov_(math.pi/2.0)
	scene:camera():updateMatrix()
	
	light = Light:new()
	light:setPosition_(vec4(4,10,10,1))
	light:setAmbientColor_(vec4(0.2, 0.2, 0.2, 1))
	light:setSpecularColor_(vec4(0.1, 0.1, 0.1, 1))
	light:setDiffuseColor_(vec4(0.7, 0.7, 0.7, 1))
	scene:addLight_(light)
end

_userFrameCallback = nil
_internalFrameCallbacks = {}

function everyFrame(lambda)
    _userFrameCallback = lambda
end

function _registerFrameCallback(lambda)
    table.insert(_internalFrameCallbacks, lambda)
end

function _tranq_handleFrame()
    for i,callback in ipairs(_internalFrameCallbacks) do
        callback()
    end
    if _userFrameCallback ~= nil then
        _userFrameCallback()
    end
end
