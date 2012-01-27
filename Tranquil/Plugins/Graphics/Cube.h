#import "PolyPrimitive.h"

@interface Cube : PolyPrimitive
- (id)initWithSize:(float)size;
@end

@interface TScene (CubePrimitive)
- (Cube *)buildCube;
- (void)drawCube;
@end