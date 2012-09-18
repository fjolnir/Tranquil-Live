#import <Foundation/Foundation.h>
#import <GLMath/GLMath.h>
#import <Tranquil/Runtime/TQNumber.h>
#import <Tranquil/Shared/TQBatching.h>
#import <Tranquil/Runtime/TQBoxedObject.h>

@class Vec3, Vec4;

@interface Quat : TQBoxedObject {
    quat_t _quat;
    TQ_BATCH_IVARS
}
@property(readwrite) quat_t quat;

+ (Quat *)withQuat:(quat_t)quat;
+ (Quat *)withX:(TQNumber *)x y:(TQNumber *)y z:(TQNumber *)z angle:(TQNumber *)theta;
+ (Quat *)withX:(TQNumber *)x y:(TQNumber *)y z:(TQNumber *)z w:(TQNumber *)w;

- (TQNumber *)x;
- (TQNumber *)y;
- (TQNumber *)z;
- (TQNumber *)w;
- (Vec3 *)vec;
- (id)setX:(TQNumber *)val;
- (id)setY:(TQNumber *)val;
- (id)setZ:(TQNumber *)val;
- (id)setW:(TQNumber *)val;
- (id)setVec:(Vec3 *)vec;
                          
- (Quat *)multiply:(id)b;
- (Quat *)inverse;
- (Quat *)normalize;
- (id)rotatePoint:(id)b;
- (TQNumber *)dot:(Quat *)b;

@end
