// Manages the graphics state

#import "GLMathWrapper.h"
#import "TCamera.h"

@class TScene, TState, Light;

@protocol TSceneObject <NSObject>
- (void)render:(TScene *)aScene;
@end

__attribute__((visibility("default"))) @interface TScene : NSObject
@property(readonly) NSArray *objects;
@property(readonly) NSArray *immediateModeObjects;
@property(readonly) NSArray *lights;
@property(readwrite) Vector4 *clearColor;
@property(readwrite) Vector4 *ambientLight;
@property(readonly) NSArray *stateStack;
@property(readonly) MatrixStack *projMatStack;
@property(readonly) MatrixStack *worldMatStack;
@property(readwrite, retain) TCamera *camera;

- (void)initializeGLState;

+ (TScene *)globalScene;

- (void)clear;
- (void)render;
- (void)addObject:(id<TSceneObject>)aObject;
- (void)removeObject:(id<TSceneObject>)aObject;
- (void)addImmediateModeObject:(id<TSceneObject>)aObject;

- (void)addLight:(Light *)aLight;
- (void)removeLight:(Light *)aLight;

- (TState *)currentState;
- (void)pushState;
- (void)popState;
// Executes a block with a copy of the current state as it's argument
- (void)withState:(void (^)(TState *))block;
@end
