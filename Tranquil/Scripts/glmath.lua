function vec2(aX,aY)
    return vec2_create(aX, aY)
end
function vec3(aX,aY,aZ)
    return vec3_create(aX, aY, aZ)
end
function vec4(aX,aY,aZ,aW)
    aW = aW or 1.0
    return vec4_create(aX, aY, aZ, aW)
end

function rgb(aR, aG, aB)
    aA = aA or 1.0
    return vec4_create(aR, aG, aB, aA)
end

function quat(aAngle,aX,aY,aZ)
	return quat_createf(aAngle, aX, aY, aZ)
end

--
-- Vector 2
--
_v2meta = getmetatable(GLMVec2_zero)
_v2meta["__add"] = function(a,b)
    if not (getmetatable(b).__luastructbridgesupportkeyname == "vec2_t") then error("Invalid type") end
	return vec2_add(a,b)
end
_v2meta["__sub"] = function(a,b)
    if not (getmetatable(b).__luastructbridgesupportkeyname == "vec2_t") then error("Invalid type") end
	return vec2_sub(a,b)
end
_v2meta["__mul"] = function(a,b)
    if not (getmetatable(b).__luastructbridgesupportkeyname == "vec2_t") then error("Invalid type") end
	return vec2_mul(a,b)
end
_v2meta["__div"] = function(a,b)
    if not (getmetatable(b).__luastructbridgesupportkeyname == "vec2_t") then error("Invalid type") end
	return vec2_div(a,b)
end
_v2meta["__eq"] = function(a,b)
    if not (getmetatable(b).__luastructbridgesupportkeyname == "vec2_t") then error("Invalid type") end
	return vec2_equals(a,b)
end

_v2idx = _v2meta["__index"]
_v2meta["__index"] = function(a,key)
    if key=="dot" then return function(b)
            if not (getmetatable(b).__luastructbridgesupportkeyname == "vec2_t") then error("Invalid type") end
            return vec2_dot(a,b)
        end
    elseif key=="magSquared" then return function()
            return vec2_magSquared(a)
        end
    elseif key=="mag" then return function()
            return vec2_mag(a)
        end
    elseif key=="dist" then return function(b)
            if not (getmetatable(b).__luastructbridgesupportkeyname == "vec2_t") then error("Invalid type") end
            return vec2_dist(a,b)
        end
    elseif key=="cross" then return function(b)
            if not (getmetatable(b).__luastructbridgesupportkeyname == "vec2_t") then error("Invalid type") end
            return vec2_cross(a,b)
        end
    elseif key=="negate" then return function()
            return vec2_negate(a)
        end
    elseif key=="floor" then return function()
            return vec2_floor(a)
        end
    elseif key=="normalize" then return function()
            return vec2_normalize(a)
        end
    else
        return _v2idx(a,key)
    end
end

--
-- Vector 3
--
_v3meta = getmetatable(GLMVec3_zero)
_v3meta["__add"] = function(a,b)
    if not (getmetatable(b).__luastructbridgesupportkeyname == "vec3_t") then error("Invalid type") end
	return vec3_add(a,b)
end
_v3meta["__sub"] = function(a,b)
    if not (getmetatable(b).__luastructbridgesupportkeyname == "vec3_t") then error("Invalid type") end
	return vec3_sub(a,b)
end
_v3meta["__mul"] = function(a,b)
    if not (getmetatable(b).__luastructbridgesupportkeyname == "vec3_t") then error("Invalid type") end
	return vec3_mul(a,b)
end
_v3meta["__div"] = function(a,b)
    if not (getmetatable(b).__luastructbridgesupportkeyname == "vec3_t") then error("Invalid type") end
	return vec3_div(a,b)
end
_v3meta["__eq"] = function(a,b)
    if not (getmetatable(b).__luastructbridgesupportkeyname == "vec3_t") then error("Invalid type") end
	return vec3_equals(a,b)
end

_v3idx = _v3meta["__index"]
_v3meta["__index"] = function(a,key)
    if key=="dot" then return function(b)
            if not (getmetatable(b).__luastructbridgesupportkeyname == "vec3_t") then error("Invalid type") end
            return vec3_dot(a,b)
        end
    elseif key=="magSquared" then return function()
            return vec3_magSquared(a)
        end
    elseif key=="mag" then return function()
            return vec3_mag(a)
        end
    elseif key=="dist" then return function(b)
            if not (getmetatable(b).__luastructbridgesupportkeyname == "vec3_t") then error("Invalid type") end
            return vec3_dist(a,b)
        end
    elseif key=="cross" then return function(b)
            if not (getmetatable(b).__luastructbridgesupportkeyname == "vec3_t") then error("Invalid type") end
            return vec3_cross(a,b)
        end
    elseif key=="negate" then return function()
            return vec3_negate(a)
        end
    elseif key=="floor" then return function()
            return vec3_floor(a)
        end
    elseif key=="normalize" then return function()
            return vec3_normalize(a)
        end
    else
        return _v3idx(a,key)
    end
