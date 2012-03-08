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

    // By default, disable depth buffer writes
    self.state.ignoreDepth = YES;
    
    return self;
}

- (void)render:(Scene *)aScene
{
    glEnable(GL_POINT_SPRITE);
    glEnable(GL_VERTEX_PROGRAM_POINT_SIZE);
    glTexEnvi(GL_POINT_SPRITE, GL_COORD_REPLACE, GL_TRUE);
    [super render:aScene];
    glDisable(GL_VERTEX_PROGRAM_POINT_SIZE);
    glDisable(GL_POINT_SPRITE);
}

@end
