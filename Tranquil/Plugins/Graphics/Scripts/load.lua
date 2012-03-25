function buildCube(size)
    size = size or 1
    return scene:addObject(Cube:cubeWithSize_useVBO_(size, true))
end

function drawCube(size)
    size = size or 1
    return scene:addImmediateModeObject(Cube:cubeWithSize_useVBO_(size, false))
end

function buildSphere(radius, stacks, slices)
    radius = radius or 1
    stacks = stacks or 10
    slices = slices or 10
	return scene:addObject(Sphere:sphereWithRadius_stacks_slices_useVBO_(radius, stacks, slices, true))
end
function drawSphere(radius, stacks, slices)
    radius = radius or 1
    stacks = stacks or 10
    slices = slices or 10
	return scene:addImmediateModeObject(Sphere:sphereWithRadius_stacks_slices_useVBO_(radius, stacks, slices, false))
end

function buildPlane(cols, rows)
    cols = cols or 4
    rows = rows or 4
	return scene:addObject(Plane:planeWithCols_rows_useVBO(cols, rows, slices, true))
end
function drawPlane(cols, rows)
    cols = cols or 4
    rows = rows or 4
    return scene:addImmediateModeObject(Plane:planeWithCols_rows_useVBO(cols, rows, slices, false))
end

function buildParticles(count)
    count = count or 100
    return scene:addObject(Plane:particles_useVBO_(count, true))
end

function buildSuperShape(step)
    step = step or 0.05
    ret =  scene:addObject(SuperShape:alloc():init())
    ret:setStep(step)
    return ret
end