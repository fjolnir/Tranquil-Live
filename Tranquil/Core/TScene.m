#import "TScene.h"
#import "TScriptContext.h"
#import "TState.h"
#import "Light.h"
#import <OpenGL/gl.h>
#import "TCamera.h"
#import "TShader.h"
#import "TGLErrorChecking.h"

static TScene *_GlobalScene = nil;

@interface TScene () {
@private
	NSMutableArray *_objects, *_immediateModeObjects, *_stateStack, *_lights;
}
@end
@implementation TScene
@synthesize projMatStack=_projStack, worldMatStack=_worldStack, objects=_objects, immediateModeObjects=_immediateModeObjects, stateStack=_stateStack, clearColor=_clearColor, ambientLight=_ambientLight, lights=_lights, camera=_camera;

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
	_projStack = [MatrixStack stackWithCapacity:8];
	[_projStack push:[Matrix4 identity]];
	 _worldStack = [MatrixStack stackWithCapacity:32];
	 [_worldStack push:[Matrix4 identity]];
	
	_objects = [NSMutableArray array];
	_immediateModeObjects = [NSMutableArray array];
	_lights = [NSMutableArray array];
	_stateStack = [NSMutableArray array];
	TState *rootState = [[TState alloc] init];
	[_stateStack addObject:rootState];
	
	self.clearColor = [Vector4 vectorWithX:0 y:0 z:0 w:1];
	_ambientLight = [Vector4 vectorWithX:0 y:0 z:0 w:1];
	
	_camera = [[TCamera alloc] init];
	
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
	for(id<TSceneObject> obj in _objects) {
		[obj render:self];
	}
	for(id<TSceneObject> obj in _immediateModeObjects) {
		[obj render:self];
	}
	[_immediateModeObjects removeAllObjects];
	[_projStack pop];
	// Notify the script
	[[TScriptContext sharedContext] executeScript:@"_frameCallback" error:nil];
}

#pragma - Accessors
- (void)clear
{
	[_objects removeAllObjects];
}
- (void)addObject:(id<TSceneObject>)aObject
{
	[_objects addObject:aObject];
}
- (void)removeObject:(id<TSceneObject>)aObject
{
	[_objects removeObject:aObject];
}
- (void)addImmediateModeObject:(id<TSceneObject>)aObject {
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

- (TState *)currentState
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
- (void)withState:(void (^)(TState *))block
{
	[self pushState];
	block([self currentState]);
	[self popState];
}
@end
