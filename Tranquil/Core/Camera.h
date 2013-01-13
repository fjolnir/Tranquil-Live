#import "Vec3.h"
#import "Vec4.h"
#import "Quat.h"
#import "Mat4.h"

@interface Camera : NSObject {
@public
    Mat4 *_matrix;
}
@property(readwrite, copy) Vec3 *position;
@property(readwrite, assign) Quat *orientation;
@property(readwrite, assign) GLMFloat fov, zoom, aspectRatio;
@property(readwrite, copy) Mat4 *matrix;

+ (Vec4 *)viewportSize;

- (id)updateMatrix;
// Takes a point in screen space and un-projects it back into world space
- (Vec3 *)unProjectPoint:(Vec3 *)aPoint;
@end
