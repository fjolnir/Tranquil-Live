#import "GLMathWrapper.h"

@implementation Vector2
@synthesize vec=_vec;
@dynamic x, y, u, v;

+ (Vector2 *)vectorWithX:(GLMFloat)aX y:(GLMFloat)aY {
	Vector2 *out = [[self alloc] init];
	out->_vec = vec2_create(aX, aY);
	return out;
}
+ (Vector2 *)vectorWithVec:(vec2_t)aVec {
	Vector2 *out = [[self alloc] init];
	out->_vec = aVec;
	return out;
}
- (id)copyWithZone:(NSZone *)aZone
{
	NSZone *zone = aZone ? aZone : NSDefaultMallocZone();
	Vector2 *copy = [[[self class] allocWithZone:zone] init];
	copy->_vec = _vec;
	return copy;
}

- (GLMFloat)x { return _vec.x; }
- (GLMFloat)y { return _vec.y; }
- (void)setX:(GLMFloat)n { _vec.x = n; }
- (void)setY:(GLMFloat)n { _vec.y = n; }
- (GLMFloat)u { return _vec.u; }
- (GLMFloat)v { return _vec.v; }
- (void)setU:(GLMFloat)n { _vec.u = n; }
- (void)setV:(GLMFloat)n { _vec.v = n; }

- (Vector2 *)add:(Vector2 *)aOther {
	return [Vector2 vectorWithVec:vec2_add(_vec, aOther->_vec)];
}
- (Vector2 *)sub:(Vector2 *)aOther {
	return [Vector2 vectorWithVec:vec2_sub(_vec, aOther->_vec)];
}
- (Vector2 *)mul:(Vector2 *)aOther {
	return [Vector2 vectorWithVec:vec2_mul(_vec, aOther->_vec)];
}
- (Vector2 *)div:(Vector2 *)aOther {
	return [Vector2 vectorWithVec:vec2_div(_vec, aOther->_vec)];
}

- (GLMFloat)dot:(Vector2 *)aOther {
	return vec2_dot(_vec, aOther->_vec);
}
- (GLMFloat)distanceToPoint:(Vector2 *)aOther {
	return vec2_dist(_vec, aOther->_vec);
}

- (GLMFloat)magnitude {
	return vec2_mag(_vec);
}
- (GLMFloat)magnitudeSquared {
    return vec2_magSquared(_vec);
}
- (Vector2 *)normalize {
	return [Vector2 vectorWithVec:vec2_normalize(_vec)];
}
- (Vector2 *)negate {
	return [Vector2 vectorWithVec:vec2_negate(_vec)];
}
- (Vector2 *)floor {
	return [Vector2 vectorWithVec:vec2_floor(_vec)];
}

- (Vector2 *)scalarMul:(GLMFloat)aScalar {
	return [Vector2 vectorWithVec:vec2_scalarMul(_vec, aScalar)];
}
- (Vector2 *)scalarDiv:(GLMFloat)aScalar {
	return [Vector2 vectorWithVec:vec2_scalarDiv(_vec, aScalar)];
}
- (Vector2 *)scalarAdd:(GLMFloat)aScalar
{
    return [Vector2 vectorWithVec:vec2_scalarAdd(_vec, aScalar)];
}
- (Vector2 *)scalarSub:(GLMFloat)aScalar
{
    return [Vector2 vectorWithVec:vec2_scalarAdd(_vec, aScalar)];
}

- (NSString *)description {
	return [[super description] stringByAppendingFormat:@" [%.2f, %.2f]", _vec.x, _vec.y];
}

@end

@implementation Vector3
@synthesize vec=_vec;
@dynamic x, y, z;

+ (Vector3 *)vectorWithX:(GLMFloat)aX y:(GLMFloat)aY z:(GLMFloat)aZ {
	Vector3 *out = [[self alloc] init];
	out->_vec = vec3_create(aX, aY, aZ);
	return out;
}
+ (Vector3 *)vectorWithVec:(vec3_t)aVec {
	Vector3 *out = [[self alloc] init];
	out->_vec = aVec;
	return out;
}
- (id)copyWithZone:(NSZone *)aZone
{
	NSZone *zone = aZone ? aZone : NSDefaultMallocZone();
	Vector3 *copy = [[[self class] allocWithZone:zone] init];
	copy->_vec = _vec;
	return copy;
}
- (GLMFloat)x { return _vec.x; }
- (GLMFloat)y { return _vec.y; }
- (GLMFloat)z { return _vec.z; }
- (void)setX:(GLMFloat)n { _vec.x = n; }
- (void)setY:(GLMFloat)n { _vec.y = n; }
- (void)setZ:(GLMFloat)n { _vec.z = n; }
- (GLMFloat)r { return _vec.r; }
- (GLMFloat)g { return _vec.g; }
- (GLMFloat)b { return _vec.b; }
- (void)setR:(GLMFloat)n { _vec.r = n; }
- (void)setG:(GLMFloat)n { _vec.g = n; }
- (void)setB:(GLMFloat)n { _vec.b = n; }

