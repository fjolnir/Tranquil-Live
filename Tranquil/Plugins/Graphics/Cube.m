#import "Cube.h"
#import <TranquilCore/TranquilCore.h>

@implementation Cube
- (id)init
{
	return [self initWithSize:1.0];
}
- (id)initWithSize:(GLMFloat)size
{
	self = [super initWithVertexCapacity:6*2*3 indexCapacity:0];
	if(!self) return nil;
	

	self.renderMode = kPolyPrimitiveRenderModeTriList;
	
	// Initialize with a white cube extending 1 unit on each axis	
	vec4_t rbb = {  size, -size, -size, 1 };
	vec4_t rtb = {  size,  size, -size, 1 };
	vec4_t ltb = { -size,  size, -size, 1 };
	vec4_t lbb = { -size, -size, -size, 1 };
	vec4_t rbf = {  size, -size,  size, 1 };
	vec4_t rtf = {  size,  size,  size, 1 };
	vec4_t ltf = { -size,  size,  size, 1 };
	vec4_t lbf = { -size, -size,  size, 1 };
	vec2_t t_lb = { 0, 0 };
	vec2_t t_rb = { 1, 0 };
	vec2_t t_rt = { 1, 1 };
	vec2_t t_lt = { 0, 1 };
	vec4_t color = self.state.color;

	vec4_t normal;
	normal = vec4_create(0, 0, -1, 0);
	[self addVertex:VertexCreate(lbb, normal, t_lb, color, 1, 1)];
	[self addVertex:VertexCreate(ltb, normal, t_lt, color, 1, 1)];
	[self addVertex:VertexCreate(rtb, normal, t_rt, color, 1, 1)];
	[self addVertex:VertexCreate(rtb, normal, t_rt, color, 1, 1)];
	[self addVertex:VertexCreate(rbb, normal, t_rb, color, 1, 1)];
	[self addVertex:VertexCreate(lbb, normal, t_lb, color, 1, 1)];

	normal = vec4_create(0, -1, 0, 0);
	[self addVertex:VertexCreate(lbf, normal, t_lt, color, 1, 1)];
	[self addVertex:VertexCreate(lbb, normal, t_lb, color, 1, 1)];
	[self addVertex:VertexCreate(rbb, normal, t_rb, color, 1, 1)];
	[self addVertex:VertexCreate(rbb, normal, t_rb, color, 1, 1)];
	[self addVertex:VertexCreate(rbf, normal, t_rt, color, 1, 1)];
	[self addVertex:VertexCreate(lbf, normal, t_lt, color, 1, 1)];

	normal = vec4_create(-1, 0, 0, 0);
	[self addVertex:VertexCreate(lbf, normal, t_rb, color, 1, 1)];
	[self addVertex:VertexCreate(ltf, normal, t_rt, color, 1, 1)];
	[self addVertex:VertexCreate(ltb, normal, t_lt, color, 1, 1)];
	[self addVertex:VertexCreate(ltb, normal, t_lt, color, 1, 1)];
	[self addVertex:VertexCreate(lbb, normal, t_lb, color, 1, 1)];
	[self addVertex:VertexCreate(lbf, normal, t_rb, color, 1, 1)];
	
	normal = vec4_create(0, 0, 1, 0);
	[self addVertex:VertexCreate(lbf, normal, t_lb, color, 1, 1)];
	[self addVertex:VertexCreate(rbf, normal, t_rb, color, 1, 1)];
	[self addVertex:VertexCreate(rtf, normal, t_rt, color, 1, 1)];
	[self addVertex:VertexCreate(rtf, normal, t_rt, color, 1, 1)];
	[self addVertex:VertexCreate(ltf, normal, t_lt, color, 1, 1)];
	[self addVertex:VertexCreate(lbf, normal, t_lb, color, 1, 1)];
	
	normal = vec4_create(0, 1, 0, 0);
	[self addVertex:VertexCreate(ltf, normal, t_lb, color, 1, 1)];
	[self addVertex:VertexCreate(rtf, normal, t_rb, color, 1, 1)];
	[self addVertex:VertexCreate(rtb, normal, t_rt, color, 1, 1)];
	[self addVertex:VertexCreate(rtb, normal, t_rt, color, 1, 1)];
	[self addVertex:VertexCreate(ltb, normal, t_lt, color, 1, 1)];
	[self addVertex:VertexCreate(ltf, normal, t_lb, color, 1, 1)];

	normal = vec4_create(1, 0, 0, 0);
	[self addVertex:VertexCreate(rbf, normal, t_lb, color, 1, 1)];
	[self addVertex:VertexCreate(rbb, normal, t_rb, color, 1, 1)];
	[self addVertex:VertexCreate(rtb, normal, t_rt, color, 1, 1)];
	[self addVertex:VertexCreate(rtb, normal, t_rt, color, 1, 1)];
	[self addVertex:VertexCreate(rtf, normal, t_lt, color, 1, 1)];
	[self addVertex:VertexCreate(rbf, normal, t_lb, color, 1, 1)];
	
	return self;
}

@end

