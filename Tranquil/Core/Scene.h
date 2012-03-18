// Manages the graphics state

#import <GLMath/GLMath.h>
#import "Camera.h"

@class Scene, State, Light;

@protocol SceneObject <NSObject>
- (void)render:(Scene *)aScene;
- (State *)state;
// Tells the object to delete all underlying resource (For example VBOs)
// This is because GC may wait for a long time before calling finalize
// even though the object isn't being used => constraining resources
- (void)invalidate;
@end

@interface Scene : NSObject
@property(readonly, nonatomic) NSArray *objects;
@property(readonly, nonatomic) NSArray *immediateModeObjects;
@property(readonly, nonatomic) NSArray *lights;
@property(readwrite, nonatomic) vec4_t clearColor;
@property(readwrite) vec4_t ambientLight;
@property(readonly) NSArray *stateStack;
@property(readonly) matrix_stack_t *projMatStack;
@property(readonly) matrix_stack_t *worldMatStack;
@property(readwrite, retain, nonatomic) Camera *camera;

- (void)initializeGLState;

+ (Scene *)globalScene;
+ (NSOpenGLPixelFormat *)pixelFormat;
+ (NSOpenGLContext *)globalContext;

- (void)clear;
- (void)render;
- (id<SceneObject>)addObject:(id<SceneObject>)aObject;
- (void)removeObject:(id<SceneObject>)aObject;
- (id<SceneObject>)addImmediateModeObject:(id<SceneObject>)aObject;

- (void)addLight:(Light *)aLight;
- (void)removeLight:(Light *)aLight;

- (State *)currentState;
- (void)pushState;
- (void)popState;
// Executes a block with a copy of the current state as it's argument
- (void)withState:(void (^)(State *))block;
@end
