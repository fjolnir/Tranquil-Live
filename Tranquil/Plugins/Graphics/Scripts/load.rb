def buildCube(size=1)
	scene.addObject Cube.cubeWithSize(size)
end
def drawCube(size=1)
	scene.addImmediateModeObject Cube.cubeWithSize(size)
end
def buildSphere(radius=1, stacks=10, slices=10)
	scene.addObject Sphere.objc_send(:sphereWithRadius,radius, :stacks,stacks, :slices,slices)
end
def buildParticles(count=100)
    scene.addObject Particles.particles(count)
end

def drawSphere(radius=1, stacks=10, slices=10)
	scene.addImmediateModeObject Sphere.objc_send(:sphereWithRadius,radius, :stacks,stacks, :slices,slices)
end
def buildPlane(subdivs=vec2(4,4))
    raise TypeError unless subdivs.is_a?(Vector2)
	scene.addObject Plane.planeWithSubdivisions(subdivs)
end
def drawPlane(subdivs=vec2(4,4))
    raise TypeError unless subdivs.is_a?(Vector2)
	scene.addImmediateModeObject Plane.planeWithSubdivisions(subdivs)
end


class PolyPrimitive
    def map
        (0...self.vertexCount).each do |i|
            self.vertices[i] = yield(i, self.vertices[i])
        end
    end
end