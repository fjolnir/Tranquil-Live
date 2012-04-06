ffi.cdef([[
typedef struct _Vertex_t {
    vec3_t position;
    vec3_t normal;
    vec4_t color;
    vec2_t texCoord;
    GLMFloat size;
    GLMFloat shininess;
} Vertex_t;
]])

Cube = objc.Cube
Plane = objc.Plane
Sphere = objc.Sphere
SuperShape = objc.SuperShape

-- Add a map method to the primitives (It's faster to do this inside lua than to pass a lua function to a c function and
-- iterate there)
local function map(prim, lambda)
    local numV = prim:vertexCount()
    local verts = prim:vertices()
    for i=0, numV-1 do
        lambda(i, verts[i])
    end
end

-- Rather than add it as a real method, we just inject it into the method cache
-- This saves us the back and forth C<->Lua calls
objc.instanceMethodCache["Cube"] = objc.instanceMethodCache["Cube"] or {}
objc.instanceMethodCache["Sphere"] = objc.instanceMethodCache["Sphere"] or {}
objc.instanceMethodCache["Plane"] = objc.instanceMethodCache["Plane"] or {}
objc.instanceMethodCache["Particles"] = objc.instanceMethodCache["Particles"] or {}

objc.instanceMethodCache["Cube"]["map_"] = map
objc.instanceMethodCache["Sphere"]["map_"] = map
objc.instanceMethodCache["Plane"]["map_"] = map
objc.instanceMethodCache["Particles"]["map_"] = map

function buildCube(size)
	size = size or 1
	return scene:addObject_(Cube:cubeWithSize_useVBO_(size, true))
end

function drawCube(size)
	size = size or 1
	return scene:addImmediateModeObject_(Cube:cubeWithSize_useVBO_(size, false))
end

function buildSphere(radius, stacks, slices)
	radius = radius or 1
	stacks = stacks or 10
	slices = slices or 10
	return scene:addObject_(Sphere:sphereWithRadius_stacks_slices_useVBO_(radius, stacks, slices, true))
end
function drawSphere(radius, stacks, slices)
	radius = radius or 1
	stacks = stacks or 10
	slices = slices or 10
	return scene:addImmediateModeObject_(Sphere:sphereWithRadius_stacks_slices_useVBO_(radius, stacks, slices, false))
end

function buildPlane(cols, rows)
	cols = cols or 4
	rows = rows or 4
	return scene:addObject_(Plane:planeWithCols_rows_useVBO(cols, rows, true))
end
function drawPlane(cols, rows)
	cols = cols or 4
	rows = rows or 4
	return scene:addImmediateModeObject_(Plane:planeWithCols_rows_useVBO(cols, rows, false))
end

function buildParticles(count)
	count = count or 100
	return scene:addObject_(Particles:particles_useVBO_(count, false))
end

function buildSuperShape(step)
	step = step or 0.05
	local ret =  scene:addObject_(SuperShape:new())
	ret:setStep_(step)
	return ret
end
