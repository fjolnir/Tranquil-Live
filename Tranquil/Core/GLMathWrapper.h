#include <GLMath/GLMath.h>

@interface Vector2 : NSObject { @public vec2_t _vec; }
@property(readwrite, assign) vec2_t vec;
@property(readwrite, assign) float x, y;
@property(readwrite, assign) float u, v;

+ (Vector2 *)vectorWithX:(float)aX y:(float)aY;
+ (Vector2 *)vectorWithVec:(vec2_t)aVec;

- (Vector2 *)add:(Vector2 *)aOther;
- (Vector2 *)sub:(Vector2 *)aOther;
- (Vector2 *)mul:(Vector2 *)aOther;
- (Vector2 *)div:(Vector2 *)aOther;

- (float)dot:(Vector2 *)aOther;
- (float)distanceToPoint:(Vector2 *)aOther;

- (float)magnitude;
- (Vector2 *)normalize;
- (Vector2 *)negate;
- (Vector2 *)floor;

- (Vector2 *)scalarMul:(float)aScalar;
- (Vector2 *)vec2_scalarDiv:(float)aScalar;
@end

@interface Vector3 : NSObject { @public vec3_t _vec; }
@property(readwrite, assign) vec3_t vec;
@property(readwrite, assign) float x, y, z;

+ (Vector3 *)vectorWithX:(float)aX y:(float)aY z:(float)aZ;
+ (Vector3 *)vectorWithVec:(vec3_t)aVec;

- (Vector3 *)add:(Vector3 *)aOther;
- (Vector3 *)sub:(Vector3 *)aOther;
- (Vector3 *)mul:(Vector3 *)aOther;
- (Vector3 *)div:(Vector3 *)aOther;
- (Vector3 *)cross:(Vector3 *)aOther;

- (float)dot:(Vector3 *)aOther;
- (float)distanceToPoint:(Vector3 *)aOther;

- (float)magnitude;
- (Vector3 *)normalize;
- (Vector3 *)negate;
- (Vector3 *)floor;

- (Vector3 *)scalarMul:(float)aScalar;
- (Vector3 *)vec3_scalarDiv:(float)aScalar;
@end

@interface Vector4 : NSObject { @public vec4_t _vec; }
@property(readwrite, assign) vec4_t vec;
@property(readwrite, assign) float x, y, z, w;
@property(readwrite, assign) float r, g, b, a;

+ (Vector4 *)vectorWithX:(float)aX y:(float)aY z:(float)aZ w:(float)aW;
+ (Vector4 *)vectorWithVec:(vec4_t)aVec;

- (Vector4 *)add:(Vector4 *)aOther;
- (Vector4 *)sub:(Vector4 *)aOther;
- (Vector4 *)mul:(Vector4 *)aOther;
- (Vector4 *)div:(Vector4 *)aOther;
- (Vector4 *)cross:(Vector4 *)aOther;

- (float)dot:(Vector4 *)aOther;
- (float)distanceToPoint:(Vector4 *)aOther;

- (float)magnitude;
- (Vector4 *)normalize;
- (Vector4 *)negate;
- (Vector4 *)floor;

- (Vector4 *)scalarMul:(float)aScalar;
- (Vector4 *)vec4_scalarDiv:(float)aScalar;
@end

@interface Matrix3 : NSObject { @public mat3_t _mat; }
@property(readwrite, assign) mat3_t mat;
+ (Matrix3 *)matrixWithMat:(mat3_t)aMat;

- (Matrix3 *)mul:(Matrix3 *)aOther;
- (Vector3 *)mulVector:(Vector3 *)aVector;
- (Matrix3 *)inverse;
- (Matrix3 *)transpose;
- (float)determinant;
@end

@interface Matrix4 : NSObject { @public mat4_t _mat; }
@property(readwrite, assign) mat4_t mat;
+ (Matrix4 *)matrixWithMat:(mat4_t)aMat;
+ (Matrix4 *)identity;
+ (Matrix4 *)zero;

+ (Matrix4 *)perspectiveMatrixWithFov:(float)aFov aspectRatio:(float)aAspect zNear:(float)aZNear zFar:(float)aZFar;
+ (Matrix4 *)frustumWithLeft:(float)aLeft right:(float)aRight bottom:(float)aBottom top:(float)aTop near:(float)aNear far:(float)aFar;
+ (Matrix4 *)orthoWithLeft:(float)aLeft right:(float)aRight bottom:(float)aBottom top:(float)aTop near:(float)aNear far:(float)aFar;
+ (Matrix4 *)lookatWithEye:(Vector3 *)aEye center:(Vector3 *)aCenter upVec:(Vector3 *)upVec;

// Transformation matrices
+ (Matrix4 *)translationWithX:(float)x y:(float)y z:(float)z;
+ (Matrix4 *)rotationWithAngle:(float)angle x:(float)x y:(float)y z:(float)z;
+ (Matrix4 *)scaleWithX:(float)x y:(float)y z:(float)z;

- (Matrix4 *)mul:(Matrix4 *)aOther;
- (Vector4 *)mulVector:(Vector4 *)aVector;
- (Vector3 *)mulVector3:(Vector3 *)aVector isPoint:(BOOL)aIsPoint ;
- (Matrix4 *)inverse;
- (Matrix4 *)transpose;
- (float)determinant;
- (Matrix3 *)extractMatrix3;

- (Matrix4 *)translateWithX:(float)x y:(float)y z:(float)z;
- (Matrix4 *)rotateWithAngle:(float)angle x:(float)x y:(float)y z:(float)z;
- (Matrix4 *)scaleWithX:(float)x y:(float)y z:(float)z;
@end

@interface MatrixStack : NSObject { @public matrix_stack_t *_stack; }
@property(readwrite, assign) matrix_stack_t *stack;
@property(readonly) Matrix4 *top, *topAsMat3;
+ (MatrixStack *)stackWithCapacity:(int)aCapacity;

- (void)push;
- (void)push:(Matrix4 *)aMat;
- (void)pop;

- (void)mul:(Matrix4 *)aMat;
- (void)translateWithX:(float)x y:(float)y z:(float)z;
- (void)scaleWithX:(float)x y:(float)y z:(float)z;
- (void)rotateWithAngle:(float)angle x:(float)x y:(float)y z:(float)z;
@end

@interface Quaternion : NSObject { @public quat_t _quat; }
@property(readwrite, assign) quat_t quat;
+ (Quaternion *)quaternionWithAngle:(float)aAngle x:(float)aX y:(float)aY z:(float)aZ;
+ (Quaternion *)quaternionWithQuat:(quat_t)aQuat;
+ (Quaternion *)quaternionFromMatrix4:(Matrix4 *)aMat;
+ (Quaternion *)quaternionFromOrtho:(Matrix4 *)aMat;

- (Matrix4 *)toMatrix4;
- (Matrix4 *)toOrtho;

- (float)magnitude;
- (Quaternion *)normalize;
- (Quaternion *)computeW;
- (Quaternion *)mul:(Quaternion *)aOther;
- (Vector4 *)rotatePoint:(Vector4 *)aPoint;
- (float)dot:(Quaternion *)aOther;
- (Quaternion *)slerpWithDest:(Quaternion *)aDest t:(float)aT;
@end
