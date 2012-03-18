def mapToSphere(windowCoord)
	viewport = Camera.viewportSize
	p = vec3(2.0*windowCoord.x/viewport.z - 1.0, 2.0*windowCoord.y/viewport.w - 1.0, 0)
	# Map to sphere
	mag = p.x**2 + p.y**2
	if mag > 1.0
		scale = 1.0 / sqrt(mag)
		p.x *= scale
		p.y *= scale
		p.z = 0
	else
		p.z = -sqrt(1.0 - mag)
	end
    return p
end

class TranquilMouseObserver
	@lastMouseLoc = vec2(0,0)
	def leftClick(x,y)
		@lastMouseLoc = mapToSphere(vec2(x,y))
	end
    
	def leftDrag(x,y)
		mouseLoc = mapToSphere(vec2(x,y))
		cam = scene.camera
		rotation = quat(0,0,0,0)
		rotation.vec = @lastMouseLoc.cross(mouseLoc) # Axis of rotation
		rotation.scalar = @lastMouseLoc.dot(mouseLoc) # Angle
        rotation = rotation.normalize    
        
        cam.orientation = rotation * cam.orientation
		cam.position = rotation * cam.position
		cam.updateMatrix
		@lastMouseLoc = mouseLoc
	end
	def scroll(dx, dy)
		cam = scene.camera
		cam.zoom = cam.zoom - dy.floatValue/50.0
		cam.updateMatrix
	end
end
