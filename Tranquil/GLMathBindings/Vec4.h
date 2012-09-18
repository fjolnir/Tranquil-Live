#import <Foundation/Foundation.h>
#import <GLMath/GLMath.h>
#import <Tranquil/Runtime/TQNumber.h>
#import <Tranquil/Runtime/TQBoxedObject.h>
#import <Tranquil/Shared/TQBatching.h>

@interface Vec4 : TQBoxedObject {
    vec4_t _vec;
    TQ_BATCH_IVARS
}
@property(readwrite) vec4_t vec;

+ (Vec4 *)withVec:(vec4_t)vec;
+ (Vec4 *)withX:(TQNumber *)x y:(TQNumber *)y z:(TQNumber *)z w:(TQNumber *)w;
+ (Vec4 *)zero;

- (TQNumber *)x;
- (TQNumber *)y;
- (TQNumber *)z;
- (TQNumber *)w;
- (id)setX:(TQNumber *)val;
- (id)setY:(TQNumber *)val;
- (id)setZ:(TQNumber *)val;
- (id)setW:(TQNumber *)val;
                          
- (Vec4 *)add:(id)b;
- (Vec4 *)subtract:(id)b;
- (Vec4 *)multiply:(id)b;
- (Vec4 *)divideBy:(id)b;
- (Vec4 *)cross:(Vec4 *)b;
- (Vec4 *)dot:(Vec4 *)b;
- (Vec4 *)dist:(Vec4 *)b;
- (Vec4 *)negate;
- (Vec4 *)ceil;
- (Vec4 *)floor;
- (Vec4 *)normalize;
- (Vec4 *)magnitude;
@end
