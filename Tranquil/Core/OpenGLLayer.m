#import "OpenGLLayer.h"
#import "Scene.h"
#import "TAppDelegate.h"
#import <OpenGL/gl.h>
#import "GLErrorChecking.h"

@implementation OpenGLLayer

+ (NSOpenGLPixelFormat *)pixelFormat
{
	NSOpenGLPixelFormatAttribute attrs[] = {
        NSOpenGLPFANoRecovery,
        NSOpenGLPFAColorSize, 24,
        NSOpenGLPFAAlphaSize, 8,
        NSOpenGLPFADepthSize, 24,
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAAccelerated,
		NSOpenGLPFAMultisample,
		NSOpenGLPFASampleBuffers, (NSOpenGLPixelFormatAttribute)1,
		NSOpenGLPFASamples, (NSOpenGLPixelFormatAttribute)4,
        0
    };
	return [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];

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
	
	glFinish();
	[context flushBuffer];
}

@end
