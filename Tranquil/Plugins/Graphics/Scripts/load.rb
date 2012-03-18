def buildCube(size=1)
	scene.addObject Cube.objc_send(:cubeWithSize,size, :useVBO,true)
end
def drawCube(size=1)
	scene.addImmediateModeObject Cube.objc_send(:cubeWithSize,size, :useVBO,false)
end

def buildSphere(radius=1, stacks=10, slices=10)
	scene.addObject Sphere.objc_send(:sphereWithRadius,radius, :stacks,stacks, :slices,slices, :useVBO,true)
end
def drawSphere(radius=1, stacks=10, slices=10)
	scene.addImmediateModeObject Sphere.objc_send(:sphereWithRadius,radius, :stacks,stacks, :slices,slices, :useVBO,false)
end

def buildPlane(subdivs=vec2(4,4))
    raise TypeError unless subdivs.is_a?(Vector2)
	scene.addObject Plane.objc_send(:planeWithSubdivisions,subdivs, :useVBO,true)
end
def drawPlane(subdivs=vec2(4,4))
    raise TypeError unless subdivs.is_a?(Vector2)
	scene.addImmediateModeObject Plane.objc_send(:planeWithSubdivisions,subdivs, :useVBO,false)
end

def buildParticles(count=100)
    scene.addObject Particles.objc_send(:particles,count, :useVBO,true)
end

