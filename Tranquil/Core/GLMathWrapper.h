#include <GLMath/GLMath.h>

// We are using double precision vertices for the time being, so we need these macros to cast uniforms to floats
// before uploading to gl. This is a workaround for a bug in MacRuby that causes it to get alignment on floats wrong
#define FCAST_VEC4(v) { (float)((v).x), (float)((v).y), (float)((v).z), (float)((v).w) }
#define FCAST_MAT4(m) { (float)((m).m00), (float)((m).m01), (float)((m).m02), (float)((m).m03), \
(float)((m).m10), (float)((m).m11), (float)((m).m12), (float)((m).m13), \
(float)((m).m20), (float)((m).m21), (float)((m).m22), (float)((m).m23), \
(float)((m).m30), (float)((m).m31), (float)((m).m32), (float)((m).m33), }

@interface Vector2 : NSObject { @public vec2_t _vec; }
@property(readwrite, assign) vec2_t vec;
@property(readwrite, assign) GLMFloat x, y;
@property(readwrite, assign) GLMFloat u, v;

+ (Vector2 *)vectorWithX:(GLMFloat)aX y:(GLMFloat)aY;
+ (Vector2 *)vectorWithVec:(vec2_t)aVec;

- (Vector2 *)add:(Vector2 *)aOther;
- (Vector2 *)sub:(Vector2 *)aOther;
- (Vector2 *)mul:(Vector2 *)aOther;
- (Vector2 *)div:(Vector2 *)aOther;

- (GLMFloat)dot:(Vector2 *)aOther;
- (GLMFloat)distanceToPoint:(Vector2 *)aOther;

- (GLMFloat)magnitude;
- (GLMFloat)magnitudeSquared;
- (Vector2 *)normalize;
- (Vector2 *)negate;
- (Vector2 *)floor;

- (Vector2 *)scalarMul:(GLMFloat)aScalar;
- (Vector2 *)scalarDiv:(GLMFloat)aScalar;
- (Vector2 *)scalarAdd:(GLMFloat)aScalar;
- (Vector2 *)scalarSub:(GLMFloat)aScalar;
@end

@interface Vector3 : NSObject { @public vec3_t _vec; }
@property(readwrite, assign) vec3_t vec;
@property(readwrite, assign) GLMFloat x, y, z;
@property(readwrite, assign) GLMFloat r, g, b;

+ (Vector3 *)vectorWithX:(GLMFloat)aX y:(GLMFloat)aY z:(GLMFloat)aZ;
+ (Vector3 *)vectorWithVec:(vec3_t)aVec;

- (Vector3 *)add:(Vector3 *)aOther;
- (Vector3 *)sub:(Vector3 *)aOther;
- (Vector3 *)mul:(Vector3 *)aOther;
- (Vector3 *)div:(Vector3 *)aOther;
- (Vector3 *)cross:(Vector3 *)aOther;

- (GLMFloat)dot:(Vector3 *)aOther;
- (GLMFloat)distanceToPoint:(Vector3 *)aOther;

- (GLMFloat)magnitude;
- (GLMFloat)magnitudeSquared;
- (Vector3 *)normalize;
- (Vector3 *)negate;
- (Vector3 *)floor;

- (Vector3 *)scalarMul:(GLMFloat)aScalar;
- (Vector3 *)scalarDiv:(GLMFloat)aScalar;
- (Vector3 *)scalarAdd:(GLMFloat)aScalar;
- (Vector3 *)scalarSub:(GLMFloat)aScalar;
@end

@interface Vector4 : NSObject { @public vec4_t _vec; }
@property(readwrite, assign) vec4_t vec;
@property(readwrite, assign) GLMFloat x, y, z, w;
@property(readwrite, assign) GLMFloat r, g, b, a;

+ (Vector4 *)vectorWithX:(GLMFloat)aX y:(GLMFloat)aY z:(GLMFloat)aZ w:(GLMFloat)aW;
+ (Vector4 *)vectorWithVec:(vec4_t)aVec;

- (Vector4 *)add:(Vector4 *)aOther;
- (Vector4 *)sub:(Vector4 *)aOther;
- (Vector4 *)mul:(Vector4 *)aOther;
- (Vector4 *)div:(Vector4 *)aOther;
- (Vector4 *)cross:(Vector4 *)aOther;

- (GLMFloat)dot:(Vector4 *)aOther;
- (GLMFloat)distanceToPoint:(Vector4 *)aOther;

- (GLMFloat)magnitude;
- (GLMFloat)magnitudeSquared;
- (Vector4 *)normalize;
- (Vector4 *)negate;
- (Vector4 *)floor;

- (Vector4 *)scalarMul:(GLMFloat)aScalar;
- (Vector4 *)scalarDiv:(GLMFloat)aScalar;
- (Vector4 *)scalarAdd:(GLMFloat)aScalar;
- (Vector4 *)scalarSub:(GLMFloat)aScalar;
@end