- (Vector3 *)add:(Vector3 *)aOther {
	return [Vector3 vectorWithVec:vec3_add(_vec, aOther->_vec)];
}
- (Vector3 *)sub:(Vector3 *)aOther {
	return [Vector3 vectorWithVec:vec3_sub(_vec, aOther->_vec)];
}
- (Vector3 *)mul:(Vector3 *)aOther {
	return [Vector3 vectorWithVec:vec3_mul(_vec, aOther->_vec)];
}
- (Vector3 *)div:(Vector3 *)aOther {
	return [Vector3 vectorWithVec:vec3_div(_vec, aOther->_vec)];
}
- (Vector3 *)cross:(Vector3 *)aOther {
	return [Vector3 vectorWithVec:vec3_cross(_vec, aOther->_vec)];
}

- (GLMFloat)dot:(Vector3 *)aOther {
	return vec3_dot(_vec, aOther->_vec);
}
- (GLMFloat)distanceToPoint:(Vector3 *)aOther {
	return vec3_dist(_vec, aOther->_vec);
}

- (GLMFloat)magnitude {
	return vec3_mag(_vec);
}
- (GLMFloat)magnitudeSquared {
    return vec3_magSquared(_vec);
}
- (Vector3 *)normalize {
	return [Vector3 vectorWithVec:vec3_normalize(_vec)];
}
- (Vector3 *)negate {
	return [Vector3 vectorWithVec:vec3_negate(_vec)];
}
- (Vector3 *)floor {
	return [Vector3 vectorWithVec:vec3_floor(_vec)];
}

- (Vector3 *)scalarMul:(GLMFloat)aScalar {
	return [Vector3 vectorWithVec:vec3_scalarMul(_vec, aScalar)];
}
- (Vector3 *)scalarDiv:(GLMFloat)aScalar {
	return [Vector3 vectorWithVec:vec3_scalarDiv(_vec, aScalar)];
}
- (Vector3 *)scalarAdd:(GLMFloat)aScalar
{
    return [Vector3 vectorWithVec:vec3_scalarAdd(_vec, aScalar)];
}
- (Vector3 *)scalarSub:(GLMFloat)aScalar
{
    return [Vector3 vectorWithVec:vec3_scalarAdd(_vec, aScalar)];
}

- (NSString *)description {
	return [[super description] stringByAppendingFormat:@" [%.2f, %.2f, %.2f]", _vec.x, _vec.y, _vec.z];
}
@end

@implementation Vector4
@synthesize vec=_vec;
@dynamic x, y, z, w, r, g, b, a;

+ (Vector4 *)vectorWithX:(GLMFloat)aX y:(GLMFloat)aY z:(GLMFloat)aZ w:(GLMFloat)aW {
	Vector4 *out = [[self alloc] init];
	out->_vec = vec4_create(aX, aY, aZ, aW);
	return out;
}
+ (Vector4 *)vectorWithVec:(vec4_t)aVec {
	Vector4 *out = [[self alloc] init];
	out->_vec = aVec;
	return out;
}
- (id)copyWithZone:(NSZone *)aZone
{
	NSZone *zone = aZone ? aZone : NSDefaultMallocZone();
	Vector4 *copy = [[[self class] allocWithZone:zone] init];
	copy->_vec = _vec;
	return copy;
}
- (GLMFloat)x { return _vec.x; }
- (GLMFloat)y { return _vec.y; }
- (GLMFloat)z { return _vec.z; }
- (GLMFloat)w { return _vec.w; }
- (GLMFloat)r { return _vec.r; }
- (GLMFloat)g { return _vec.g; }
- (GLMFloat)b { return _vec.b; }
- (GLMFloat)a { return _vec.a; }

- (void)setX:(GLMFloat)n { _vec.x = n; }
- (void)setY:(GLMFloat)n { _vec.y = n; }
- (void)setZ:(GLMFloat)n { _vec.z = n; }
- (void)setW:(GLMFloat)n { _vec.w = n; }

- (void)setR:(GLMFloat)n { _vec.r = n; }
- (void)setG:(GLMFloat)n { _vec.g = n; }
- (void)setB:(GLMFloat)n { _vec.b = n; }
- (void)setA:(GLMFloat)n { _vec.a = n; }

