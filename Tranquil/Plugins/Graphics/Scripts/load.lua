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

objc_loadClass("Cube")
objc_loadClass("Plane")
objc_loadClass("Sphere")
objc_loadClass("SuperShape")

function buildCube(size)
	size = size or 1
	return scene:addObject_(Cube:cubeWithSize_useVBO_(size, true).id)
end

function drawCube(size)
	size = size or 1
	return scene:addImmediateModeObject_(Cube:cubeWithSize_useVBO_(size, false).id)
end

function buildSphere(radius, stacks, slices)
	radius = radius or 1
	stacks = stacks or 10
	slices = slices or 10
	return scene:addObject_(Sphere:sphereWithRadius_stacks_slices_useVBO_(radius, stacks, slices, true).id)
end
function drawSphere(radius, stacks, slices)
	radius = radius or 1
	stacks = stacks or 10
	slices = slices or 10
	return scene:addImmediateModeObject_(Sphere:sphereWithRadius_stacks_slices_useVBO_(radius, stacks, slices, false).id)
end

function buildPlane(cols, rows)
	cols = cols or 4
	rows = rows or 4
	return scene:addObject_(Plane:planeWithCols_rows_useVBO(cols, rows, slices, true).id)
end
function drawPlane(cols, rows)
	cols = cols or 4
	rows = rows or 4
	return scene:addImmediateModeObject_(Plane:planeWithCols_rows_useVBO(cols, rows, slices, false).id)
end

function buildParticles(count)
	count = count or 100
	return scene:addObject_(Plane:particles_useVBO_(count, true).id)
end

function buildSuperShape(step)
	step = step or 0.05
	ret =  scene:addObject_(SuperShape:new().id)
	ret:setStep_(step)
	return ret
end
