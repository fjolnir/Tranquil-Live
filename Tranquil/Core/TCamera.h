#import "GLMathWrapper.h"

__attribute__((visibility("default"))) @interface TCamera : NSObject
@property(readwrite, assign) Vector4 *position;
@property(readwrite, assign) Quaternion *orientation;
@property(readwrite, assign) float fov, zoom, aspectRatio;
@property(readonly) Matrix4 *matrix;

- (void)updateMatrix;
// Takes a point in screen space and un-projects it back into world space
- (Vector4 *)unProjectPoint:(Vector4 *)aPoint;
@end
