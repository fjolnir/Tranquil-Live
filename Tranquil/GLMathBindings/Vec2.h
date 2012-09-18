#import <Foundation/Foundation.h>
#import <GLMath/GLMath.h>
#import <Tranquil/Runtime/TQNumber.h>
#import <Tranquil/Shared/TQBatching.h>
#import <Tranquil/Runtime/TQBoxedObject.h>

@interface Vec2 : TQBoxedObject {
    vec2_t _vec;
    TQ_BATCH_IVARS
}
@property(readwrite) vec2_t vec;

+ (Vec2 *)withVec:(vec2_t)vec;
+ (Vec2 *)withX:(TQNumber *)x y:(TQNumber *)y;
+ (Vec2 *)zero;

- (TQNumber *)x;
- (TQNumber *)y;

- (id)setX:(TQNumber *)val;
- (id)setY:(TQNumber *)val;

- (Vec2 *)add:(id)b;
- (Vec2 *)subtract:(id)b;
- (Vec2 *)multiply:(id)b;
- (Vec2 *)divideBy:(id)b;
- (Vec2 *)dist:(Vec2 *)b;
- (Vec2 *)negate;
- (Vec2 *)ceil;
- (Vec2 *)floor;
- (Vec2 *)normalize;
- (Vec2 *)magnitude;
@end
