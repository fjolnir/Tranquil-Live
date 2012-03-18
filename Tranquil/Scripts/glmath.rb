Vec2 = vec2_create(0,0).class #OSX::vec2_t
Vec3 = vec3_create(0,0,0).class #OSX::vec3_t
Vec4 = vec4_create(0,0,0,0).class #OSX::vec4_t
cam = Scene.globalScene.camera
Quat = cam.orientation.class #OSX::quat_t
Mat4 = cam.matrix.class #OSX::mat4_t

def vec2(aX,aY)
    vec2_create(aX, aY)
end
def vec3(aX,aY,aZ)
    vec3_create(aX, aY, aZ)
end
def vec4(aX,aY,aZ,aW=1.0)
    vec4_create(aX, aY, aZ, aW)
end

def rgb(aR, aG, aB, aA=1.0)
    vec4_create(aR, aG, aB, aA)
end

def quat(aAngle,aX,aY,aZ)
	quat_createf(aAngle, aX, aY, aZ)
end

# Generic operators
class Quat
	def *(x)
		if x.is_a?(self.class)
			quat_multQuat(self, x)
		elsif x.is_a?(Vec4)
			quat_rotatePoint(self, x)
		else
			raise TypeError
		end
	end
	def to_mat4
		quat_to_mat4(self)
	end
	def to_quat
		mat4_to_quat(self)
	end
	def to_ortho
		quat_to_ortho(self)
	end
	def to_quat
		ortho_to_quat(self)
	end
	def magSquared
		quat_magSquared(self)
	end
	def mag
		quat_mag(self)
	end
	def computeW
		quat_computeW(self)
	end
	def normalize
		quat_normalize(self)
	end
	def rotatePoint(p)
		quat_rotatePoint(self,p)
	end
	def inverse
		quat_inverse(self)
	end
	def dotProduct(x)
		quat_dotProduct(self,x)
	end
	def slerp(x, t)
		quat_slerp(self,x,t)
	end
    def vec
        vec3(x,y,z)
    end
    def vec=(v)
        self.x = v.x
        self.y = v.y
        self.z = v.z
    end
    def scalar
        self.w
    end
    def scalar=(n)
        self.w=n
    end
end

class Mat4
	def self.scale(vec)
		mat4_create_scale(vec.x, vec.y, vec.z)
	end
	def self.translation(vec)
		mat4_create_translation(vec.x, vec.y, vec.z)
	end
	def self.rotation(angle, vec)
		mat4_create_rotation(angle, vec.x, vec.y, vec.z)
	end
	 def +(x)
		if x.is_a?(self.class)
			raise "todo"
        elsif other.is_a?(Numeric)
			raise "todo"
        else
		    raise TypeError
        end
    end
    def -(x)
		if x.is_a?(self.class)
			raise "todo"
        elsif other.is_a?(Numeric)
			raise "todo"
        else
		    raise TypeError
        end
    end
    def *(x)
        if x.is_a?(self.class)
            mat4_mul(self,x)
		elsif other.is_a?(Vec4)
			vec4_mul_mat4(x, self)
        elsif other.is_a?(Numeric)
			raise "todo"
        else
		    raise TypeError
        end
    end
    def /(x)
        if x.is_a?(self.class)
			raise "todo"
        elsif other.is_a?(Numeric)
			raise "todo"
        else
		    raise TypeError
        end
    end

end

class Vec2
    def +(x)
		if x.is_a?(self.class)
            vec2_add(self,x)
        elsif other.is_a?(Numeric)
            vec2_scalarAdd(x)
        else
		    raise TypeError
        end
    end
    def -(x)
		if x.is_a?(self.class)
            vec2_sub(self,x)
        elsif other.is_a?(Numeric)
            vec2_scalarSub(x)
        else
		    raise TypeError
        end
    end
    def *(x)
        if x.is_a?(self.class)
            vec2_mul(self,x)
        elsif other.is_a?(Numeric)
            vec2_scalarMul(x)
        else
		    raise TypeError
        end
    end
    def /(x)
        if x.is_a?(self.class)
            vec2_div(self,x)
        elsif other.is_a?(Numeric)
            vec2_scalarDiv(x)
        else
		    raise TypeError
        end
    end
    def dot(x)
		if x.is_a?(self.class)
			vec2_dot(self,x)
		else
			raise TypeError
		end
    end
    def magSquared(x)
		if x.is_a?(self.class)
			vec2_magSquared(self,x)
		else
			raise TypeError
		end
    end
    def mag(x)
		if x.is_a?(self.class)
			vec2_mag(self,x)
		else
			raise TypeError
		end
    end
    def dist(x)
		if x.is_a?(self.class)
			vec2_dist(self,x)
		else
			raise TypeError
		end
    end
    def negate
		if x.is_a?(self.class)
			vec2_negate(self)
		else
			raise TypeError
		end
    end
    def floor
		if x.is_a?(self.class)
			vec2_floor(self)
		else
			raise TypeError
		end
    end
