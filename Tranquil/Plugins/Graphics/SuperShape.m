#import "SuperShape.h"
#import "PolyPrimitive.h"

@interface SuperShape () {
    Vertex_t *_vertices;
    unsigned _vertexCount;
    GLuint *_indices;
    unsigned _indexCount;
    
    // Computed from _step, (using _step directly isn't precise)
    unsigned _vRes, _hRes;
    float _vStep, _hStep;
}
@end

@implementation SuperShape
@synthesize ss1a=_ss1a, ss1b=_ss1b, ss1m=_ss1m, ss1n1=_ss1n1, ss1n2=_ss1n2, ss1n3=_ss1n3, ss2a=_ss2a, ss2b=_ss2b, ss2m=_ss2m, ss2n1=_ss2n1, ss2n2=_ss2n2, ss2n3=_ss2n3, step=_step, state=_state;

- (id)init
{
    if(!(self = [super init]))
        return nil;
    
    _state = [GlobalState() copy];
    _vertices = NULL;
    _vertexCount = 0;
    self.step = 0.05;
    
    return self;
}

- (void)invalidate
{
}

- (void)dealloc
{
    [_state release];
    free(_vertices);
    [super dealloc];
}

- (void)setStep:(float)aStep
{
    _step = aStep;
    
    _hRes = (unsigned)(2.0*M_PI/_step);
    _vRes = (unsigned)(M_PI/_step);
    _hStep = 2.0*M_PI / (float)(_hRes-1);
    _vStep = M_PI / (float)(_vRes-1);
    
    _vertexCount = _vRes*_hRes;
    _indexCount = 2*_vRes*(_hRes-1);
    
    if(!_vertices) {
        _vertices = calloc(_vertexCount, sizeof(Vertex_t));
        _indices = calloc(_indexCount, sizeof(GLuint));
    } else {
        _vertices = realloc(_vertices, sizeof(Vertex_t)*_vertexCount);
        _indices = realloc(_indices, sizeof(GLuint)*_indexCount);
    }
}

- (void)render:(Scene *)aScene
{    
    // Generate the vertices
    unsigned i = 0;
    float theta, phi;
    theta = -M_PI;
    
    for(unsigned x = 0; x < _hRes; ++x) {
        phi = -M_PI_2;
        for(unsigned y = 0; y < _vRes; ++y) {
            
            Vertex_t *v = &_vertices[i++];
            float l,r;
            // Calculate shape 1
            l = fastPow(fabsf((1.0f/_ss1a)*cosf(_ss1m*theta/4.0f)), _ss1n2);
            r = fastPow(fabsf((1.0f/_ss1b)*sinf(_ss1m*theta/4.0f)), _ss1n3);
            float r1 = fastPow(l+r, -1.0f/_ss1n1);
            
            // Calculate shape 2
            l = fastPow(fabsf((1.0f/_ss2a)*cosf(_ss2m*phi/4.0f)), _ss2n2);
            r = fastPow(fabsf((1.0f/_ss2b)*sinf(_ss2m*phi/4.0f)), _ss2n3);
            float r2 = fastPow(l+r, -1.0f/_ss2n1);
            
            float cosPhi = cosf(phi);
            v->position.x = r1*cosf(theta)*r2*cosPhi;
            v->position.y = r1*sinf(theta)*r2*cosPhi;
            v->position.z = r2*sinf(phi);
            v->position.w = 1;
            
            v->texCoord = vec2_create((theta+M_PI)/(2.0*M_PI), (phi+M_PI_2)/M_PI);
            v->color = vec4_create(1, 0, 0, 1);
            v->size = 1.0;
            v->normal = GLMVec4_zero;
            v->shininess = 0.3;
            
            // = eval(self, theta, phi);
            phi += _vStep;
        }
        theta += _hStep;
    }
//    NSLog(@"step: %f theta(%f): %f (d:%f) step: %f phi(%f): %f", hstep, M_PI, theta,M_PI-theta, vstep, M_PI_2, phi);
    
    // Generate the indices
    i = 0;
    for(unsigned x = 0; x < _hRes-1; ++x) {
        for(unsigned y = 0; y < _vRes; ++y) {
            _indices[i++] = x*_vRes + y;
            _indices[i++] = (x+1)*_vRes + y;
            
            Vertex_t *vert1 = &_vertices[x*_vRes + y];
            Vertex_t *vert2 = &_vertices[(x+1)*_vRes + y];
            Vertex_t *vert3 = &_vertices[x*_vRes + y+1];
            
            if(y == 0) {
                vert1->normal = vec4_create(0, 0, -1, 0);
            } else if(y == _vRes-1) {
                vert1->normal = vec4_create(0, 0, 1, 0);
            } else {
                vec4_t v1 = vec4_sub(vert2->position, vert1->position);
                vec4_t v2 = vec4_sub(vert3->position, vert1->position);
                vert1->normal = vec4_normalize(vec4_cross(v1, v2));
                vert2->normal = vert1->normal;
            }
        }
    }
    for(i = 0; i < _vertexCount; ++i) {
        _vertices[i].normal = vec4_normalize(_vertices[i].normal);
        _vertices[i].color = _vertices[i].normal;
        _vertices[i].color.a = 1;
        _vertices[i].normal.w = 0;
    }
    
	[_state applyToScene:aScene];
    void *baseOffset = _vertices;
    
	Shader *shader = _state.shader;
	if(!shader) {
		TLog(@"No shader");
		return;
	}
	[shader withAttribute:@"a_position" do:^(GLuint loc) {
		glEnableVertexAttribArray(loc);
		glVertexAttribPointer(loc, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex_t), (void*)(baseOffset+offsetof(Vertex_t, position)));
	}];
	[shader withAttribute:@"a_normal" do:^(GLuint loc) {
		glEnableVertexAttribArray(loc);
		glVertexAttribPointer(loc, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex_t), (void*)(baseOffset+offsetof(Vertex_t, normal)));
	}];
	[shader withAttribute:@"a_color" do:^(GLuint loc) {
		glEnableVertexAttribArray(loc);
		glVertexAttribPointer(loc, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex_t), (void*)(baseOffset+offsetof(Vertex_t, color)));
	}];
	[shader withAttribute:@"a_texCoord" do:^(GLuint loc) {
		glEnableVertexAttribArray(loc);
		glVertexAttribPointer(loc, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex_t), (void*)(baseOffset+offsetof(Vertex_t, texCoord)));
	}];
    [shader withAttribute:@"a_size" do:^(GLuint loc) {
		glEnableVertexAttribArray(loc);
		glVertexAttribPointer(loc, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex_t), (void*)(baseOffset+offsetof(Vertex_t, size)));
	}];
    [shader withAttribute:@"a_shininess" do:^(GLuint loc) {
		glEnableVertexAttribArray(loc);
		glVertexAttribPointer(loc, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex_t), (void*)(baseOffset+offsetof(Vertex_t, shininess)));
	}];
    
    TCheckGLError();

    glDrawElements(GL_QUAD_STRIP, _indexCount, GL_UNSIGNED_INT, _indices);
//    glPointSize(6);
//    glDrawArrays(GL_POINTS, 0, _vertexCount);
    TCheckGLError();
    
	[_state unapplyToScene:aScene];
}


@end
