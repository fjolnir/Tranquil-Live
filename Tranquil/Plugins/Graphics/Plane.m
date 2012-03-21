#import "Plane.h"

@implementation Plane

+ (Plane *)planeWithCols:(int)uDiv rows:(int)vDiv useVBO:(BOOL)aUseVBO
{
    return [[[self alloc] initWithCols:uDiv rows:vDiv useVBO:aUseVBO] autorelease];
}

- (id)initWithCols:(int)uDiv rows:(int)vDiv useVBO:(BOOL)aUseVBO
{
	assert(uDiv>0 && vDiv>0);
	
	self = [super initWithVertexCapacity:(uDiv*vDiv) + (uDiv-1)*(vDiv-1) indexCapacity:0 useVBO:aUseVBO];
	if(!self) return nil;
	
	self.renderMode = PolyPrimitiveRenderModeTriStrip;
	
	// Build the vertex list
	Vertex_t verts[uDiv*vDiv];
	vec4_t pos, color, normal;
	color = self.state.color;
	normal = vec4_create(0, 1, 0, 0);
	int i = 0;
	for(int v = 0; v < vDiv; ++v) {
		for(int u = 0; u < uDiv; ++u) {
			pos = vec4_create((2.0f*(GLMFloat)u/(uDiv-1))-1.0f, 0.0, 2.0f*((GLMFloat)v/(vDiv-1))-1.0, 1);
			verts[i++] = VertexCreate(pos, normal, vec2_create(pos.x, pos.y), color, 1, 1);
		}
	}
	// Build the triangle strip (We're not using indices because we want deforming to be easy)
	for(int v = 0; v < vDiv-1; ++v) {
		if((v&1) == 0) { // Even
			for(int u = 0; u < uDiv; ++u) {
				[self addVertex:verts[u + v*uDiv]];
				[self addVertex:verts[u + (v+1)*uDiv]];
			}
		} else { // Odd
			for(int u = uDiv-1; u > 0; --u) {
				[self addVertex:verts[u + (v+1)*uDiv]];
				[self addVertex:verts[u-1 + v*uDiv]];
			}
		}							  
	}
	if((vDiv&1) && vDiv > 2)
		[self addVertex:verts[(vDiv-1) * uDiv]];
	
	return self;
}
@end
