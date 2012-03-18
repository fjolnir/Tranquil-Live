#import "PolyPrimitive.h"

@interface Cube : PolyPrimitive
+ (Cube *)cubeWithSize:(GLMFloat)size;
- (id)initWithSize:(GLMFloat)size;
@end
