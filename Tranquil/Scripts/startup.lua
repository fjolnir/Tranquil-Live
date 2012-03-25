LuaCocoa.import("GLMath")
LuaCocoa.import("TranquilCore")
LuaCocoa.import("OpenGL")

-- Add math functions/constants to the global namespace
for k,v in pairs(math) do _G[k] = v end

scene = Scene:globalScene()

require "glmath"
require "state"
require "mouse"
require "logging"

function _setup()
    scene:setClearColor(vec4(0,0,0,1))
    
    scene:camera():setPosition(vec4(0, 0, 5, 1))
 	scene:camera():setOrientation(quat(0, 1, 0, 0))
 	scene:camera():setFov(math.pi/2.0)
 	scene:camera():updateMatrix()
    
    light = Light:alloc():init()
    print(light.position)
 	light:setPosition(vec4(4,10,10,1))
 	light:setAmbientColor(vec4(0.2, 0.2, 0.2, 1))
 	light:setSpecularColor(vec4(0.1, 0.1, 0.1, 1))
 	light:setDiffuseColor(vec4(0.7, 0.7, 0.7, 1))
 	scene:addLight(light)
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