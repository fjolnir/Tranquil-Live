#import <TranquilCore/TranquilCore.h>
#import "PolyPrimitive.h"

@interface Plane : PolyPrimitive
- (id)initWithSubdivisions:(vec2_t)aSubdivs useVBO:(BOOL)aUseVBO;
@end