@interface Matrix3 : NSObject { @public mat3_t _mat; }
@property(readwrite, assign) mat3_t mat;
+ (Matrix3 *)matrixWithMat:(mat3_t)aMat;

- (Matrix3 *)mul:(Matrix3 *)aOther;
- (Vector3 *)mulVector:(Vector3 *)aVector;
- (Matrix3 *)inverse;
- (Matrix3 *)transpose;
- (GLMFloat)determinant;
@end

@interface Matrix4 : NSObject { @public mat4_t _mat; }
@property(readwrite, assign) mat4_t mat;
+ (Matrix4 *)matrixWithMat:(mat4_t)aMat;
+ (Matrix4 *)identity;
+ (Matrix4 *)zero;

+ (Matrix4 *)perspectiveMatrixWithFov:(GLMFloat)aFov aspectRatio:(GLMFloat)aAspect zNear:(GLMFloat)aZNear zFar:(GLMFloat)aZFar;
+ (Matrix4 *)frustumWithLeft:(GLMFloat)aLeft right:(GLMFloat)aRight bottom:(GLMFloat)aBottom top:(GLMFloat)aTop near:(GLMFloat)aNear far:(GLMFloat)aFar;
+ (Matrix4 *)orthoWithLeft:(GLMFloat)aLeft right:(GLMFloat)aRight bottom:(GLMFloat)aBottom top:(GLMFloat)aTop near:(GLMFloat)aNear far:(GLMFloat)aFar;
+ (Matrix4 *)lookatWithEye:(Vector3 *)aEye center:(Vector3 *)aCenter upVec:(Vector3 *)upVec;

// Transformation matrices
+ (Matrix4 *)translationWithX:(GLMFloat)x y:(GLMFloat)y z:(GLMFloat)z;
+ (Matrix4 *)rotationWithAngle:(GLMFloat)angle x:(GLMFloat)x y:(GLMFloat)y z:(GLMFloat)z;
+ (Matrix4 *)scaleWithX:(GLMFloat)x y:(GLMFloat)y z:(GLMFloat)z;

- (Matrix4 *)mul:(Matrix4 *)aOther;
- (Vector4 *)mulVector:(Vector4 *)aVector;
- (Vector3 *)mulVector3:(Vector3 *)aVector isPoint:(BOOL)aIsPoint ;
- (Matrix4 *)inverse;
- (Matrix4 *)transpose;
- (GLMFloat)determinant;
- (Matrix3 *)extractMatrix3;

- (Matrix4 *)translateWithX:(GLMFloat)x y:(GLMFloat)y z:(GLMFloat)z;
- (Matrix4 *)rotateWithAngle:(GLMFloat)angle x:(GLMFloat)x y:(GLMFloat)y z:(GLMFloat)z;
- (Matrix4 *)scaleWithX:(GLMFloat)x y:(GLMFloat)y z:(GLMFloat)z;
@end

@interface MatrixStack : NSObject { @public matrix_stack_t *_stack; }
@property(readwrite, assign) matrix_stack_t *stack;
@property(readonly) Matrix4 *top, *topAsMat3;
+ (MatrixStack *)stackWithCapacity:(int)aCapacity;

- (void)push;
- (void)push:(Matrix4 *)aMat;
- (void)pop;

- (void)mul:(Matrix4 *)aMat;
- (void)translateWithX:(GLMFloat)x y:(GLMFloat)y z:(GLMFloat)z;
- (void)scaleWithX:(GLMFloat)x y:(GLMFloat)y z:(GLMFloat)z;
- (void)rotateWithAngle:(GLMFloat)angle x:(GLMFloat)x y:(GLMFloat)y z:(GLMFloat)z;
@end

@interface Quaternion : NSObject { @public quat_t _quat; }
@property(readwrite, assign) quat_t quat;
@property(readwrite, assign) Vector3 *vec;
@property(readwrite, assign) GLMFloat scalar;


+ (Quaternion *)quaternionWithAngle:(GLMFloat)aAngle x:(GLMFloat)aX y:(GLMFloat)aY z:(GLMFloat)aZ;
+ (Quaternion *)quaternionWithQuat:(quat_t)aQuat;
+ (Quaternion *)quaternionFromMatrix4:(Matrix4 *)aMat;
+ (Quaternion *)quaternionFromOrtho:(Matrix4 *)aMat;

- (Matrix4 *)toMatrix4;
- (Matrix4 *)toOrtho;

- (GLMFloat)magnitude;
- (Quaternion *)normalize;
- (Quaternion *)computeW;
- (Quaternion *)mul:(Quaternion *)aOther;
- (Vector4 *)rotatePoint:(Vector4 *)aPoint;
- (GLMFloat)dot:(Quaternion *)aOther;
- (Quaternion *)slerpWithDest:(Quaternion *)aDest t:(GLMFloat)aT;
@end
