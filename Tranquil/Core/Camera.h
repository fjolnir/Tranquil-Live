@interface Camera : NSObject {
@public
    mat4_t _matrix;
}
@property(readwrite, assign) vec3_t position;
@property(readwrite, assign) quat_t orientation;
@property(readwrite, assign) GLMFloat fov, zoom, aspectRatio;
@property(readwrite) mat4_t matrix;
+ (vec4_t)viewportSize;

- (void)updateMatrix;
// Takes a point in screen space and un-projects it back into world space
- (vec3_t)unProjectPoint:(vec3_t)aPoint;
@end
