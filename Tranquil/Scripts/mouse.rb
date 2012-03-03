def mapToSphere(windowCoord)
	viewport = Camera.viewportSize
	p = vec3(2.0*windowCoord.x/viewport.z - 1.0, 2.0*windowCoord.y/viewport.w - 1.0, 0)
	# Map to sphere
	mag = p.x**2 + p.y**2
	if mag > 1.0
		scale = 1.0 / Math.sqrt(mag)
		p.x *= scale
		p.y *= scale
		p.z = 0
	else
		p.z = -Math.sqrt(1.0 - mag)
	end
    return p
end

class TranquilMouseObserver
	@@lastMouseLoc = vec2(0,0)
	def leftClick(pos)
		@@lastMouseLoc = mapToSphere(pos)
	end
    
	def leftDrag(pos)
		mouseLoc = mapToSphere(pos)

		cam = scene.camera
		rotation = Quaternion.new
		rotation.vec = @@lastMouseLoc.cross(mouseLoc) # Axis of rotation
		rotation.scalar = @@lastMouseLoc.dot(mouseLoc) # Angle
        #rotation = rotation.normalize    
        
        cam.orientation = rotation.mul(cam.orientation)
		cam.position = rotation.rotatePoint(cam.position)
		cam.updateMatrix
		@@lastMouseLoc = mouseLoc
	end
	def scroll(delta)
		cam = Scene.globalScene.camera;
		cam.zoom = [0.1, cam.zoom - delta.y/50.0].max
		cam.updateMatrix
	end
end
