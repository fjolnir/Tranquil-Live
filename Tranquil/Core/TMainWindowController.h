@class TOpenGLView, TOverlayTextView;

@interface TMainWindowController : NSWindowController
@property(readwrite, retain) IBOutlet TOpenGLView *mainView;
@property(readwrite, retain) IBOutlet TOverlayTextView *scriptView;

- (IBAction)runActiveScript:(id)sender;
@end
