#import "PolyPrimitive.h"

@interface Particles : PolyPrimitive
+ (Particles *)particles:(NSUInteger)aCount useVBO:(BOOL)aUseVBO;
- (id)initWithCount:(NSUInteger)aCount useVBO:(BOOL)aUseVBO;
@end
