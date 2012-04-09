function mapToSphere(windowCoord)
	local viewport = Camera:viewportSize()
	local p = vec3(2.0*windowCoord.x/viewport.z - 1.0, 2.0*windowCoord.y/viewport.w - 1.0, 0)

	mag = p.x^2 + p.y^2

	if mag > 1.0 then
		local scale = 1.0 / sqrt(mag)
		p.x = p.x*scale
		p.y = p.y*scale
		p.z = 0
	else
		p.z = -sqrt(1.0 - mag)
	end
	return p
end


local _lastMouseLoc
local _clickOrientation

function _tranq_leftClick(x,y)
	_lastMouseLoc = vec2(x,y)
	_clickOrientation = scene:camera():orientation()
end

function _tranq_leftDrag(x,y)
	local cam = scene:camera()
	local last = mapToSphere(_lastMouseLoc)
	local mouseLoc = mapToSphere(vec2(x,y))

	local rotation = quat(0,0,0,0)
	rotation.vec = _clickOrientation:rotatePoint(last:cross(mouseLoc)) -- Axis of rotation
	rotation.scalar = last:dot(mouseLoc) -- Angle
	rotation = rotation:normalize()

	cam:setOrientation_(rotation*cam:orientation())
	cam:setPosition_(rotation:rotatePoint(cam:position()))
	
	cam:updateMatrix()
	_lastMouseLoc = vec2(x,y)
end
function _tranq_scroll(dx,dy)
	local cam = scene:camera()
	cam:setZoom_(cam:zoom() - dy/50.0)
	cam:updateMatrix()
end

function _tranq_resetCam()
	scene:camera():setPosition_(vec3(0, 0, 5))
	scene:camera():setOrientation_(quat(0, 1, 0, 0))
	scene:camera():setFov_(math.pi/2.0)
	scene:camera():updateMatrix()
end

