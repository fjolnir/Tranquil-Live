#import "Sphere.h"

@implementation Sphere

+ (Sphere *)sphereWithRadius:(GLMFloat)aRadius stacks:(int)aStacks slices:(int)aSlices useVBO:(BOOL)aUseVBO
{
    return [[[self alloc] initWithRadius:aRadius stacks:aStacks slices:aSlices useVBO:aUseVBO] autorelease];
}

- (id)initWithRadius:(GLMFloat)aRadius stacks:(int)aStacks slices:(int)aSlices useVBO:(BOOL)aUseVBO
{
	assert(aRadius>0);
	assert(aStacks>0 && aSlices>0);
	
	self = [super initWithVertexCapacity:aSlices*aStacks*6 indexCapacity:0 useVBO:aUseVBO];
	if(!self) return nil;
	
	self.renderMode = PolyPrimitiveRenderModeTriList;

	GLMFloat radsPerSeg = degToRad(360.0/(GLMFloat)aStacks);
	vec4_t color = self.state.color;
	for(int j = 0; j < aSlices; ++j) {
		GLMFloat scale[2],height[2],nheight[2];
		scale[0] = sinf(degToRad((j/(GLMFloat)aSlices)*180));
		scale[1] = sinf(degToRad(((j+1)/(GLMFloat)aSlices)*180));
		height[0] = cosf(degToRad((j/(GLMFloat)aSlices)*180)) * aRadius;
		height[1] = cosf(degToRad(((j+1)/(GLMFloat)aSlices)*180)) * aRadius;
		nheight[0] = cosf(degToRad((j/(GLMFloat)aSlices)*180)) * (aRadius+1.0f);
		nheight[1] = cosf(degToRad(((j+1)/(GLMFloat)aSlices)*180)) * (aRadius+1.0f);
		
		for(int i = 0; i < aStacks; ++i) {
			vec3_t point[2], npoint[2];
			point[0] = vec3_create(sinf(i*radsPerSeg)*aRadius, 0, cos(i*radsPerSeg)*aRadius);
			point[1] = vec3_create(sinf((i+1)*radsPerSeg)*aRadius, 0, cos((i+1)*radsPerSeg)*aRadius);
			npoint[0] = vec3_create(sinf(i*radsPerSeg)*(aRadius+1.0f), 0, cos(i*radsPerSeg)*(aRadius+1.0f));
			npoint[1] = vec3_create(sinf((i+1)*radsPerSeg)*(aRadius+1.0f), 0, cos((i+1)*radsPerSeg)*(aRadius+1.0f));
			
			vec3_t vertices[4], normals[4];
			vec2_t texCoords[4];
			
			vertices[0] = vec3_create(point[1].x*scale[0], height[0], point[1].z*scale[0]);
			vertices[1] = vec3_create(point[0].x*scale[1], height[1], point[0].z*scale[1]);
			vertices[2] = vec3_create(point[0].x*scale[0], height[0], point[0].z*scale[0]);
			vertices[3] = vec3_create(point[1].x*scale[1], height[1], point[1].z*scale[1]);

			normals[0] = vec3_normalize(vec3_sub(vec3_create(npoint[1].x*scale[0], nheight[0], npoint[1].z*scale[0]), vertices[0]));
			normals[1] = vec3_normalize(vec3_sub(vec3_create(npoint[0].x*scale[1], nheight[1], npoint[0].z*scale[1]), vertices[1]));
			normals[2] = vec3_normalize(vec3_sub(vec3_create(npoint[0].x*scale[0], nheight[0], npoint[0].z*scale[0]), vertices[2]));
			normals[3] = vec3_normalize(vec3_sub(vec3_create(npoint[1].x*scale[1], nheight[1], npoint[1].z*scale[1]), vertices[3]));

			texCoords[0] = vec2_create((i+1)/(GLMFloat)aStacks, j/(GLMFloat)aSlices);
			texCoords[1] = vec2_create(i/(GLMFloat)aStacks, (j+1)/(GLMFloat)aSlices);
			texCoords[2] = vec2_create(i/(GLMFloat)aStacks, j/(GLMFloat)aSlices);
			texCoords[3] = vec2_create((i+1)/(GLMFloat)aStacks, (j+1)/(GLMFloat)aSlices);

			[self addVertex:VertexCreate(vertices[2], normals[2], texCoords[2], color, 1, 1)];
			[self addVertex:VertexCreate(vertices[1], normals[1], texCoords[1], color, 1, 1)];
			[self addVertex:VertexCreate(vertices[0], normals[0], texCoords[0], color, 1, 1)];
			
			[self addVertex:VertexCreate(vertices[0], normals[0], texCoords[0], color, 1, 1)];
			[self addVertex:VertexCreate(vertices[1], normals[1], texCoords[1], color, 1, 1)];
			[self addVertex:VertexCreate(vertices[3], normals[3], texCoords[3], color, 1, 1)];
		}
	}
	
	return self;
}
@end
