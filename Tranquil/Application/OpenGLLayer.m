#import "OpenGLLayer.h"
#import <TranquilCore/TranquilCore.h>
#import "TAppDelegate.h"
#import <OpenGL/gl.h>

@implementation OpenGLLayer

+ (NSOpenGLPixelFormat *)pixelFormat
{
	return [Scene pixelFormat];

}
- (NSOpenGLPixelFormat *)openGLPixelFormatForDisplayMask:(uint32_t)mask
{
	return [[self class] pixelFormat];
}

- (NSOpenGLContext *)openGLContextForPixelFormat:(NSOpenGLPixelFormat *)pixelFormat {

	NSOpenGLContext *ctx = GlobalGLContext();
	assert(ctx != nil);

	[ctx makeCurrentContext];
	GLint vSync = 1;
    [ctx setValues:&vSync forParameter:NSOpenGLCPSwapInterval];
	[[Scene globalScene] initializeGLState];

	return ctx;
}

- (BOOL)canDrawInOpenGLContext:(NSOpenGLContext *)context
                   pixelFormat:(NSOpenGLPixelFormat *)pixelFormat
                  forLayerTime:(CFTimeInterval)timeInterval
                  displayTime:(const CVTimeStamp *)timeStamp
{
	return YES;
}

// Keeps the viewport size up to date
- (BOOL)needsDisplayOnBoundsChange
{
	return YES;
}

- (void)drawInOpenGLContext:(NSOpenGLContext *)context
				pixelFormat:(NSOpenGLPixelFormat *)pixelFormat
               forLayerTime:(CFTimeInterval)timeInterval
				displayTime:(const CVTimeStamp *)timeStamp
{
	[[Scene globalScene] render];

//	glFinish();
    glFlush();
	[context flushBuffer];
}

@end
