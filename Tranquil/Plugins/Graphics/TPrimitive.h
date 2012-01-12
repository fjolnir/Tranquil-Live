#import <OpenGL/gl.h>
#import <GLMath.h>
#import "TScene.h"

@class TState;

typedef union {
	float f[16];
	struct {
		vec4_t position;
		vec4_t normal;
		vec4_t color;
		vec2_t texCoord;
		float size;
		float shininess;
	};
} TVertex_t;

static __inline__ TVertex_t TVertexCreate(vec4_t aPos, vec4_t aNormal, vec2_t aTexCoord, vec4_t aColor, float aSize, float aShininess) {
	TVertex_t out = { .position=aPos, .normal=aNormal, .color=aColor, .texCoord=aTexCoord, .size=aSize, .shininess=aShininess };
	return out;
}

typedef enum {
	kTPrimitiveRenderModeTriStrip = GL_TRIANGLE_STRIP,
	kTPrimitiveRenderModeTriFan = GL_TRIANGLE_FAN,
	kTPrimitiveRenderModeTriList = GL_TRIANGLES,
	kTPrimitiveRenderModePoints = GL_POINTS
} TPrimitiveRenderMode;

@interface TPrimitive : NSObject <TSceneObject>
@property(readonly) GLuint vertexBuffer, indexBuffer;
@property(readwrite, assign, nonatomic) TVertex_t *vertices;
@property(readwrite, assign, nonatomic) GLuint *indices;
@property(readwrite, assign, nonatomic) int vertexCount, vertexCapacity, indexCount, indexCapacity;
@property(readwrite, assign, nonatomic) BOOL usesIndices;
@property(readwrite, assign, nonatomic) TPrimitiveRenderMode renderMode;
@property(readwrite, retain, nonatomic) TState *state;

- (id)initWithVertexCapacity:(int)aVertexCapacity indexCapacity:(int)aIndexCapacity;

// You should never call this method directly, only override it in subclasses.
// It will be called automatically when the primitive needs to be rendered.
- (void)drawInScene:(TScene *)aScene;

- (void)addVertex:(TVertex_t)aVertex;
- (void)clear;

- (void)recomputeNormals:(BOOL)aSmooth;
@end

