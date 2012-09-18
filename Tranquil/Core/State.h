// Just a container for the render state of an object
#import <GLMath/GLMath.h>

@class Scene, Shader, Texture, TQNumber, Vec4, Mat4;

@interface State : NSObject {
@public
    Mat4 *_transform;
}
@property(readwrite, copy) Mat4 *transform;
@property(readwrite, copy) Vec4 *ambientLight;
@property(readwrite, copy) Vec4 *color;
@property(readwrite, copy) TQNumber *shininess;
@property(readwrite, copy) TQNumber *opacity;
@property(readwrite, copy) TQNumber *lineWidth;
@property(readwrite, copy) TQNumber *pointRadius;
@property(readwrite, retain) Shader *shader;
@property(readwrite, retain) Texture *texture;

@property(readwrite, assign) BOOL drawWireframe, drawNormals, drawPoints, antiAlias, drawOrigin, ignoreDepth, noZWrite, cullBackFace, unlit;

- (void)applyToScene:(Scene *)aScene;
- (void)unapplyToScene:(Scene *)aScene;
@end
