#import <Foundation/Foundation.h>
#import <GLMath/GLMath.h>
#import <Tranquil/Runtime/TQNumber.h>
#import <Tranquil/Runtime/TQBoxedObject.h>
#import <Tranquil/Shared/TQBatching.h>

@class Vec3;

@interface Mat4 : TQBoxedObject {
    mat4_t _mat;
    TQ_BATCH_IVARS
}
@property(readwrite) mat4_t mat;

+ (Mat4 *)withMat:(mat4_t)mat;
+ (Mat4 *)identity;
+ (Mat4 *)zero;
+ (Mat4 *)scale:(Vec3 *)aVec;
+ (Mat4 *)translation:(Vec3 *)aVec;
+ (Mat4 *)rotationWithAngle:(TQNumber *)aAngle axis:(Vec3 *)aVec;

- (TQNumber *)m00;
- (id)setM00:(TQNumber *)aVal;
- (TQNumber *)m01;
- (id)setM01:(TQNumber *)aVal;
- (TQNumber *)m02;
- (id)setM02:(TQNumber *)aVal;
- (TQNumber *)m03;
- (id)setM03:(TQNumber *)aVal;
- (TQNumber *)m10;
- (id)setM10:(TQNumber *)aVal;
- (TQNumber *)m11;
- (id)setM11:(TQNumber *)aVal;
- (TQNumber *)m12;
- (id)setM12:(TQNumber *)aVal;
- (TQNumber *)m13;
- (id)setM13:(TQNumber *)aVal;
- (TQNumber *)m20;
- (id)setM20:(TQNumber *)aVal;
- (TQNumber *)m21;
- (id)setM21:(TQNumber *)aVal;
- (TQNumber *)m22;
- (id)setM22:(TQNumber *)aVal;
- (TQNumber *)m23;
- (id)setM23:(TQNumber *)aVal;
- (TQNumber *)m30;
- (id)setM30:(TQNumber *)aVal;
- (TQNumber *)m31;
- (id)setM31:(TQNumber *)aVal;
- (TQNumber *)m32;
- (id)setM32:(TQNumber *)aVal;
- (TQNumber *)m3;
- (id)setM33:(TQNumber *)aVal;

- (id)multiply:(id)b;
- (Mat4 *)inverse;
@end
