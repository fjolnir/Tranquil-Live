#import "PolyPrimitive.h"

@interface VertexWrapper ()
@property(readwrite, assign, nonatomic) Vertex_t *vert;
- (void)updateVert;
@end

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
		vec4_t white = { 1, 1, 1, 1 };
		glUniform4fv(loc, 1, white.f);
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
		glVertexAttribPointer(loc, 4, GL_FLOAT, GL_FALSE, sizeof(vec4_t), points);
	}];
	[shader withAttribute:@"a_color" do:^(GLuint loc) {
		glEnableVertexAttribArray(loc);
		glVertexAttribPointer(loc, 4, GL_FLOAT, GL_FALSE, sizeof(vec4_t), colors);
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
		glVertexAttribPointer(loc, 1, GL_FLOAT, GL_FALSE, sizeof(Vertex_t), (void*)(baseOffset+offsetof(Vertex_t, size)));
	}];
	[shader withAttribute:@"a_shininess" do:^(GLuint loc) {
		glEnableVertexAttribArray(loc);
		glVertexAttribPointer(loc, 1, GL_FLOAT, GL_FALSE, sizeof(Vertex_t), (void*)(baseOffset+offsetof(Vertex_t, shininess)));
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
	glBufferSubData(GL_ARRAY_BUFFER, (_vertexCount-1)*sizeof(Vertex_t), sizeof(Vertex_t), _vertices[_vertexCount-1].f);
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

- (PolyPrimitive *)mapVertices:(VertexMappingBlock)aEnumBlock
{
    VertexWrapper *wrapper = [[VertexWrapper alloc] init];
    for(NSUInteger i = 0; i < _vertexCount; ++i) {
        wrapper.vert = &_vertices[i];
        aEnumBlock(i, wrapper);
        [wrapper updateVert];
    }
    [wrapper release];
    if(_useVBO) {
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
        glBufferSubData(GL_ARRAY_BUFFER, 0, _vertexCount*sizeof(Vertex_t), _vertices);
    }
    return self;
}

@end

@implementation VertexWrapper {
@private
    Vector4 *_pos;
    Vector4 *_normal;
    Vector4 *_color;
    Vector2 *_texCoord;
    float _size;
    float _shininess;
    Vertex_t *_vert;
}

@synthesize pos = _pos;
@synthesize normal = _normal;
@synthesize color = _color;
@synthesize texCoord = _texCoord;
@synthesize size = _size;
@synthesize shininess = _shininess;
@synthesize vert = _vert;

- (id)init
{
    if(!(self = [super init]))
        return nil;
    _pos = [Vector4 vectorWithVec:kVec4_zero];
    _normal = [Vector4 vectorWithVec:kVec4_zero];
    _color = [Vector4 vectorWithVec:kVec4_zero];
    _texCoord = [Vector2 vectorWithVec:kVec2_zero];
    _size = 0.0f;
    _shininess = 0.0f;

    return self;
}

- (void)setVert:(Vertex_t *)aVert
{
    _vert = aVert;
    _pos->_vec = _vert->position;
    _normal->_vec = _vert->normal;
    _color->_vec = _vert->color;
    _texCoord->_vec = _vert->texCoord;
    _size = _vert->size;
    _shininess = _vert->shininess;
}

- (void)updateVert
{
    _vert->position = _pos->_vec;
    _vert->normal = _normal->_vec;
    _vert->color = _color->_vec;
    _vert->texCoord = _texCoord->_vec;
    _vert->size = _size;
    _vert->shininess = _shininess;
}

- (void)dealloc
{
    [_pos release], _pos = nil;
    [_normal release], _normal = nil;
    [_color release], _color = nil;
    [_texCoord release], _texCoord = nil;
    [super dealloc];
}

@end