- (Vector4 *)add:(Vector4 *)aOther {
	return [Vector4 vectorWithVec:vec4_add(_vec, aOther->_vec)];
}
- (Vector4 *)sub:(Vector4 *)aOther {
	return [Vector4 vectorWithVec:vec4_sub(_vec, aOther->_vec)];
}
- (Vector4 *)mul:(Vector4 *)aOther {
	return [Vector4 vectorWithVec:vec4_mul(_vec, aOther->_vec)];
}
- (Vector4 *)div:(Vector4 *)aOther {
	return [Vector4 vectorWithVec:vec4_div(_vec, aOther->_vec)];
}
- (Vector4 *)cross:(Vector4 *)aOther {
	return [Vector4 vectorWithVec:vec4_cross(_vec, aOther->_vec)];
}

- (GLMFloat)dot:(Vector4 *)aOther {
	return vec4_dot(_vec, aOther->_vec);
}
- (GLMFloat)distanceToPoint:(Vector4 *)aOther {
	return vec4_dist(_vec, aOther->_vec);
}

- (GLMFloat)magnitude {
	return vec4_mag(_vec);
}
- (GLMFloat)magnitudeSquared {
    return vec4_magSquared(_vec);
}

- (Vector4 *)normalize {
	return [Vector4 vectorWithVec:vec4_normalize(_vec)];
}
- (Vector4 *)negate {
	return [Vector4 vectorWithVec:vec4_negate(_vec)];
}
- (Vector4 *)floor {
	return [Vector4 vectorWithVec:vec4_floor(_vec)];
}

- (Vector4 *)scalarMul:(GLMFloat)aScalar {
	return [Vector4 vectorWithVec:vec4_scalarMul(_vec, aScalar)];
}
- (Vector4 *)scalarDiv:(GLMFloat)aScalar {
	return [Vector4 vectorWithVec:vec4_scalarDiv(_vec, aScalar)];
}
- (Vector4 *)scalarAdd:(GLMFloat)aScalar
{
    return [Vector4 vectorWithVec:vec4_scalarAdd(_vec, aScalar)];
}
- (Vector4 *)scalarSub:(GLMFloat)aScalar
{
    return [Vector4 vectorWithVec:vec4_scalarAdd(_vec, aScalar)];
}

- (NSString *)description {
	return [[super description] stringByAppendingFormat:@" [%.2f, %.2f, %.2f, %.2f]", _vec.x, _vec.y, _vec.z, _vec.w];
}
@end

@implementation Matrix3
@synthesize mat=_mat;

+ (Matrix3 *)matrixWithMat:(mat3_t)aMat {
	Matrix3 *out = [[self alloc] init];
	out->_mat = aMat;
	return out;
}
- (id)copyWithZone:(NSZone *)aZone
{
	NSZone *zone = aZone ? aZone : NSDefaultMallocZone();
	Matrix3 *copy = [[[self class] allocWithZone:zone] init];
	copy->_mat = _mat;
	return copy;
}
- (Matrix3 *)mul:(Matrix3 *)aOther {
	return [Matrix3 matrixWithMat:mat3_mul(_mat, aOther->_mat)];
}
- (Vector3 *)mulVector:(Vector3 *)aVector {
	return [Vector3 vectorWithVec:vec3_mul_mat3(aVector->_vec, _mat)];
}
- (Matrix3 *)inverse {
	return [Matrix3 matrixWithMat:mat3_inverse(_mat, NULL)];
}
- (Matrix3 *)transpose {
	return [Matrix3 matrixWithMat:mat3_transpose(_mat)];
}
- (GLMFloat)determinant {
	return mat3_det(_mat);
}
@end

@implementation Matrix4
@synthesize mat=_mat;

+ (Matrix4 *)matrixWithMat:(mat4_t)aMat {
	Matrix4 *out = [[self alloc] init];
	out->_mat = aMat;
	return out;
}
+ (Matrix4 *)identity {
	return [Matrix4 matrixWithMat:kMat4_identity];
}
+ (Matrix4 *)zero {
	return [Matrix4 matrixWithMat:kMat4_zero];
}
- (id)copyWithZone:(NSZone *)aZone
{
	NSZone *zone = aZone ? aZone : NSDefaultMallocZone();
	Matrix4 *copy = [[[self class] allocWithZone:zone] init];
	copy->_mat = _mat;
	return copy;
}

