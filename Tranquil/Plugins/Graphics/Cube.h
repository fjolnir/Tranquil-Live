#import "PolyPrimitive.h"

@interface Cube : PolyPrimitive
+ (Cube *)cubeWithSize:(GLMFloat)size useVBO:(BOOL)aUseVBO;
- (id)initWithSize:(GLMFloat)size useVBO:(BOOL)aUseVBO;
@end
