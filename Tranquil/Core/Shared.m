#import "Shared.h"
#import "OpenGLLayer.h"

static NSOpenGLContext *_globalGlContext = nil;

NSOpenGLContext *GlobalGLContext(void) {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_globalGlContext = [[NSOpenGLContext alloc] initWithFormat:[OpenGLLayer pixelFormat] shareContext:nil];
	});
	return _globalGlContext;
}