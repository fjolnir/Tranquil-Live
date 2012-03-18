#import "PolyPrimitive.h"

@interface PolyPrimitive () {
	int _vertexCapacity, _indexCapacity;
}
- (void)_deleteVBO;
@end

@implementation PolyPrimitive {
@private
    BOOL _useVBO;
}

@synthesize vertexBuffer=_vertexBuffer, indexBuffer=_indexBuffer, vertices=_vertices, vertexCapacity=_vertexCapacity,
	indices=_indices, indexCapacity=_indexCapacity, vertexCount=_vertexCount, indexCount=_indexCount,
	usesIndices=_usesIndices, renderMode=_renderMode, state=_state, isValid=_isValid;
@synthesize useVBO = _useVBO;


- (id)initWithVertexCapacity:(int)aVertexCapacity indexCapacity:(int)aIndexCapacity
{
	self = [super init];
	if(!self) return nil;

	_state = [GlobalState() copy];
    _isValid = YES;

	_vertexCount = 0;
	_indexCount = 0;
	_vertices = NULL;
	_indices = NULL;

    _vertexBuffer = 0;
    _indexBuffer = 0;
    _usesIndices = aIndexCapacity > 0;
    _useVBO = NO;
    [self setVertexCapacity:aVertexCapacity];
    [self setIndexCapacity:aIndexCapacity];
	return self;
}

- (void)_deleteVBO
{
    [GlobalGLContext() makeCurrentContext];
	GLuint buffers[] = { _indexBuffer, _vertexBuffer };
	glDeleteBuffers(2, buffers);
    _indexBuffer = _vertexBuffer = 0;
    TCheckGLError();
}

- (void)setUseVBO:(BOOL)aUseVBO
{
    _useVBO = aUseVBO;
    if(!_useVBO)
        [self _deleteVBO];
}

- (void)invalidate
{
    if(!_isValid)
        return;
    _isValid = NO;

    if(_useVBO)
    	[self _deleteVBO];
	free(_vertices);
	free(_indices);
}

- (void)finalize
{
    [self invalidate];

	[super finalize];
}

#pragma mark - Rendering

// This should only be called after drawing (if you are going to draw) since it messes up the shader state
- (void)drawNormals:(Scene *)aScene
{
	Shader *shader = [aScene currentState].shader;
	[shader withUniform:@"u_globalAmbientColor" do:^(GLuint loc) {
        float white[4] = { 1, 1, 1, 1 };
		glUniform4fv(loc, 1, white);
	}];
	[shader withUniform:@"u_lightCount" do:^(GLuint loc) {
		glUniform1i(loc, 0);
	}];
	int count = 2*_vertexCount;
	vec4_t *points, *colors;
	points = malloc(sizeof(vec4_t)*count);
	colors = malloc(sizeof(vec4_t)*count);
	for(int i = 0; i < _vertexCount; ++i) {
		points[2*i] = _vertices[i].position;
		points[2*i+1] = vec4_add(_vertices[i].position, vec4_scalarMul(_vertices[i].normal, 0.5f));
		colors[2*i] = vec4_create(1, 0, 0, 1);
		colors[2*i+1] = colors[2*i];
	}
	[shader withAttribute:@"a_position" do:^(GLuint loc) {
		glEnableVertexAttribArray(loc);
		glVertexAttribPointer(loc, 4, GL_DOUBLE, GL_FALSE, sizeof(vec4_t), points);
	}];
	[shader withAttribute:@"a_color" do:^(GLuint loc) {
		glEnableVertexAttribArray(loc);
		glVertexAttribPointer(loc, 4, GL_DOUBLE, GL_FALSE, sizeof(vec4_t), colors);
	}];
	glDrawArrays(GL_LINES, 0, count);
	free(points);
	free(colors);
}
- (void)render:(Scene *)aScene
{
	[_state applyToScene:aScene];
    void *baseOffset = _vertices;
    if(_useVBO) {
        baseOffset = 0;
    	glBindBufferARB(GL_ARRAY_BUFFER, _vertexBuffer);
    }

	Shader *shader = _state.shader;
	if(!shader) {
		TLog(@"No shader");
		return;
	}
	[shader withAttribute:@"a_position" do:^(GLuint loc) {
		glEnableVertexAttribArray(loc);
		glVertexAttribPointer(loc, 4, GL_DOUBLE, GL_FALSE, sizeof(Vertex_t), (void*)(baseOffset+offsetof(Vertex_t, position)));
	}];
	[shader withAttribute:@"a_normal" do:^(GLuint loc) {
		glEnableVertexAttribArray(loc);
		glVertexAttribPointer(loc, 4, GL_DOUBLE, GL_FALSE, sizeof(Vertex_t), (void*)(baseOffset+offsetof(Vertex_t, normal)));
	}];
	[shader withAttribute:@"a_color" do:^(GLuint loc) {
		glEnableVertexAttribArray(loc);
		glVertexAttribPointer(loc, 4, GL_DOUBLE, GL_FALSE, sizeof(Vertex_t), (void*)(baseOffset+offsetof(Vertex_t, color)));
	}];
	[shader withAttribute:@"a_texCoord" do:^(GLuint loc) {
		glEnableVertexAttribArray(loc);
		glVertexAttribPointer(loc, 2, GL_DOUBLE, GL_FALSE, sizeof(Vertex_t), (void*)(baseOffset+offsetof(Vertex_t, texCoord)));
	}];
	[shader withAttribute:@"a_size" do:^(GLuint loc) {
		glEnableVertexAttribArray(loc);
		glVertexAttribPointer(loc, 1, GL_DOUBLE, GL_FALSE, sizeof(Vertex_t), (void*)(baseOffset+offsetof(Vertex_t, size)));
	}];
	[shader withAttribute:@"a_shininess" do:^(GLuint loc) {
		glEnableVertexAttribArray(loc);
		glVertexAttribPointer(loc, 1, GL_DOUBLE, GL_FALSE, sizeof(Vertex_t), (void*)(baseOffset+offsetof(Vertex_t, shininess)));
	}];

	if(_usesIndices) {
		glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
		glIndexPointer(GL_UNSIGNED_INT, 0, 0);
		glDrawElements(_renderMode, _indexCount, GL_UNSIGNED_INT, 0);
		glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER, 0);
	} else
		glDrawArrays(_renderMode, 0, _vertexCount);

    if(_useVBO)
    	glBindBufferARB(GL_ARRAY_BUFFER, 0);

    if(_state.drawNormals)
        [self drawNormals:aScene];
	[_state unapplyToScene:aScene];
}

