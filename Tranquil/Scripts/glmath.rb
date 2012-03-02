def vec2(aX,aY)
	Vector2.vectorWithX(aX, y:aY)
end
def vec3(aX,aY,aZ)
	Vector3.vectorWithX(aX, y:aY, z:aZ)
end
def vec4(aX,aY,aZ,aW=1.0)
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
	    if other.is_a? self.class
		    mul(other)
		elsif other.is_a?(Numeric)
		    scalarMul(other)
		else
		    raise TypeError
		end
	end
	def +(other)
	    if other.is_a?(self.class)
            add(other)
        elsif other.is_a?(Numeric)
            scalarAdd(other)
		else
		    raise TypeError
        end
	end
	def -(other)
		if other.is_a?(self.class)
            sub(other)
        elsif other.is_a?(Numeric)
            scalarSub(other)
		else
		    raise TypeError
        end
	end
	def /(other)
	    if other.is_a?(self.class)
            div(other)
        elsif other.is_a?(Numeric)
            scalarDiv(other)
		else
		    raise TypeError
        end
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
