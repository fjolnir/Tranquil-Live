#import "Particles.h"

@implementation Particles

- (id)initWithCount:(NSUInteger)aCount
{
    if(!(self = [super initWithVertexCapacity:aCount indexCapacity:0]))
       return nil;
    
    // Zero all the vertices, the position is set by using mapVertices
    memset(self.vertices, 0, sizeof(Vertex_t)*aCount);
    self.renderMode = kPolyPrimitiveRenderModePoints;
    self.vertexCount = aCount;
    
    return self;
}

- (void)render:(Scene *)aScene
{
    glEnable(GL_POINT_SPRITE);
    [super render:aScene];
    glDisable(GL_POINT_SPRITE);
}

@end
