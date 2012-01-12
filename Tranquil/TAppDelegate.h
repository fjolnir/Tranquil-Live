@class TOpenGLView;

NSOpenGLContext *TGlobalGLContext();

@interface TAppDelegate : NSObject <NSApplicationDelegate>
@property(readonly) IBOutlet TOpenGLView *glView;
@end