end

class Vec3
    def +(x)
		if x.is_a?(self.class)
            vec3_add(self,x)
        elsif other.is_a?(Numeric)
            vec3_scalarAdd(x)
        else
		    raise TypeError
        end
    end
    def -(x)
		if x.is_a?(self.class)
            vec3_sub(self,x)
        elsif other.is_a?(Numeric)
            vec3_scalarSub(x)
        else
		    raise TypeError
        end
    end
    def *(x)
        if x.is_a?(self.class)
            vec3_mul(self,x)
        elsif other.is_a?(Numeric)
            vec3_scalarMul(x)
        else
		    raise TypeError
        end
    end
    def /(x)
        if x.is_a?(self.class)
            vec3_div(self,x)
        elsif other.is_a?(Numeric)
            vec3_scalarDiv(x)
        else
		    raise TypeError
        end
    end
    def dot(x)
		if x.is_a?(self.class)
			vec3_dot(self,x)
		else
			raise TypeError
		end
    end
    def magSquared(x)
		if x.is_a?(self.class)
			vec3_magSquared(self,x)
		else
			raise TypeError
		end
    end
    def mag(x)
		if x.is_a?(self.class)
			vec3_mag(self,x)
		else
			raise TypeError
		end
    end
    def dist(x)
		if x.is_a?(self.class)
			vec3_dist(self,x)
		else
			raise TypeError
		end
    end
    def cross(x)
		if x.is_a?(self.class)
			vec3_cross(self,x)
		else
			raise TypeError
		end
    end
    def negate
		if x.is_a?(self.class)
			vec3_negate(self)
		else
			raise TypeError
		end
    end
    def floor
		if x.is_a?(self.class)
			vec3_floor(self)
		else
			raise TypeError
		end
    end
end

class Vec4
    def +(x)
		if x.is_a?(self.class)
            vec4_add(self,x)
        elsif other.is_a?(Numeric)
            vec4_scalarAdd(x)
        else
		    raise TypeError
        end

    end
    def -(x)
		if x.is_a?(self.class)
            vec4_sub(self,x)
        elsif other.is_a?(Numeric)
            vec4_scalarSub(x)
        else
		    raise TypeError
        end
    end
    def *(x)
        if x.is_a?(self.class)
            vec4_mul(self,x)
        elsif other.is_a?(Numeric)
            vec4_scalarMul(x)
		elsif other.is_a?(mat4)
			vec4_mul_mat4(self, x)
        else
		    raise TypeError
        end
    end
    def /(x)
        if x.is_a?(self.class)
            vec4_div(self,x)
        elsif other.is_a?(Numeric)
            vec4_scalarDiv(x)
        else
		    raise TypeError
        end
    end
    def dot(x)
		if x.is_a?(self.class)
			vec4_dot(self,x)
		else
			raise TypeError
		end
    end
    def magSquared(x)
		if x.is_a?(self.class)
			vec4_magSquared(self,x)
		else
			raise TypeError
		end
    end
    def mag(x)
		if x.is_a?(self.class)
			vec4_mag(self,x)
		else
			raise TypeError
		end
    end
    def dist(x)
		if x.is_a?(self.class)
			vec4_dist(self,x)
		else
			raise TypeError
		end
    end
    def cross(x)
		if x.is_a?(self.class)
			vec4_cross(self,x)
		else
			raise TypeError
		end
    end
    def negate
		if x.is_a?(self.class)
			vec4_negate(self)
		else
			raise TypeError
		end
    end
    def floor
		if x.is_a?(self.class)
			vec4_floor(self)
		else
			raise TypeError
		end
    end
end
