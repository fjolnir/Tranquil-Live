@class MainView, OverlayTextView;

@interface MainWindowController : NSWindowController
@property(readwrite, retain) IBOutlet MainView *mainView;
@property(readwrite, retain) IBOutlet OverlayTextView *scriptView;

- (IBAction)runActiveScript:(id)sender;
- (IBAction)runSelection:(id)sender;
@end
