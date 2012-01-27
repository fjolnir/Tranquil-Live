// Just a container for the render state of an object
#import <GLMath.h>

@class TScene, TShader;

typedef enum {
	kTRenderHintNone         = 0x00000000,
	kTRenderHintWireframe    = 0x00000001,
	kTRenderHintDrawNormals  = 0x00000002,
	kTRenderHintPoint        = 0x00000004,
	kTRenderHintAAlias       = 0x00000008,
	kTRenderHintDrawBBox     = 0x00000010,
	kTRenderHintUnlit        = 0x00000020,
	kTRenderHintVertexColors = 0x00000040,
	kTRenderHintDrawOrigin   = 0x00000080,
	kTRenderHintCastShadow   = 0x00000100,
	kTRenderHintIgnoreDepth  = 0x00000200,
	kTRenderHintNoZWrite     = 0x00000400,
	kTRenderHintCullBack     = 0x00000800
} TRenderHint;

__attribute__((visibility("default"))) @interface TState : NSObject
@property(readwrite, assign) Matrix4 *transform;
@property(readwrite, assign) Vector4 *ambientLight;
@property(readwrite, assign) float shininess;
@property(readwrite, assign) float opacity;
@property(readwrite, assign) float lineWidth;
@property(readwrite, assign) float pointRadius;
@property(readwrite, retain) TShader *shader;
@property(readwrite, assign) TRenderHint renderHint;

- (void)applyToScene:(TScene *)aScene;
- (void)unapplyToScene:(TScene *)aScene;
@end
