ffi.cdef([[
typedef struct _Vertex_t {
    vec4_t position;
    vec4_t normal;
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
local function map(prim, selector, lambda)
    local numV = prim.vertexCount()
    local verts = prim.vertices()
    for i=0, numV-1 do
        lambda(i, verts[i])
    end
end

Sphere.map_ = map
Cube.map_ = map
Plane.map_ = map

function buildCube(size)
	size = size or 1
	return scene.addObject_(Cube.cubeWithSize_useVBO_(size, true))
end

function drawCube(size)
	size = size or 1
	return scene.addImmediateModeObject_(Cube.cubeWithSize_useVBO_(size, false))
end

function buildSphere(radius, stacks, slices)
	radius = radius or 1
	stacks = stacks or 10
	slices = slices or 10
	return scene.addObject_(Sphere.sphereWithRadius_stacks_slices_useVBO_(radius, stacks, slices, true))
end
function drawSphere(radius, stacks, slices)
	radius = radius or 1
	stacks = stacks or 10
	slices = slices or 10
	return scene.addImmediateModeObject_(Sphere.sphereWithRadius_stacks_slices_useVBO_(radius, stacks, slices, false))
end

function buildPlane(cols, rows)
	cols = cols or 4
	rows = rows or 4
	return scene.addObject_(Plane.planeWithCols_rows_useVBO(cols, rows, slices, true))
end
function drawPlane(cols, rows)
	cols = cols or 4
	rows = rows or 4
	return scene.addImmediateModeObject_(Plane.planeWithCols_rows_useVBO(cols, rows, slices, false))
end

function buildParticles(count)
	count = count or 100
	return scene.addObject_(Plane.particles_useVBO_(count, true))
end

function buildSuperShape(step)
	step = step or 0.05
	ret =  scene.addObject_(SuperShape.new())
	ret.setStep_(step)
	return ret
end
