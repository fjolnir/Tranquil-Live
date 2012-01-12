#import "TShader.h"
#import <OpenGL/gl.h>
#import "TGLErrorChecking.h"
#import "TAppDelegate.h"

static TShader *_ActiveShader = nil;

@interface TShader () {
	NSMutableDictionary *_unifCache, *_attribCache;
}
- (GLuint)_loadShader:(NSString *)sourceStr type:(GLenum)shaderType compiled:(BOOL *)succeeded;
- (void)_linkProgram:(GLuint)programObject success:(BOOL *)success;
@end

@implementation TShader
@synthesize program=_program, name=_name;

+ (TShader *)activeShader
{
	return _ActiveShader;
}

+ (TShader *)shaderWithName:(NSString *)aName fragmentShader:(NSString *)aFragSrc vertexShader:(NSString *)aVertSrc
{
	TShader *shader = [[self alloc] initWithWithFragmentShader:aFragSrc vertexShader:aVertSrc];
	shader.name = aName;
	return [shader autorelease];
}

- (id)initWithWithFragmentShader:(NSString *)aFragSrc vertexShader:(NSString *)aVertSrc
{
	if(!(self = [super init]))
		return nil;
	
	_unifCache = [[NSMutableDictionary alloc] init];
	_attribCache = [[NSMutableDictionary alloc] init];
	
	BOOL success;
	GLuint fragmentShader = [self _loadShader:aFragSrc type:GL_FRAGMENT_SHADER compiled:&success];
	assert(success);

	GLuint vertexShader = [self _loadShader:aVertSrc type:GL_VERTEX_SHADER compiled:&success];
	assert(success);

	_program = glCreateProgram();
	glAttachShader(_program, vertexShader);
	glAttachShader(_program, fragmentShader);
	TCheckGLError();
	
	[self _linkProgram:_program success:&success];
	assert(success);

	_name = [[NSString alloc] initWithString:@"Untitled"];

	TCheckGLError();
	return self;
}

- (NSArray *)getUniforms
{
	GLint total = 0;
	glGetProgramiv(_program, GL_ATTACHED_SHADERS, &total); 
	
	NSMutableArray *ret = [NSMutableArray arrayWithCapacity:total];
	glGetProgramiv(_program, GL_ACTIVE_UNIFORMS, &total); 
	TCheckGLError();
	for(int i=0; i<total; ++i)  {
		GLsizei name_len, num;
		GLenum type = GL_ZERO;
		GLchar name[100];
		glGetActiveUniform( _program, (GLuint)i, sizeof(name)-1,
						   &name_len, &num, &type, name );
		name[name_len] = 0;
		[ret addObject:[NSDictionary dictionaryWithObjectsAndKeys:
						[NSString stringWithUTF8String:name], @"name",
						[NSNumber numberWithInt:glGetUniformLocation(_program, name)], nil]];
	}
	TCheckGLError();
	
	return ret;
}

- (NSArray *)getAttributes
{
	GLint total = 0;
	glGetProgramiv(_program, GL_ATTACHED_SHADERS, &total); 
	
	NSMutableArray *ret = [NSMutableArray arrayWithCapacity:total];
	glGetProgramiv(_program, GL_ACTIVE_ATTRIBUTES, &total); 
	TCheckGLError();
	for(int i=0; i<total; ++i)  {
		GLsizei name_len, num;
		GLenum type = GL_ZERO;
		GLchar name[100];
		glGetActiveAttrib(_program, (GLuint)i, sizeof(name)-1,
						  &name_len, &num, &type, name);
		name[name_len] = 0;
		[ret addObject:[NSDictionary dictionaryWithObjectsAndKeys:
						[NSString stringWithUTF8String:name], @"name",
						[NSNumber numberWithInt:glGetAttribLocation(_program, name)], nil]];
	}
	TCheckGLError();
	
	return ret;
}

