#import "TAppDelegate.h"
#import "TMainWindowController.h"
#import "TScriptContext.h"
#import "TPluginManager.h"
#import "TScene.h"
#import "TShader.h"
#import "TState.h"
#import "TOpenGLView.h"
#import "TGLErrorChecking.h"
#import "TOpenGLLayer.h"

NSOpenGLContext *_globalGlContext = nil;

NSOpenGLContext *TGlobalGLContext() {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_globalGlContext = [[NSOpenGLContext alloc] initWithFormat:[TOpenGLLayer pixelFormat] shareContext:nil];
	});
	return _globalGlContext;
}

@implementation TAppDelegate
@synthesize glView;

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
	NSString *path = [[NSBundle mainBundle] pathForResource:@"startup" ofType:@"lua" inDirectory:@"Scripts"];
	NSString *bootScript = [NSString stringWithContentsOfFile:path usedEncoding:NULL error:nil];
	TScriptError *err = nil;
	[[TScriptContext sharedContext] executeScript:bootScript error:&err];
	if(err) {
		NSLog(@"Error executing startup script: %@", err);
		[NSApp terminate:nil];
	}

	[TGlobalGLContext() makeCurrentContext];
	TCheckGLError();
	NSString *fragSrc = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"simple" ofType:@"fsh" inDirectory:@"Shaders"]
											  usedEncoding:NULL error:NULL];
	NSString *vertSrc = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"simple" ofType:@"vsh" inDirectory:@"Shaders"]
											  usedEncoding:NULL error:NULL];

	TShader *shader = [TShader shaderWithName:@"Simple" fragmentShader:fragSrc vertexShader:vertSrc];
	TCheckGLError();
	[[TScene globalScene] currentState].shader = shader;

	[[TPluginManager sharedManager] loadAllPlugins];
}

@end
