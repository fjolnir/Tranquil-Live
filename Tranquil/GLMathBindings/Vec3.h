#import <Foundation/Foundation.h>
#import <GLMath/GLMath.h>
#import <Tranquil/Runtime/TQNumber.h>
#import <Tranquil/Shared/TQBatching.h>
#import <Tranquil/Runtime/TQBoxedObject.h>

@interface Vec3 : TQBoxedObject {
    vec3_t _vec;
    TQ_BATCH_IVARS
}
@property(readwrite) vec3_t vec;

+ (Vec3 *)withVec:(vec3_t)vec;
+ (Vec3 *)withX:(TQNumber *)x y:(TQNumber *)y z:(TQNumber *)z;
+ (Vec3 *)zero;

- (TQNumber *)x;
- (TQNumber *)y;
- (TQNumber *)z;

- (id)setX:(TQNumber *)val;
- (id)setY:(TQNumber *)val;
- (id)setZ:(TQNumber *)val;

- (Vec3 *)add:(id)b;
- (Vec3 *)subtract:(id)b;
- (Vec3 *)multiply:(id)b;
- (Vec3 *)divideBy:(id)b;
- (Vec3 *)cross:(Vec3 *)b;
- (Vec3 *)dot:(Vec3 *)b;
- (Vec3 *)dist:(Vec3 *)b;
- (Vec3 *)negate;
- (Vec3 *)ceil;
- (Vec3 *)floor;
- (Vec3 *)normalize;
- (Vec3 *)magnitude;
@end
