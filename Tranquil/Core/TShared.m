#import "TShared.h"
#import "TOpenGLLayer.h"

static NSOpenGLContext *_globalGlContext = nil;

NSOpenGLContext *TGlobalGLContext(void) {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_globalGlContext = [[NSOpenGLContext alloc] initWithFormat:[TOpenGLLayer pixelFormat] shareContext:nil];
	});
	return _globalGlContext;
}