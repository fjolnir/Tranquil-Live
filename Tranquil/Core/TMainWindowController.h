@class TOpenGLView, TOverlayTextView, TScene;

@interface TMainWindowController : NSWindowController
@property(readwrite, retain) IBOutlet TOpenGLView *mainView;
@property(readwrite, retain) IBOutlet TOverlayTextView *scriptView;
@property(readwrite, retain) TScene *scene;

- (IBAction)runActiveScript:(id)sender;
@end
