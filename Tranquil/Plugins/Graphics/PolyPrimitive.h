#import <OpenGL/gl.h>
#import <TranquilCore/TranquilCore.h>

@class State;

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
} Vertex_t;

static __inline__ Vertex_t VertexCreate(vec4_t aPos, vec4_t aNormal, vec2_t aTexCoord, vec4_t aColor, float aSize, float aShininess) {
	Vertex_t out = { .position=aPos, .normal=aNormal, .color=aColor, .texCoord=aTexCoord, .size=aSize, .shininess=aShininess };
	return out;
}

typedef enum {
	kPolyPrimitiveRenderModeTriStrip = GL_TRIANGLE_STRIP,
	kPolyPrimitiveRenderModeTriFan = GL_TRIANGLE_FAN,
	kPolyPrimitiveRenderModeTriList = GL_TRIANGLES,
	kPolyPrimitiveRenderModePoints = GL_POINTS
} PolyPrimitiveRenderMode;

typedef Vertex_t (^VertexMappingBlock)(NSUInteger aIndex, Vertex_t aVertex);

@interface PolyPrimitive : NSObject <SceneObject>
@property(readonly) GLuint vertexBuffer, indexBuffer;
@property(readwrite, assign, nonatomic) Vertex_t *vertices;
@property(readwrite, assign, nonatomic) GLuint *indices;
@property(readwrite, assign, nonatomic) int vertexCount, vertexCapacity, indexCount, indexCapacity;
@property(readonly) BOOL usesIndices;
@property(readwrite, assign, nonatomic) PolyPrimitiveRenderMode renderMode;
@property(readwrite, retain, nonatomic) State *state;
@property(readonly, nonatomic) BOOL isValid;
@property(readwrite, assign, nonatomic) BOOL useVBO;

- (id)initWithVertexCapacity:(int)aVertexCapacity indexCapacity:(int)aIndexCapacity;

- (void)addVertex:(Vertex_t)aVertex;
- (void)clear;

// Frees the VBOs & data for this primitive. rendering it unusable
- (void)invalidate;

- (void)recomputeNormals:(BOOL)aSmooth;
@end

