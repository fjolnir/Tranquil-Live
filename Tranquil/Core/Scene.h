// Manages the graphics state

#import <GLMath/GLMath.h>

@class Scene, State, Light, Camera, Vec4;

@protocol SceneObject <NSObject>
- (void)render:(Scene *)aScene;
- (State *)state;
// Tells the object to delete all underlying resource (For example VBOs)
// This is because GC may wait for a long time before calling finalize
// even though the object isn't being used => constraining resources
- (void)invalidate;
@end

@interface Scene : NSObject
@property(readonly) NSArray *objects;
@property(readonly) NSArray *immediateModeObjects;
@property(readonly) NSArray *lights;
@property(readwrite, copy, nonatomic) Vec4 *clearColor;
@property(readwrite, copy, nonatomic) Vec4 *ambientLight;
@property(readonly) NSArray *stateStack;
@property(readonly) matrix_stack_t *projMatStack;
@property(readonly) matrix_stack_t *worldMatStack;
@property(readwrite, retain, nonatomic) Camera *camera;
@property(readwrite, copy) id (^frameCallback)();

- (id)initializeGLState;

+ (Scene *)globalScene;
+ (NSOpenGLPixelFormat *)pixelFormat;
+ (NSOpenGLContext *)globalContext;

- (id)clear;
- (id)render;
- (id<SceneObject>)addObject:(id<SceneObject>)aObject;
- (id)removeObject:(id<SceneObject>)aObject;
- (id<SceneObject>)addImmediateModeObject:(id<SceneObject>)aObject;

- (id)addLight:(Light *)aLight;
- (id)removeLight:(Light *)aLight;

- (State *)currentState;
- (id)pushState;
- (id)pushState;
- (id)popState;
// Executes a block with a copy of the current state as it's argument
- (id)pushState:(id (^)(State *))block;
@end
