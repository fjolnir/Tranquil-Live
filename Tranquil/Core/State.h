// Just a container for the render state of an object
#import <TranquilCore/GLMathWrapper.h>

@class Scene, Shader, Texture;

@interface State : NSObject {
@public
    Matrix4 *_transform;
}
@property(readwrite, assign) Matrix4 *transform;
@property(readwrite, assign) Vector4 *ambientLight;
@property(readwrite, assign) Vector4 *color;
@property(readwrite, assign) float shininess;
@property(readwrite, assign) float opacity;
@property(readwrite, assign) float lineWidth;
@property(readwrite, assign) float pointRadius;
@property(readwrite, retain) Shader *shader;
@property(readwrite, retain) Texture *texture;

@property(readwrite, assign) BOOL drawWireframe, drawNormals, drawPoints, antiAlias, drawOrigin, ignoreDepth, noZWrite, cullBackFace, unlit;

- (void)applyToScene:(Scene *)aScene;
- (void)unapplyToScene:(Scene *)aScene;
@end
