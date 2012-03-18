#import <TranquilCore/TranquilCore.h>
#import "PolyPrimitive.h"

@interface Plane : PolyPrimitive
+ (Plane *)planeWithCols:(int)uDiv rows:(int)vDiv useVBO:(BOOL)aUseVBO;
- (id)initWithCols:(int)aCols rows:(int)aRows useVBO:(BOOL)aUseVBO;
@end
