#define kTranquilFinishedLaunching @"kTranquilFinishedLaunching"

@class MainView;

@interface TAppDelegate : NSObject <NSApplicationDelegate>
@property(readonly) IBOutlet MainView *glView;
@end
