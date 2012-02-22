#import <OpenGL/gl.h>
#import "Scene.h"
#import "ScriptContext.h"
#import "State.h"
#import "Light.h"
#import "Camera.h"
#import "Shader.h"
#import "GLErrorChecking.h"

static Scene *_GlobalScene = nil;
static NSOpenGLContext *_globalGlContext = nil;

@interface Scene () {
@private
	NSMutableArray *_objects, *_immediateModeObjects, *_stateStack, *_lights;
}
@end
@implementation Scene
@synthesize projMatStack=_projStack, worldMatStack=_worldStack, objects=_objects, immediateModeObjects=_immediateModeObjects, stateStack=_stateStack, clearColor=_clearColor, ambientLight=_ambientLight, lights=_lights, camera=_camera;

+ (NSOpenGLPixelFormat *)pixelFormat
{
	NSOpenGLPixelFormatAttribute attrs[] = {
        NSOpenGLPFANoRecovery,
        NSOpenGLPFAColorSize, 24,
        NSOpenGLPFAAlphaSize, 8,
        NSOpenGLPFADepthSize, 24,
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAAccelerated,
		NSOpenGLPFAMultisample,
		NSOpenGLPFASampleBuffers, (NSOpenGLPixelFormatAttribute)1,
		NSOpenGLPFASamples, (NSOpenGLPixelFormatAttribute)4,
        0
    };
	return [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
    
}

+ (Scene *)globalScene
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_GlobalScene = [[self alloc] init];
	});
	return _GlobalScene;
}

+ (NSOpenGLContext *)globalContext
{	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_globalGlContext = [[NSOpenGLContext alloc] initWithFormat:[self pixelFormat] shareContext:nil];
	});
	return _globalGlContext;
}

- (id)init
{
	self = [super init];
	if(!self) return nil;
	_projStack = [MatrixStack stackWithCapacity:8];
	[_projStack push:[Matrix4 identity]];
	 _worldStack = [MatrixStack stackWithCapacity:32];
	 [_worldStack push:[Matrix4 identity]];
	
	_objects = [NSMutableArray array];
	_immediateModeObjects = [NSMutableArray array];
	_lights = [NSMutableArray array];
	_stateStack = [NSMutableArray array];
	State *rootState = [[State alloc] init];
	[_stateStack addObject:rootState];
	
	self.clearColor = [Vector4 vectorWithX:0 y:0 z:0 w:1];
	_ambientLight = [Vector4 vectorWithX:0 y:0 z:0 w:1];
	
	_camera = [[Camera alloc] init];
	
	[GlobalGLContext() makeCurrentContext];
	TCheckGLError();
	NSString *fragSrc = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"simple" ofType:@"fsh" inDirectory:@"Shaders"]
											  usedEncoding:NULL error:NULL];
	NSString *vertSrc = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"simple" ofType:@"vsh" inDirectory:@"Shaders"]
											  usedEncoding:NULL error:NULL];
	
	Shader *shader = [Shader shaderWithName:@"Simple" fragmentShader:fragSrc vertexShader:vertSrc];
	TCheckGLError();
	[self currentState].shader = shader;
	
	return self;
}

- (void)initializeGLState
{
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

- (void)render
{
	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
	
	[_projStack push:_camera.matrix];
	for(id<SceneObject> obj in _objects) {
		[obj render:self];
	}
	for(id<SceneObject> obj in _immediateModeObjects) {
		[obj render:self];
	}
	[_immediateModeObjects removeAllObjects];
	[_projStack pop];
	// Notify the script
	[[ScriptContext sharedContext] executeScript:@"_frameCallback" error:nil];
}

#pragma - Accessors
- (void)clear
{
	[_objects removeAllObjects];
}
- (id<SceneObject>)addObject:(id<SceneObject>)aObject
{
	[_objects addObject:aObject];
	return aObject;
}
- (void)removeObject:(id<SceneObject>)aObject
{
	[_objects removeObject:aObject];
}
- (void)addImmediateModeObject:(id<SceneObject>)aObject {
	[_immediateModeObjects addObject:aObject];
}

- (void)addLight:(Light *)aLight
{
	[_lights addObject:aLight];
}
- (void)removeLight:(Light *)aLight
{
	[_lights removeObject:aLight];
}

- (void)setClearColor:(Vector4 *)aColor
{
	_clearColor = aColor;
	glClearColor(aColor.r, aColor.g, aColor.b, aColor.a);
}

- (State *)currentState
{
	return [_stateStack lastObject];
}
- (void)pushState
{
	[_stateStack addObject:[[self currentState] copy]];
}
- (void)popState
{
	[_stateStack removeLastObject];
}
- (void)withState:(void (^)(State *))block
{
	[self pushState];
	block([self currentState]);
	[self popState];
}
@end
