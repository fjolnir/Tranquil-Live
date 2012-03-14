// Just a container for the render state of an object
#import <GLMath/GLMath.h>

@class Scene, Shader, Texture;

@interface State : NSObject {
@public
    mat4_t _transform;
}
@property(readwrite, assign) mat4_t transform;
@property(readwrite, assign) vec4_t ambientLight;
@property(readwrite, assign) vec4_t color;
@property(readwrite, assign) GLMFloat shininess;
@property(readwrite, assign) GLMFloat opacity;
@property(readwrite, assign) GLMFloat lineWidth;
@property(readwrite, assign) GLMFloat pointRadius;
@property(readwrite, retain) Shader *shader;
@property(readwrite, retain) Texture *texture;

@property(readwrite, assign) BOOL drawWireframe, drawNormals, drawPoints, antiAlias, drawOrigin, ignoreDepth, noZWrite, cullBackFace, unlit;

- (void)applyToScene:(Scene *)aScene;
- (void)unapplyToScene:(Scene *)aScene;
@end
