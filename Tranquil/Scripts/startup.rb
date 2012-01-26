-- Called at the end of each frame (beginning of the next)

_errorDuringUserCallback = false
_prevUserFrameCallback = nil
_userFrameCallback = nil

function _frameCallback()
	_audio_updateSpectrum()
	if not pcall(_userFrameCallback) then
		_errorDuringUserCallback = true
		pcall(_prevUserFrameCallback)
	else
		_errorDuringUserCallback = false
	end
end

function everyFrame(aCallback)
	if not _errorDuringUserCallback then
		_prevUserFrameCallback = _userFrameCallback
	end
	_userFrameCallback = aCallback
end

-- Load the API
ffi = require("ffi")
C = ffi.C
ffi.cdef[[
	// Copied straight from GLMathTypes.h
	union _vec2_t {
		struct { float x; float y; };
		struct { float w; float h; };
		struct { float u; float v; };
	};
	typedef union _vec2_t vec2_t;

	union _vec3_t {
		struct { float x; float y; float z; };
		struct { float r; float g; float b; };
	};
	typedef union _vec3_t vec3_t;

	union _vec4_t {
		struct { float x; float y; float z; float w; };
		struct { float r; float g; float b; float a; };
	};
	typedef union _vec4_t vec4_t;
	
	union _mat4_t {
		struct {
			float m00, m01, m02, m03;
			float m10, m11, m12, m13;
			float m20, m21, m22, m23;
			float m30, m31, m32, m33;
		};
	};
	typedef union _mat4_t mat4_t;
	
	union _quat_t {
		struct { float x; float y; float z; float w; };
	};
	typedef union _quat_t quat_t;
	
	struct _matrix_stack_t {
		mat4_t *items;
		unsigned int capacity;
		unsigned int count;
	};
	typedef struct _matrix_stack_t matrix_stack_t;
	
	union _bezier_t {
		vec3_t controlPoints[4];
		vec3_t cp[4];
	};
	typedef union _bezier_t bezier_t;
	
	union _rect_t {
		struct { vec2_t o; vec2_t s; };
		struct { vec2_t origin; vec2_t size; };
		struct { float x; float y; float w; float h; };
	};
	typedef union _rect_t rect_t;
	
	// Vector functions
	vec4_t _vec4_create(float x, float y, float z, float w);
	vec4_t _vec4_add(const vec4_t v1, const vec4_t v2);
	vec4_t _vec4_sub(const vec4_t v1, const vec4_t v2);
	vec4_t _vec4_mul(const vec4_t v1, const vec4_t v2);
	vec4_t _vec4_div(const vec4_t v1, const vec4_t v2);
	float _vec4_dot(const vec4_t v1, const vec4_t v2);
	float _vec4_magSquared(const vec4_t v);
	float _vec4_mag(const vec4_t v);
	float _vec4_dist(const vec4_t v1, const vec4_t v2);
	vec4_t _vec4_scalarMul(const vec4_t v, float s);
	vec4_t _vec4_scalarDiv(const vec4_t v, float s);
	vec4_t _vec4_cross(const vec4_t v1, const vec4_t v2);
	vec4_t _vec4_negate(const vec4_t v);
	vec4_t _vec4_floor(vec4_t v);
	
	// Matrix functions
	mat4_t _mat4_mul(const mat4_t m1, const mat4_t m2);
	vec3_t _vec3_mul_mat4(const vec3_t v, const mat4_t m, bool isPoint);
	vec4_t _vec4_mul_mat4(const vec4_t v, const mat4_t m);
	mat4_t _mat4_inverse(const mat4_t m, bool *success_out);
	mat4_t _mat4_transpose(const mat4_t m);
	float _mat4_det(mat4_t m);
	
	bool _vec2_equals(const vec2_t v1, const vec2_t v2);
	bool _vec3_equals(const vec3_t v1, const vec3_t v2);
	bool _vec4_equals(const vec4_t v1, const vec4_t v2);
	bool _mat4_equals(const mat4_t m1, const mat4_t m2);
	bool _quat_equals(const quat_t q1, const quat_t q2);
]]

local vec4Meta = {
	__tostring = function(a) return "("..a.x..", "..a.y..", "..a.z..", "..a.w..")" end,
	__add = function(a,b) assert(ffi.istype(vec4, b)) return C._vec4_add(a,b) end,
	__sub = function(a,b) assert(ffi.istype(vec4, b)) return C._vec4_sub(a,b) end,
	__div = function(a,b)
		if     ffi.istype(vec4, b) then return C._vec4_div(a,b)
		elseif type(b)=="number"   then return C._vec4_scalarMul(a, b) end
	end,
	__mul = function(a,b)
		if     ffi.istype(vec4, b) then return C._vec4_mul(a,b)
		elseif ffi.istype(mat4, b) then return C._vec4_mul_mat4(a, b)
		elseif type(b)=="number"   then return C._vec4_scalarMul(a, b) end
	end,
	__unm = function(a) return C._vec4_neg(a) end,
	__eq  = function(a,b)
		if ffi.istype(vec4, b) then return C._vec4_equals(a,b)
		else return false end
	end,
	__len = function(a) return 4 end,
	__index = {
		floor = function(a) return C._vec4_floor(a) end,
		magnitude = function(a) return C._vec4_mag(a) end,
		magnitudeSquared = function(a) return C._vec4_magSquared(a) end,
		cross = function(a, b) assert(ffi.istype(vec4, b)) return C._vec4_cross(a,b) end,
		dot = function(a, b) assert(ffi.istype(vec4, b)) return C._vec4_dot(a,b) end,
	}
}
vec4 = ffi.metatype("vec4_t", vec4Meta)

local mat4Meta = {
	--__tostring = function(a) return "TODO: mat4 tostring",
	__mul = function(a,b) assert(ffi.istype(mat4, b)) return C._mat4_mul(a,b) end,
	__eq  = function(a,b) assert(ffi.istype(mat4, b)) return C._mat4_equals(a,b) end,
	__len = function(a) return 16 end,
	__index = {
		cross = function(a, b) assert(ffi.istype(mat4, b))  return C._vec4_cross(a,b) end,
		inverse = function(a) return C._mat4_inverse(a) end,
		transpose = function(a) return C._mat4_transpose(a) end,
	}
}
mat4 = ffi.metatype("mat4_t", mat4Meta)
