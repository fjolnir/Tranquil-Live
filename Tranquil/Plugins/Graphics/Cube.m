#import "Cube.h"
#import <TranquilCore/TranquilCore.h>

@implementation Cube
    
+ (Cube *)cubeWithSize:(GLMFloat)aSize useVBO:(BOOL)aUseVBO
{
    return [[(Cube*)[self alloc] initWithSize:aSize useVBO:aUseVBO] autorelease];
}

- (id)init
{
	return [self initWithSize:1.0 useVBO:YES];
}
- (id)initWithSize:(GLMFloat)size useVBO:(BOOL)aUseVBO
{
	self = [super initWithVertexCapacity:6*2*3 indexCapacity:0 useVBO:aUseVBO];
	if(!self) return nil;
	

	self.renderMode = PolyPrimitiveRenderModeTriList;
	
	// Initialize with a white cube extending 1 unit on each axis	
	vec3_t rbb = {  size, -size, -size };
	vec3_t rtb = {  size,  size, -size };
	vec3_t ltb = { -size,  size, -size };
	vec3_t lbb = { -size, -size, -size };
	vec3_t rbf = {  size, -size,  size };
	vec3_t rtf = {  size,  size,  size };
	vec3_t ltf = { -size,  size,  size };
	vec3_t lbf = { -size, -size,  size };
	vec2_t t_lb = { 0, 0 };
	vec2_t t_rb = { 1, 0 };
	vec2_t t_rt = { 1, 1 };
	vec2_t t_lt = { 0, 1 };
	vec4_t color = self.state.color.vec;

	vec3_t normal;
	normal = vec3_create(0, 0, -1);
	[self addVertex:VertexCreate(lbb, normal, t_lb, color, 1, 1)];
	[self addVertex:VertexCreate(ltb, normal, t_lt, color, 1, 1)];
	[self addVertex:VertexCreate(rtb, normal, t_rt, color, 1, 1)];
	[self addVertex:VertexCreate(rtb, normal, t_rt, color, 1, 1)];
	[self addVertex:VertexCreate(rbb, normal, t_rb, color, 1, 1)];
	[self addVertex:VertexCreate(lbb, normal, t_lb, color, 1, 1)];

	normal = vec3_create(0, -1, 0);
	[self addVertex:VertexCreate(lbf, normal, t_lt, color, 1, 1)];
	[self addVertex:VertexCreate(lbb, normal, t_lb, color, 1, 1)];
	[self addVertex:VertexCreate(rbb, normal, t_rb, color, 1, 1)];
	[self addVertex:VertexCreate(rbb, normal, t_rb, color, 1, 1)];
	[self addVertex:VertexCreate(rbf, normal, t_rt, color, 1, 1)];
	[self addVertex:VertexCreate(lbf, normal, t_lt, color, 1, 1)];

	normal = vec3_create(-1, 0, 0);
	[self addVertex:VertexCreate(lbf, normal, t_rb, color, 1, 1)];
	[self addVertex:VertexCreate(ltf, normal, t_rt, color, 1, 1)];
	[self addVertex:VertexCreate(ltb, normal, t_lt, color, 1, 1)];
	[self addVertex:VertexCreate(ltb, normal, t_lt, color, 1, 1)];
	[self addVertex:VertexCreate(lbb, normal, t_lb, color, 1, 1)];
	[self addVertex:VertexCreate(lbf, normal, t_rb, color, 1, 1)];
	
	normal = vec3_create(0, 0, 1);
	[self addVertex:VertexCreate(lbf, normal, t_lb, color, 1, 1)];
	[self addVertex:VertexCreate(rbf, normal, t_rb, color, 1, 1)];
	[self addVertex:VertexCreate(rtf, normal, t_rt, color, 1, 1)];
	[self addVertex:VertexCreate(rtf, normal, t_rt, color, 1, 1)];
	[self addVertex:VertexCreate(ltf, normal, t_lt, color, 1, 1)];
	[self addVertex:VertexCreate(lbf, normal, t_lb, color, 1, 1)];
	
	normal = vec3_create(0, 1, 0);
	[self addVertex:VertexCreate(ltf, normal, t_lb, color, 1, 1)];
	[self addVertex:VertexCreate(rtf, normal, t_rb, color, 1, 1)];
	[self addVertex:VertexCreate(rtb, normal, t_rt, color, 1, 1)];
	[self addVertex:VertexCreate(rtb, normal, t_rt, color, 1, 1)];
	[self addVertex:VertexCreate(ltb, normal, t_lt, color, 1, 1)];
	[self addVertex:VertexCreate(ltf, normal, t_lb, color, 1, 1)];

	normal = vec3_create(1, 0, 0);
	[self addVertex:VertexCreate(rbf, normal, t_lb, color, 1, 1)];
	[self addVertex:VertexCreate(rbb, normal, t_rb, color, 1, 1)];
	[self addVertex:VertexCreate(rtb, normal, t_rt, color, 1, 1)];
	[self addVertex:VertexCreate(rtb, normal, t_rt, color, 1, 1)];
	[self addVertex:VertexCreate(rtf, normal, t_lt, color, 1, 1)];
	[self addVertex:VertexCreate(rbf, normal, t_lb, color, 1, 1)];
	
	return self;
}

@end