end


--
-- Vector 4
--
_v4meta = getmetatable(GLMVec4_zero)
_v4meta["__add"] = function(a,b)
    if not (getmetatable(b).__luastructbridgesupportkeyname == "vec4_t") then error("Invalid type") end
	return vec4_add(a,b)
end
_v4meta["__sub"] = function(a,b)
    if not (getmetatable(b).__luastructbridgesupportkeyname == "vec4_t") then error("Invalid type") end
	return vec4_sub(a,b)
end
_v4meta["__mul"] = function(a,b)
    if not (getmetatable(b).__luastructbridgesupportkeyname == "vec4_t") then error("Invalid type") end
	return vec4_mul(a,b)
end
_v4meta["__div"] = function(a,b)
    if not (getmetatable(b).__luastructbridgesupportkeyname == "vec4_t") then error("Invalid type") end
	return vec4_div(a,b)
end
_v4meta["__eq"] = function(a,b)
    if not (getmetatable(b).__luastructbridgesupportkeyname == "vec4_t") then error("Invalid type") end
	return vec4_equals(a,b)
end

_v4idx = _v4meta["__index"]
_v4meta["__index"] = function(a,key)
    if key=="dot" then return function(b)
            if not (getmetatable(b).__luastructbridgesupportkeyname == "vec4_t") then error("Invalid type") end
            return vec4_dot(a,b)
        end
    elseif key=="magSquared" then return function()
            return vec4_magSquared(a)
        end
    elseif key=="mag" then return function()
            return vec4_mag(a)
        end
    elseif key=="dist" then return function(b)
            if not (getmetatable(b).__luastructbridgesupportkeyname == "vec4_t") then error("Invalid type") end
            return vec4_dist(a,b)
        end
    elseif key=="cross" then return function(b)
            if not (getmetatable(b).__luastructbridgesupportkeyname == "vec4_t") then error("Invalid type") end
            return vec4_cross(a,b)
        end
    elseif key=="negate" then return function()
            return vec4_negate(a)
        end
    elseif key=="floor" then return function()
            return vec4_floor(a)
        end
    elseif key=="normalize" then return function()
            return vec4_normalize(a)
        end
    else
        return _v4idx(a,key)
    end
end

--
-- Quaternion
--
_quatmeta = getmetatable(quat(0,0,0,0))
_quatmeta["__mul"] = function(a,b)
    type = getmetatable(b).__luastructbridgesupportkeyname
    if type == "quat_t" then
        return quat_multQuat(a,b)
    elseif type == "vec4_t" then
        return quat_rotatePoint(a,b)
    else
        error("Invalid type")
    end
end
_quatmeta["__eq"] = function(a,b)
    if not (getmetatable(b).__luastructbridgesupportkeyname == "quat_t") then error("Invalid type") end
	return quat_equals(a,b)
end

_quatidx = _quatmeta["__index"]
_quatmeta["__index"] = function(a,key)
    if key=="dot" then return function(b)
            if not (getmetatable(b).__luastructbridgesupportkeyname == "quat_t") then error("Invalid type") end
            return quat_dotProduct(a,b)
        end
    elseif key=="magSquared" then return function()
            return quat_magSquared(a)
        end
    elseif key=="mag" then return function()
            return quat_mag(a)
        end
    elseif key=="toOrtho" then return function()
            return quat_to_ortho(a)
        end
    elseif key=="slerp" then return function(t)
            return quat_slerp(a,t)
        end
    elseif key=="inverse" then return function()
            return quat_inverse(a)
        end
    elseif key=="computeW" then return function()
            return quat_computeW(a)
        end
    elseif key=="normalize" then return function()
            return quat_normalize(a)
        end
    else
        return _quatidx(a,key)
    end
end

--
-- 4x4 Matrix
--
_mat4meta = getmetatable(GLMMat4_zero)
_mat4meta["__mul"] = function(a,b)
    if not (getmetatable(b).__luastructbridgesupportkeyname == "mat4_t") then error("Invalid type") end
    return mat4_mul(a,b)
end
_mat4meta["__eq"] = function(a,b)
    if not (getmetatable(b).__luastructbridgesupportkeyname == "mat4_t") then error("Invalid type") end
	return mat4_equals(a,b)
end
