// Manages the graphics state

#import "GLMathWrapper.h"
#import "Camera.h"

@class Scene, State, Light;

@protocol SceneObject <NSObject>
- (void)render:(Scene *)aScene;
@end

__attribute__((visibility("default"))) @interface Scene : NSObject
@property(readonly) NSArray *objects;
@property(readonly) NSArray *immediateModeObjects;
@property(readonly) NSArray *lights;
@property(readwrite) Vector4 *clearColor;
@property(readwrite) Vector4 *ambientLight;
@property(readonly) NSArray *stateStack;
@property(readonly) MatrixStack *projMatStack;
@property(readonly) MatrixStack *worldMatStack;
@property(readwrite, retain) Camera *camera;

- (void)initializeGLState;

+ (Scene *)globalScene;

- (void)clear;
- (void)render;
- (id<SceneObject>)addObject:(id<SceneObject>)aObject;
- (void)removeObject:(id<SceneObject>)aObject;
- (void)addImmediateModeObject:(id<SceneObject>)aObject;

- (void)addLight:(Light *)aLight;
- (void)removeLight:(Light *)aLight;

- (State *)currentState;
- (void)pushState;
- (void)popState;
// Executes a block with a copy of the current state as it's argument
- (void)withState:(void (^)(State *))block;
@end
