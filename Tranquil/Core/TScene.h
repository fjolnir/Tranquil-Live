#import "TOpenGLView.h"
#import <GLMath.h>

@class TScene;

@protocol TSceneObject <NSObject>
- (void)render:(TScene *)aScene;
@end

@interface TScene : NSObject
@property(readonly) NSArray *objects;
@property(readonly) matrix_stack_t *projMatStack;
@property(readonly) matrix_stack_t *worldMatStack;

+ (TScene *)globalScene;
- (void)render:(TOpenGLView *)aView;
- (void)addObject:(id<TSceneObject>)aObject;
- (void)removeObject:(id<TSceneObject>)aObject;
@end
