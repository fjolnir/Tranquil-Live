#import "TScene.h"
#import "TScriptContext.h"
#import "TState.h"
#import "TLight.h"
#import <OpenGL/gl.h>
#import "TCamera.h"
#import "TShader.h"
#import "TGLErrorChecking.h"

static TScene *_GlobalScene = nil;

@interface TScene () {
@private
	NSMutableArray *_objects, *_stateStack, *_lights;
}
@end
@implementation TScene
@synthesize projMatStack=_projStack, worldMatStack=_worldStack, objects=_objects, stateStack=_stateStack, ambientLight=_ambientLight, lights=_lights, camera=_camera;

+ (TScene *)globalScene
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_GlobalScene = [[self alloc] init];
	});
	return _GlobalScene;
}

- (id)init
{
	self = [super init];
	if(!self) return nil;
	_projStack = matrix_stack_create(8);
	matrix_stack_push_item(_projStack, kMat4_identity);
	_worldStack = matrix_stack_create(32);
	matrix_stack_push_item(_worldStack, kMat4_identity);
	
	_objects = [[NSMutableArray alloc] init];
	_lights = [[NSMutableArray alloc] init];
	_stateStack = [[NSMutableArray alloc] init];
	TState *rootState = [[TState alloc] init];
	[_stateStack addObject:rootState];
	[rootState release];
	
	_ambientLight = vec4_create(0.0, 0.0, 0.0, 1);
	TLight *light = [[[TLight alloc] init] autorelease];
	light.position = vec4_create(0, 2, 0, 1);
	light.ambientColor = vec4_create(0.2, 0.2, 0.2, 1);
	light.specularColor = vec4_create(0.1, 0.1, 0.1, 1);
	light.diffuseColor = vec4_create(0.7, 0.7, 0.7, 1);
	[_lights addObject:light];
	light = [[[TLight alloc] init] autorelease]; 
	light.position = vec4_create(-5, 0, 0, 1);
	light.ambientColor = vec4_create(0.2, 0.0, 0.0, 1);
	light.specularColor = vec4_create(0.1, 0.1, 0.1, 1);
	light.diffuseColor = vec4_create(1.0, 0.0, 0.0, 1);
	[_lights addObject:light];
	
	light = [[[TLight alloc] init] autorelease]; 
	light.position = vec4_create(1, 2, 0, 1);
	light.ambientColor = vec4_create(0.0, 0.0, 0.2, 1);
	light.specularColor = vec4_create(0.1, 0.1, 0.1, 1);
	light.diffuseColor = vec4_create(0.0, 0.0, 1.0, 1);
	[_lights addObject:light];
	
	light = [[[TLight alloc] init] autorelease]; 
	light.position = vec4_create(-0.5, 2, 0, 1);
	light.ambientColor = vec4_create(0.0, 0.2, 0.0, 1);
	light.specularColor = vec4_create(0.1, 0.1, 0.1, 1);
	light.diffuseColor = vec4_create(0.0, 1.0, 0.0, 1);
	[_lights addObject:light];

	
	_camera = [[TCamera alloc] init];
	_camera.position = vec4_create(0, 2, 5, 1);
	_camera.orientation = quat_createf(1, 0, 0, degToRad(-10));
	[_camera updateMatrix];
	
	[TGlobalGLContext() makeCurrentContext];
	TCheckGLError();
	NSString *fragSrc = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"simple" ofType:@"fsh" inDirectory:@"Shaders"]
											  usedEncoding:NULL error:NULL];
	NSString *vertSrc = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"simple" ofType:@"vsh" inDirectory:@"Shaders"]
											  usedEncoding:NULL error:NULL];
	
	TShader *shader = [TShader shaderWithName:@"Simple" fragmentShader:fragSrc vertexShader:vertSrc];
	TCheckGLError();
	[self currentState].shader = shader;
	
	return self;
}

- (void)dealloc
{
	matrix_stack_destroy(_projStack);
	matrix_stack_destroy(_worldStack);
	[_objects release];
	[_lights release];
	[_stateStack release];
	[_camera release];
	
	[super dealloc];
}

- (void)initializeGLState
{
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

- (void)render
{
	glClearColor(0.9, 0.1, 0.1, 1);
	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
	
	TLight *light = [_lights objectAtIndex:0];
	static float foo=0.0f;
	foo+=0.04;
	light.position = vec4_create(0, 3.0*sinf(foo), 5, 1);

	matrix_stack_push_item(_projStack, _camera.matrix);
	for(id<TSceneObject> obj in _objects) {
		[obj render:self];
	}
	matrix_stack_pop(_projStack);
	// Notify the script
	[[TScriptContext sharedContext] callGlobalFunction:@"_frameCallback" withArguments:nil];
}

#pragma - Accessors
- (void)addObject:(id<TSceneObject>)aObject
{
	[_objects addObject:aObject];
}
- (void)removeObject:(id<TSceneObject>)aObject
{
	[_objects removeObject:aObject];
}

- (TState *)currentState
{
	return [_stateStack lastObject];
}
- (void)pushState
{
	[_stateStack addObject:[[[self currentState] copy] autorelease]];
}
- (void)popState
{
	[_stateStack removeLastObject];
}
- (void)withState:(void (^)(TState *))block
{
	[self pushState];
	block([self currentState]);
	[self popState];
}
@end
