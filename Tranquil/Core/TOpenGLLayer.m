#import "TOpenGLLayer.h"
#import "TScene.h"
#import "TAppDelegate.h"
#import <OpenGL/gl.h>
#import "TGLErrorChecking.h"

@implementation TOpenGLLayer

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
	return [[[NSOpenGLPixelFormat alloc] initWithAttributes:attrs] autorelease];

}
- (NSOpenGLPixelFormat *)openGLPixelFormatForDisplayMask:(uint32_t)mask
{
	return [[self class] pixelFormat];
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
		NSOpenGLPFAScreenMask, mask,
        0
    };
	return [[[NSOpenGLPixelFormat alloc] initWithAttributes:attrs] autorelease];
}

- (NSOpenGLContext *)openGLContextForPixelFormat:(NSOpenGLPixelFormat *)pixelFormat {
	
	NSOpenGLContext *ctx = TGlobalGLContext();//[[NSOpenGLContext alloc] initWithFormat:pixelFormat shareContext:TGlobalGLContext()];
	assert(ctx != nil);
	
	[ctx makeCurrentContext];
	GLint vSync = 1;
    [ctx setValues:&vSync forParameter:NSOpenGLCPSwapInterval];
	[[TScene globalScene] initializeGLState];
	
	return [ctx autorelease];
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
	[[TScene globalScene] render];
	
	glFinish();
	[context flushBuffer];
}

@end
