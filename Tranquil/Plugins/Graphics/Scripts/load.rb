def buildCube(size=1)
	scene.addObject Cube.alloc.initWithSize(size)
end
def drawCube(size=1)
	scene.addImmediateModeObject Cube.alloc.initWithSize(size)
end
def buildSphere(radius=1, stacks=10, slices=10)
	scene.addObject Sphere.alloc.initWithRadius(radius, stacks:stacks, slices:slices)
end
def drawSphere(radius=1, stacks=10, slices=10)
	scene.addImmediateModeObject Sphere.alloc.initWithRadius(radius, stacks:stacks, slices:slices)
end
def buildPlane(subdivs=vec2(4,4))
	scene.addObject Plane.alloc.initWithSubdivisions(subdivs)
end
def drawPlane(subdivs=vec2(4,4))
	scene.addImmediateModeObject Plane.alloc.initWithSubdivisions(subdivs)
end