- (GLint)getUniformLocation:(NSString *)aUniformName
{
	NSNumber *cached = [_unifCache objectForKey:aUniformName];
	GLint location;
	if(!cached) {
		location = glGetUniformLocation(_program, (const GLchar*)[aUniformName UTF8String]);
		[_unifCache setObject:[NSNumber numberWithInt:location] forKey:aUniformName];
		if(location == -1)
			NSLog(@"Uniform lookup error: No such uniform (%@)", aUniformName);
	} else
		location = [cached intValue];
	
	TCheckGLError();
	return location;
}

- (GLint)getAttributeLocation:(NSString *)aAttribName
{
	NSNumber *cached = [_attribCache objectForKey:aAttribName];
	GLint location;
	if(!cached) {
		location = glGetAttribLocation(_program, (const GLchar*)[aAttribName UTF8String]);
		[_attribCache setObject:[NSNumber numberWithInt:location] forKey:aAttribName];
		if(location == -1)
			NSLog(@"Attribute lookup error: No such attribute (%@)", aAttribName);
	} else
		location = [cached intValue];
	
	TCheckGLError();
	return location;
}

-(void)withUniform:(NSString *)aUniformName do:(void (^)(GLint))block
{
	GLint loc = [self getUniformLocation:aUniformName];
	if(loc != -1)
		block(loc);
}

-(void)withAttribute:(NSString *)aAttribName do:(void (^)(GLint))block
{
	GLint loc = [self getAttributeLocation:aAttribName];
	if(loc != -1)
		block(loc);
}

- (void)dealloc
{
	if(_program) {
		glDeleteProgram(_program);
		_program = 0;
	}
	[_name release];
	[_unifCache release];
	[_attribCache release];
	
	[super dealloc];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<Shader '%@' - %@>", _name, [super description]];
}

#pragma mark -

- (void)makeActive
{
	glUseProgram(_program);
	TCheckGLError();
	_ActiveShader = self;
}

- (void)makeInactive
{
	_ActiveShader = nil;
	glUseProgram(0);
	TCheckGLError();
}

#pragma mark -
#pragma mark Shader loading
- (GLuint)_loadShader:(NSString *)aSourceStr type:(GLenum)aShaderType compiled:(BOOL *)aoSucceeded
{
	GLuint shaderObject;
	
	GLchar **source = malloc(sizeof(GLchar*));
	source[0] = (GLchar *)[aSourceStr UTF8String];
	if(!source) {
		*aoSucceeded = NO;
		free(source);
		return 0;
	}
	
	shaderObject = glCreateShader(aShaderType);
	glShaderSource(shaderObject, 1, (const GLchar **)source, NULL);
	glCompileShader(shaderObject);

	GLint temp = 0;
	glGetShaderiv(shaderObject, GL_INFO_LOG_LENGTH, &temp);
	if (temp > 0) {
		GLchar *log = (GLchar *)malloc(temp);
		glGetShaderInfoLog(shaderObject, temp, &temp, log);
		NSLog(@">> %@ shader compile log:\n %s", aShaderType == GL_FRAGMENT_SHADER ? @"Fragment" : @"Vertex", log);
		free(log);
	}
	
	glGetShaderiv(shaderObject, GL_COMPILE_STATUS, &temp);
	if(temp == GL_FALSE) {
		*aoSucceeded = NO;
		NSLog(@">> Failed to compile shader %@", aSourceStr);
	}
	if(aoSucceeded) *aoSucceeded = YES;
	free(source);
	return shaderObject;
}

- (void)_linkProgram:(GLuint)programObject success:(BOOL *)succeeded {
	glLinkProgram(programObject);
	
	GLint logLength = 0;
	glGetProgramiv(programObject, GL_INFO_LOG_LENGTH, &logLength);
	if(logLength > 0) {
		GLchar *log = (GLchar *)malloc(logLength);
		glGetProgramInfoLog(programObject, logLength, &logLength, log);
		NSLog(@">> Program link log:\n%s", log);
		free(log);
	}

	glGetProgramiv(programObject, GL_LINK_STATUS, (GLint *)succeeded);
	if(*succeeded == 0)
		NSLog(@"Failed to link shader program");
	
	TCheckGLError();
}

@end
