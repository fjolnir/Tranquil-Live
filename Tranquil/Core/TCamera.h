#include <GLMath.h>

__attribute__((visibility("default"))) @interface TCamera : NSObject
@property(readwrite, assign) vec4_t position;
@property(readwrite, assign) quat_t orientation;
@property(readwrite, assign) float fov, zoom, aspectRatio;
@property(readonly) mat4_t matrix;

- (void)updateMatrix;
// Takes a point in screen space and un-projects it back into world space
- (vec4_t)unProjectPoint:(vec4_t)aPoint;
@end