// Viewing matrices
+ (Matrix4 *)perspectiveMatrixWithFov:(GLMFloat)aFov aspectRatio:(GLMFloat)aAspect zNear:(GLMFloat)aZNear zFar:(GLMFloat)aZFar {
	Matrix4 *out = [[self alloc] init];
	out->_mat = mat4_perspective(aFov, aAspect, aZNear, aZFar);
	return out;
}
+ (Matrix4 *)frustumWithLeft:(GLMFloat)aLeft right:(GLMFloat)aRight bottom:(GLMFloat)aBottom top:(GLMFloat)aTop near:(GLMFloat)aNear far:(GLMFloat)aFar {
	Matrix4 *out = [[self alloc] init];
	out->_mat = mat4_frustum(aLeft, aRight, aBottom, aTop, aNear, aFar);
	return out;
}
+ (Matrix4 *)orthoWithLeft:(GLMFloat)aLeft right:(GLMFloat)aRight bottom:(GLMFloat)aBottom top:(GLMFloat)aTop near:(GLMFloat)aNear far:(GLMFloat)aFar {
	Matrix4 *out = [[self alloc] init];
	out->_mat = mat4_ortho(aLeft, aRight, aBottom, aTop, aNear, aFar);
	return out;
}
+ (Matrix4 *)lookatWithEye:(Vector3 *)aEye center:(Vector3 *)aCenter upVec:(Vector3 *)upVec {
	Matrix4 *out = [[self alloc] init];
	vec3_t e = aEye->_vec;
	vec3_t c = aCenter->_vec;
	vec3_t u = upVec->_vec;
	out->_mat = mat4_lookat(e.x, e.y, e.z, c.x, c.y, c.z, u.x, u.y, u.z);
	return out;
}

// Transformation matrices
+ (Matrix4 *)translationWithX:(GLMFloat)x y:(GLMFloat)y z:(GLMFloat)z {
	Matrix4 *out = [[self alloc] init];
	out->_mat = mat4_create_translation(x, y, z);
	return out;
}
+ (Matrix4 *)rotationWithAngle:(GLMFloat)angle x:(GLMFloat)x y:(GLMFloat)y z:(GLMFloat)z {
	Matrix4 *out = [[self alloc] init];
	out->_mat = mat4_create_rotation(angle, x, y, z);
	return out;
}
+ (Matrix4 *)scaleWithX:(GLMFloat)x y:(GLMFloat)y z:(GLMFloat)z {
	Matrix4 *out = [[self alloc] init];
	out->_mat = mat4_create_scale(x, y, z);
	return out;
}


- (Matrix4 *)mul:(Matrix4 *)aOther {
	return [Matrix4 matrixWithMat:mat4_mul(_mat, aOther->_mat)];
}
- (Vector4 *)mulVector:(Vector4 *)aVector {
	return [Vector4 vectorWithVec:vec4_mul_mat4(aVector->_vec, _mat)];
}
- (Vector3 *)mulVector3:(Vector3 *)aVector isPoint:(BOOL)aIsPoint {
	return [Vector3 vectorWithVec:vec3_mul_mat4(aVector->_vec, _mat, aIsPoint)];
}
- (Matrix4 *)inverse {
	return [Matrix4 matrixWithMat:mat4_inverse(_mat, NULL)];
}
- (Matrix4 *)transpose {
	return [Matrix4 matrixWithMat:mat4_transpose(_mat)];
}
- (GLMFloat)determinant {
	return mat4_det(_mat);
}
- (Matrix3 *)extractMatrix3 {
	return [Matrix3 matrixWithMat:mat4_extract_mat3(_mat)];
}

// Transformations
- (Matrix4 *)translateWithX:(GLMFloat)x y:(GLMFloat)y z:(GLMFloat)z {
	return [Matrix4 matrixWithMat:mat4_translate(_mat, x, y, z)];
}
- (Matrix4 *)rotateWithAngle:(GLMFloat)angle x:(GLMFloat)x y:(GLMFloat)y z:(GLMFloat)z {
	return [Matrix4 matrixWithMat:mat4_rotate(_mat, angle, x, y, z)];
}
- (Matrix4 *)scaleWithX:(GLMFloat)x y:(GLMFloat)y z:(GLMFloat)z {
	return [Matrix4 matrixWithMat:mat4_scale(_mat, x, y, z)];
}
@end

@implementation MatrixStack
@synthesize stack=_stack;
@dynamic top, topAsMat3;

+ (MatrixStack *)stackWithCapacity:(int)aCapacity {
	MatrixStack *out = [[MatrixStack alloc] init];
	out.stack = matrix_stack_create(aCapacity);
	return out;
}
- (id)copyWithZone:(NSZone *)aZone
{
	NSZone *zone = aZone ? aZone : NSDefaultMallocZone();
	MatrixStack *copy = [[[self class] allocWithZone:zone] init];
	copy->_stack = matrix_stack_create(_stack->capacity);
	memcpy(copy->_stack->items, _stack->items, _stack->count*sizeof(mat4_t));
	copy->_stack->count = _stack->count;
	return copy;
}

