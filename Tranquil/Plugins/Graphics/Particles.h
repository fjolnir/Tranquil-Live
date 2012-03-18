#import "PolyPrimitive.h"

@interface Particles : PolyPrimitive
+ (Particles *)particles:(NSUInteger)aCount;
- (id)initWithCount:(NSUInteger)aCount;
@end
