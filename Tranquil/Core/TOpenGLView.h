@protocol TOpenGLRenderable
- (void)render;
@end

@interface TOpenGLView : NSOpenGLView
@property(readonly) NSArray *renderables;
- (void)addRenderable:(id<TOpenGLRenderable>)aRenderable;
@end
