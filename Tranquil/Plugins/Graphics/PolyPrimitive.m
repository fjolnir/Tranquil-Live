#import "PolyPrimitive.h"
#import "TState.h"
#import "TShader.h"
#import "TGLErrorChecking.h"

@interface PolyPrimitive () {
	int _vertexCapacity, _indexCapacity;
}
@end

@implementation PolyPrimitive
@synthesize vertexBuffer=_vertexBuffer, indexBuffer=_indexBuffer, vertices=_vertices, vertexCapacity=_vertexCapacity,
	indices=_indices, indexCapacity=_indexCapacity, vertexCount=_vertexCount, indexCount=_indexCount,
	usesIndices=_usesIndices, renderMode=_renderMode, state=_state;

- (id)initWithVertexCapacity:(int)aVertexCapacity indexCapacity:(int)aIndexCapacity
{
	self = [super init];
	if(!self) return nil;

	_state = [TGlobalState() copy];

	_vertexCount = 0;
	_indexCount = 0;
	_vertices = NULL;
	_indices = NULL;
	glGenBuffers(1, &_vertexBuffer);
	glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
	[self setVertexCapacity:aVertexCapacity];
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	TCheckGLError();

	_usesIndices = aIndexCapacity > 0;
	if(_usesIndices) {
		glGenBuffers(1, &_indexBuffer);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _vertexBuffer);
		[self setIndexCapacity:aIndexCapacity];
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
		TCheckGLError();
	}
	
	_vertexCount = _indexCount = 0;

	return self;
}

- (void)finalize
{
	[TGlobalGLContext() makeCurrentContext];
	if(_usesIndices)
		glDeleteBuffers(1, &_indexBuffer);
	glDeleteBuffers(1, &_vertexBuffer);
//	GLuint buffers[] = { _indexBuffer, _vertexBuffer };
//	glDeleteBuffers(2, buffers);
	free(_vertices);
	free(_indices);
	
	[super finalize];
}

- (void)drawNormals:(TScene *)aScene
{
	//glLineWidth(3);
	TShader *shader = [aScene currentState].shader;
	[shader withUniform:@"u_ambientColor" do:^(GLint loc) {
		vec4_t white = { 1, 1, 1, 1 };
		glUniform4fv(loc, 1, white.f);
	}];
	[shader withUniform:@"u_lightCount" do:^(GLint loc) {
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
	[shader makeActive];
	[shader withAttribute:@"a_position" do:^(GLint loc) {
		glEnableVertexAttribArray(loc);
		glVertexAttribPointer(loc, 4, GL_FLOAT, GL_FALSE, sizeof(vec4_t), points);
	}];
	[shader withAttribute:@"a_color" do:^(GLint loc) {
		glEnableVertexAttribArray(loc);
		glVertexAttribPointer(loc, 4, GL_FLOAT, GL_FALSE, sizeof(vec4_t), colors);
	}];
	glDrawArrays(GL_LINES, 0, count);
	[shader makeInactive];
	free(points);
	free(colors);
}
- (void)render:(TScene *)aScene
{
	[_state applyToScene:aScene];
	glBindBufferARB(GL_ARRAY_BUFFER, _vertexBuffer);	

	//TVertex_t *verts = glMapBuffer(GL_ARRAY_BUFFER, GL_READ_ONLY);
	//glUnmapBuffer(GL_ARRAY_BUFFER);

	TShader *shader = _state.shader;
	if(!shader) {
		TLog(@"No shader");
		return;
	}
	[shader withAttribute:@"a_position" do:^(GLint loc) {
		glEnableVertexAttribArray(loc);
		glVertexAttribPointer(loc, 4, GL_FLOAT, GL_FALSE, sizeof(TVertex_t), (void*)offsetof(TVertex_t, position));
	}];
	[shader withAttribute:@"a_normal" do:^(GLint loc) {
		glEnableVertexAttribArray(loc);
		glVertexAttribPointer(loc, 4, GL_FLOAT, GL_FALSE, sizeof(TVertex_t), (void*)offsetof(TVertex_t, normal));
	}];
	[shader withAttribute:@"a_color" do:^(GLint loc) {
		glEnableVertexAttribArray(loc);
		glVertexAttribPointer(loc, 4, GL_FLOAT, GL_FALSE, sizeof(TVertex_t), (void*)offsetof(TVertex_t, color));
	}];
	[shader withAttribute:@"a_texCoord" do:^(GLint loc) {
		glEnableVertexAttribArray(loc);
		glVertexAttribPointer(loc, 2, GL_FLOAT, GL_FALSE, sizeof(TVertex_t), (void*)offsetof(TVertex_t, texCoord));
	}];
	[shader withAttribute:@"a_size" do:^(GLint loc) {
		glEnableVertexAttribArray(loc);
		glVertexAttribPointer(loc, 1, GL_FLOAT, GL_FALSE, sizeof(TVertex_t), (void*)offsetof(TVertex_t, size));
	}];
	[shader withAttribute:@"a_shininess" do:^(GLint loc) {
		glEnableVertexAttribArray(loc);
		glVertexAttribPointer(loc, 1, GL_FLOAT, GL_FALSE, sizeof(TVertex_t), (void*)offsetof(TVertex_t, shininess));
	}];
	
	if(_usesIndices) {
		glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
		glIndexPointer(GL_UNSIGNED_INT, 0, 0);
		glDrawElements(_renderMode, _indexCount, GL_UNSIGNED_INT, 0);
		glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER, 0);
	} else
		glDrawArrays(_renderMode, 0, _vertexCount);
	
	glBindBufferARB(GL_ARRAY_BUFFER, 0);
	[_state unapplyToScene:aScene];
}

#pragma mark -

- (void)setVertexCapacity:(int)aVertexCapacity
{
	if(_vertexCapacity == aVertexCapacity || aVertexCapacity == 0) return;
	_vertexCapacity = aVertexCapacity;
	if(_vertices)
		_vertices = realloc(_vertices, _vertexCapacity*sizeof(TVertex_t));
	else
		_vertices = calloc(_vertexCapacity, sizeof(TVertex_t));

	glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
	glBufferData(GL_ARRAY_BUFFER, _vertexCapacity*sizeof(TVertex_t), _vertices, GL_DYNAMIC_DRAW);
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
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, _indexCapacity*sizeof(GLuint), _indices, GL_DYNAMIC_DRAW);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	TCheckGLError();
}
- (void)addVertex:(TVertex_t)aVertex
{
	if(_vertexCount+1 > _vertexCapacity)
		[self setVertexCapacity:(_vertexCapacity>0 ? _vertexCapacity : 4) * 2];
	_vertices[_vertexCount] = aVertex;
	
	glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
	glBufferSubData(GL_ARRAY_BUFFER, _vertexCount*sizeof(TVertex_t), sizeof(TVertex_t), _vertices[_vertexCount].f);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	TCheckGLError();

	++_vertexCount;
}

- (void)addIndex:(GLuint)aIndex
{
	if(_indexCount+1 >= _indexCapacity)
		[self setIndexCapacity:(_indexCapacity>0 ? _indexCapacity : 4) * 2];
	_indices[_indexCount] = aIndex;
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
	glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, _indexCount*sizeof(GLuint), sizeof(GLuint), &_indices[_indexCount]);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	TCheckGLError();

	++_indexCount;
}

- (void)clear
{
	memset(_vertices, 0, sizeof(TVertex_t)*_vertexCount);
	_vertexCount = 0;
	memset(_indices, 0, sizeof(GLuint)*_indexCount);
	_indexCount = 0;
}

- (void)recomputeNormals:(BOOL)aSmooth
{
	// TODO
}
@end