#pragma mark -

- (void)setVertexCapacity:(int)aVertexCapacity
{
	if(_vertexCapacity == aVertexCapacity || aVertexCapacity == 0) return;

	_vertexCapacity = aVertexCapacity;
	if(_vertices)
		_vertices = realloc(_vertices, _vertexCapacity*sizeof(Vertex_t));
	else
		_vertices = calloc(_vertexCapacity, sizeof(Vertex_t));

    if(!_useVBO) return;
    if(!_vertexBuffer)
        glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
	glBufferData(GL_ARRAY_BUFFER, _vertexCapacity*sizeof(Vertex_t), _vertices, GL_DYNAMIC_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	TCheckGLError();
}
- (void)setIndexCapacity:(int)aIndexCapacity
{
	if(_indexCapacity == aIndexCapacity || aIndexCapacity == 0) return;
	_indexCapacity = aIndexCapacity;
	if(_indices)
		_indices = realloc(_indices, _indexCapacity*sizeof(GLuint));
	else
		_indices = calloc(_indexCapacity, sizeof(GLuint));

    if(!_useVBO) return;
    if(!_indexBuffer)
        glGenBuffers(1, &_indexBuffer);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, _indexCapacity*sizeof(GLuint), _indices, GL_DYNAMIC_DRAW);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	TCheckGLError();
}
- (void)addVertex:(Vertex_t)aVertex
{
    ++_vertexCount;
	if(_vertexCount > _vertexCapacity)
		[self setVertexCapacity:(_vertexCapacity>0 ? _vertexCapacity : 64) * 2];
	_vertices[_vertexCount-1] = aVertex;

    if(!_useVBO) return;
	glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
	glBufferSubData(GL_ARRAY_BUFFER, (_vertexCount-1)*sizeof(Vertex_t), sizeof(Vertex_t), (GLMFloat*)&_vertices[_vertexCount-1]);
    TCheckGLError();
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	TCheckGLError();
}

- (void)addIndex:(GLuint)aIndex
{
    ++_indexCount;
	if(_indexCount >= _indexCapacity)
		[self setIndexCapacity:(_indexCapacity>0 ? _indexCapacity : 64) * 2];
	_indices[_indexCount-1] = aIndex;

    if(!_useVBO) return;
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
	glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, (_indexCount-1)*sizeof(GLuint), sizeof(GLuint), &_indices[_indexCount-1]);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	TCheckGLError();
}

- (void)clear
{
	memset(_vertices, 0, sizeof(Vertex_t)*_vertexCount);
	_vertexCount = 0;
	memset(_indices, 0, sizeof(GLuint)*_indexCount);
	_indexCount = 0;
}

- (void)recomputeNormals:(BOOL)aSmooth
{
	// TODO
}

//- (PolyPrimitive *)mapVertices:(VertexMappingBlock)aEnumBlock
//{
//    for(NSUInteger i = 0; i < _vertexCount; ++i) {
//        _vertices[i] = aEnumBlock(i, _vertices[i]);
//        
//        printVec4(_vertices[i].position);
//    }
//    if(_useVBO) {
//        glBindBuffer(GL_ARRAY_BUFFER, 0);
//        glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
//        glBufferSubData(GL_ARRAY_BUFFER, 0, _vertexCount*sizeof(Vertex_t), _vertices);
//    }
//    return self;
//}

@end