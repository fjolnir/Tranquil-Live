#include <GLMath.h>
@interface TCamera : NSObject
@property(readwrite, assign) vec4_t position;
@property(readwrite, assign) quat_t orientation;
@property(readwrite, assign) float fov, zoom, aspectRatio;
@property(readonly) mat4_t matrix;

- (void)updateMatrix;
@end
