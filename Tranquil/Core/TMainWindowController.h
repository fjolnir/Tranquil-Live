@class TMainView, TOverlayTextView;

@interface TMainWindowController : NSWindowController
@property(readwrite, retain) IBOutlet TMainView *mainView;
@property(readwrite, retain) IBOutlet TOverlayTextView *scriptView;

- (IBAction)runActiveScript:(id)sender;
@end
