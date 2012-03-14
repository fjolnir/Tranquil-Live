@interface Camera : NSObject {
@public
    mat4_t _matrix;
}
@property(readwrite, assign) vec4_t position;
@property(readwrite, assign) quat_t orientation;
@property(readwrite, assign) GLMFloat fov, zoom, aspectRatio;
@property(readonly) mat4_t matrix;
+ (vec4_t)viewportSize;

- (void)updateMatrix;
// Takes a point in screen space and un-projects it back into world space
- (vec4_t)unProjectPoint:(vec4_t)aPoint;
@end
