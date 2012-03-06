#import <TranquilCore/ScriptContext.h>
#import "Logger.h"

@class MainView, OverlayTextView;

@interface MainWindowController : NSWindowController <ScriptContextDelegate, LoggerDelegate>
@property(readwrite, retain) IBOutlet MainView *mainView;
@property(readwrite, retain) IBOutlet OverlayTextView *consoleView;
@property(readwrite, retain) IBOutlet NSTabView *tabView;

- (IBAction)switchScriptView:(id)sender;
- (IBAction)runActiveScript:(id)sender;
- (IBAction)runSelection:(id)sender;
@end
