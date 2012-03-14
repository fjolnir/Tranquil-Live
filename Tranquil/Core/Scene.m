#import <OpenGL/gl.h>
#import "Scene.h"
#import "ScriptContext.h"
#import "State.h"
#import "Light.h"
#import "Shader.h"
#import "GLErrorChecking.h"
#import "Logger.h"
#import <MacRuby/MacRuby.h>
#import <TranquilCore/TranquilCore.h>

static Scene *_GlobalScene = nil;
static NSOpenGLContext *_globalGlContext = nil;

@interface Scene () {
@private
	NSMutableArray *_objects, *_immediateModeObjects, *_stateStack, *_lights;
    id _rubyFrameHandler;
    NSComparator _depthSortingBlock;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishedLaunching:)
                                                 name:kTranquilFinishedLaunching
                                               object:nil];

    _projStack = matrix_stack_create(8);
    matrix_stack_push_item(_projStack, kMat4_identity);
    _worldStack = matrix_stack_create(32);
    matrix_stack_push_item(_worldStack, kMat4_identity);
	
	_objects = [NSMutableArray array];
	_immediateModeObjects = [NSMutableArray array];
	_lights = [NSMutableArray array];
	_stateStack = [NSMutableArray array];
	State *rootState = [[State alloc] init];
	[_stateStack addObject:rootState];
	
	self.clearColor = vec4_create(0, 0, 0, 1);
	_ambientLight = vec4_create(0, 0, 0, 1);
	
	self.camera = [[Camera alloc] init];
	
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

- (void)finishedLaunching:(NSNotification *)aNotification
{
    _rubyFrameHandler = [[ScriptContext sharedContext] executeScript:@"TranquilFrameHandler.new"error:nil];
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
	
    matrix_stack_push_item(_projStack, _camera.matrix);

    [_objects sortUsingComparator:_depthSortingBlock];
    [_immediateModeObjects sortUsingComparator:_depthSortingBlock];
	for(id<SceneObject> obj in _objects) {
		[obj render:self];
	}
	for(id<SceneObject> obj in _immediateModeObjects) {
		[obj render:self];
	}
    [_immediateModeObjects makeObjectsPerformSelector:@selector(invalidate)];
	[_immediateModeObjects removeAllObjects];
    matrix_stack_pop(_projStack);

	// Notify the script
    @try {
        [_rubyFrameHandler performRubySelector:@selector(handleFrame)];
    } @catch(NSException *e) {
        [[Logger sharedLogger] log:e.description];
    }
}

#pragma - Accessors
- (void)clear
{
	[_objects makeObjectsPerformSelector:@selector(invalidate)];
	[_objects removeAllObjects];
}

- (void)setCamera:(Camera *)aCamera
{
    _camera = aCamera;
    _depthSortingBlock = [^NSComparisonResult(id<SceneObject> obj1, id<SceneObject> obj2) {
        vec4_t origin = { 0,0,0,1 };
        vec4_t p1 = vec4_mul_mat4(origin, obj1.state->_transform);
        p1 = vec4_mul_mat4(p1, _camera->_matrix);
        vec4_t p2 = vec4_mul_mat4(origin, obj2.state->_transform);
        p2 = vec4_mul_mat4(p2, _camera->_matrix);
        return ((p1.z >= p2.z) ? NSOrderedAscending : NSOrderedDescending);
    } copy];
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
- (id<SceneObject>)addImmediateModeObject:(id<SceneObject>)aObject
{
	[_immediateModeObjects addObject:aObject];
    return aObject;
}

- (void)addLight:(Light *)aLight
{
	[_lights addObject:aLight];
}
- (void)removeLight:(Light *)aLight
{
	[_lights removeObject:aLight];
}

- (void)setClearColor:(vec4_t)aColor
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
