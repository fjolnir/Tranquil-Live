#import "Sphere.h"
#import "State.h"

@implementation Sphere
- (id)initWithRadius:(float)aRadius stacks:(int)aStacks slices:(int)aSlices
{
	assert(aRadius>0);
	assert(aStacks>0 && aSlices>0);
	
	self = [super initWithVertexCapacity:aSlices*aStacks*6 indexCapacity:0];
	if(!self) return nil;
	
	self.renderMode = kPolyPrimitiveRenderModeTriList;

	float radsPerSeg = degToRad(360.0/(float)aStacks);
	vec4_t color = self.state.color.vec;
	for(int j = 0; j < aSlices; ++j) {
		float scale[2],height[2],nheight[2];
		scale[0] = sin(degToRad((j/(float)aSlices)*180));
		scale[1] = sin(degToRad(((j+1)/(float)aSlices)*180));
		height[0] = cos(degToRad((j/(float)aSlices)*180)) * aRadius;
		height[1] = cos(degToRad(((j+1)/(float)aSlices)*180)) * aRadius;
		nheight[0] = cos(degToRad((j/(float)aSlices)*180)) * (aRadius+1.0f);
		nheight[1] = cos(degToRad(((j+1)/(float)aSlices)*180)) * (aRadius+1.0f);
		
		for(int i = 0; i < aStacks; ++i) {
			vec3_t point[2], npoint[2];
			point[0] = vec3_create(sinf(i*radsPerSeg)*aRadius, 0, cos(i*radsPerSeg)*aRadius);
			point[1] = vec3_create(sinf((i+1)*radsPerSeg)*aRadius, 0, cos((i+1)*radsPerSeg)*aRadius);
			npoint[0] = vec3_create(sinf(i*radsPerSeg)*(aRadius+1.0f), 0, cos(i*radsPerSeg)*(aRadius+1.0f));
			npoint[1] = vec3_create(sinf((i+1)*radsPerSeg)*(aRadius+1.0f), 0, cos((i+1)*radsPerSeg)*(aRadius+1.0f));
			
			vec4_t vertices[4], normals[4];
			vec2_t texCoords[4];
			
			vertices[0] = vec4_create(point[1].x*scale[0], height[0], point[1].z*scale[0], 1);
			vertices[1] = vec4_create(point[0].x*scale[1], height[1], point[0].z*scale[1], 1);
			vertices[2] = vec4_create(point[0].x*scale[0], height[0], point[0].z*scale[0], 1);
			vertices[3] = vec4_create(point[1].x*scale[1], height[1], point[1].z*scale[1], 1);

			normals[0] = vec4_normalize(vec4_sub(vec4_create(npoint[1].x*scale[0], nheight[0], npoint[1].z*scale[0], 1), vertices[0]));
			normals[1] = vec4_normalize(vec4_sub(vec4_create(npoint[0].x*scale[1], nheight[1], npoint[0].z*scale[1], 1), vertices[1]));
			normals[2] = vec4_normalize(vec4_sub(vec4_create(npoint[0].x*scale[0], nheight[0], npoint[0].z*scale[0], 1), vertices[2]));
			normals[3] = vec4_normalize(vec4_sub(vec4_create(npoint[1].x*scale[1], nheight[1], npoint[1].z*scale[1], 1), vertices[3]));

			texCoords[0] = vec2_create((i+1)/(float)aStacks, j/(float)aSlices);
			texCoords[1] = vec2_create(i/(float)aStacks, (j+1)/(float)aSlices);
			texCoords[2] = vec2_create(i/(float)aStacks, j/(float)aSlices);
			texCoords[3] = vec2_create((i+1)/(float)aStacks, (j+1)/(float)aSlices);

			[self addVertex:TVertexCreate(vertices[2], normals[2], texCoords[2], color, 1, 1)];
			[self addVertex:TVertexCreate(vertices[1], normals[1], texCoords[1], color, 1, 1)];
			[self addVertex:TVertexCreate(vertices[0], normals[0], texCoords[0], color, 1, 1)];
			
			[self addVertex:TVertexCreate(vertices[0], normals[0], texCoords[0], color, 1, 1)];
			[self addVertex:TVertexCreate(vertices[1], normals[1], texCoords[1], color, 1, 1)];
			[self addVertex:TVertexCreate(vertices[3], normals[3], texCoords[3], color, 1, 1)];
		}
	}
	
	return self;
}
@end
