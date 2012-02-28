def vec2(aX,aY)
	Vector2.vectorWithX(aX, y:aY)
end
def vec3(aX,aY,aZ)
	Vector3.vectorWithX(aX, y:aY, z:aZ)
end
def vec4(aX,aY,aZ,aW)
	Vector4.vectorWithX(aX, y:aY, z:aZ, w:aW)
end

def rgb(aR, aG, aB, aA=1.0)
    Vector4.vectorWithX(aR, y:aG, z:aB, w:aA)
end

def quat(aAngle,aX,aY,aZ)
	Quaternion.quaternionWithAngle(aAngle, x:aX, y:aY, z:aZ)
end

# Generic operators
module GLMathOperators
	def *(other)
		mul(other)
	end
	def +(other)
		add(other)
	end
	def -(other)
		sub(other)
	end
	def /(other)
		div(other)
	end
end
class Vector2
	include GLMathOperators
end
class Vector3
	include GLMathOperators
end
class Vector4
	include GLMathOperators
end
class Matrix3
	include GLMathOperators
end
class Matrix4
	include GLMathOperators
	def self.scale(vec)
		scaleWithX(vec.x, y:vec.y, z:vec.z)
	end
	def self.translation(vec)
		translationWithX(vec.x, y:vec.y, z:vec.z)
	end
	def self.rotation (angle, vec)
		rotationWithAngle(angle, x:vec.x, y:vec.y, z:vec.z)
	end
end
class Quaternion
	include GLMathOperators
end
