// Manages the graphics state

#import "TOpenGLView.h"
#import <GLMath.h>
#import "TCamera.h"

@class TScene, TState;

@protocol TSceneObject <NSObject>
- (void)render:(TScene *)aScene;
@end

@interface TScene : NSObject
@property(readonly) NSArray *objects;
@property(readonly) NSArray *lights;
@property(readwrite, assign) vec4_t ambientLight;
@property(readonly) NSArray *stateStack;
@property(readonly) matrix_stack_t *projMatStack;
@property(readonly) matrix_stack_t *worldMatStack;
@property(readwrite, retain) TCamera *camera;

- (void)initializeGLState;

+ (TScene *)globalScene;
- (void)render;
- (void)addObject:(id<TSceneObject>)aObject;
- (void)removeObject:(id<TSceneObject>)aObject;

- (TState *)currentState;
- (void)pushState;
- (void)popState;
@end