- (void)finalize {
	matrix_stack_destroy(_stack);
	[super finalize];
}
- (void)push {
	matrix_stack_push(_stack);
}
- (void)push:(Matrix4 *)aMat {
	matrix_stack_push_item(_stack, aMat->_mat);
}
- (void)pop {
	matrix_stack_pop(_stack);
}

- (Matrix4 *)top {
	return [Matrix4 matrixWithMat:matrix_stack_get_mat4(_stack)];
}
- (Matrix3 *)topAsMat3 {
	return [Matrix3 matrixWithMat:matrix_stack_get_mat3(_stack)];
}
- (void)mul:(Matrix4 *)aMat {
	matrix_stack_mul_mat4(_stack, aMat->_mat);
}
- (void)translateWithX:(GLMFloat)x y:(GLMFloat)y z:(GLMFloat)z {
	matrix_stack_translate(_stack, x, y, z);
}
- (void)scaleWithX:(GLMFloat)x y:(GLMFloat)y z:(GLMFloat)z {
	matrix_stack_scale(_stack, x, y, z);
}
- (void)rotateWithAngle:(GLMFloat)angle x:(GLMFloat)x y:(GLMFloat)y z:(GLMFloat)z {
	matrix_stack_rotate(_stack, angle, x, y, z);
}
@end

@implementation Quaternion
@synthesize quat=_quat;
@dynamic vec, scalar;

+ (Quaternion *)quaternionWithAngle:(GLMFloat)aAngle x:(GLMFloat)aX y:(GLMFloat)aY z:(GLMFloat)aZ {
	Quaternion *out = [[self alloc] init];
	out->_quat = quat_createf(aAngle, aX, aY, aZ);
	return out;
}
+ (Quaternion *)quaternionWithQuat:(quat_t)aQuat {
	Quaternion *out = [[self alloc] init];
	out->_quat = aQuat;
	return out;
}
+ (Quaternion *)quaternionFromMatrix4:(Matrix4 *)aMat {
	Quaternion *out = [[self alloc] init];
	out->_quat = ortho_to_quat(aMat->_mat);
	return out;
}
+ (Quaternion *)quaternionFromOrtho:(Matrix4 *)aMat {
	Quaternion *out = [[self alloc] init];
	out->_quat = mat4_to_quat(aMat->_mat);
	return out;
}
- (id)copyWithZone:(NSZone *)aZone
{
	NSZone *zone = aZone ? aZone : NSDefaultMallocZone();
	Quaternion *copy = [[[self class] allocWithZone:zone] init];
	copy->_quat = _quat;
	return copy;
}

- (Vector3 *)vec { return [Vector3 vectorWithVec:_quat.vec]; }
- (GLMFloat)scalar { return _quat.scalar; }

- (void)setVec:(Vector3 *)n { _quat.vec = n.vec; }
- (void)setScalar:(GLMFloat)n { _quat.scalar = n; }

- (Matrix4 *)toMatrix4 {
	return [Matrix4 matrixWithMat:quat_to_mat4(_quat)];
}
- (Matrix4 *)toOrtho {
	return [Matrix4 matrixWithMat:quat_to_ortho(_quat)];
}

- (GLMFloat)magnitude {
	return quat_mag(_quat);
}
- (Quaternion *)normalize {
	return [Quaternion quaternionWithQuat:quat_normalize(_quat)];
}
- (Quaternion *)computeW {
	return [Quaternion quaternionWithQuat:quat_computeW(_quat)];
}
- (Quaternion *)mul:(Quaternion *)aOther {
	return [Quaternion quaternionWithQuat:quat_multQuat(_quat, aOther->_quat)];
}
- (Vector4 *)rotatePoint:(Vector4 *)aPoint {
	return [Vector4 vectorWithVec:quat_rotatePoint(_quat, aPoint->_vec)];
}
- (GLMFloat)dot:(Quaternion *)aOther {
	return quat_dotProduct(_quat, aOther->_quat);
}
- (Quaternion *)slerpWithDest:(Quaternion *)aDest t:(GLMFloat)aT {
	return [Quaternion quaternionWithQuat:quat_slerp(_quat, aDest->_quat, aT)];
}

- (NSString *)description {
	return [[super description] stringByAppendingFormat:@" [%.2f, %.2f, %.2f, %.2f]", _quat.x, _quat.y, _quat.z, _quat.w];
}
@end
