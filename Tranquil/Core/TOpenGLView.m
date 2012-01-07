#import "TOpenGLView.h"
#import <OpenGL/gl.h>
#import <OpenGL/OpenGL.h>
#import <CoreVideo/CVDisplayLink.h>

@interface TOpenGLView () {
	NSTimer *_renderTimer;
	NSMutableArray *_renderables;
}
@end

@implementation TOpenGLView
@synthesize renderables=_renderables;
- (id)initWithFrame:(NSRect)frameRect
{
	NSOpenGLPixelFormatAttribute attrs[] = {
        NSOpenGLPFANoRecovery,
        NSOpenGLPFAColorSize, 24,
        NSOpenGLPFAAlphaSize, 8,
        NSOpenGLPFADepthSize, 16,
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAAccelerated,
        0
    };
    NSOpenGLPixelFormat *pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
	self = [super initWithFrame:frameRect pixelFormat:pixelFormat];
	[pixelFormat release];
	
	if(self)
		_renderables = [[NSMutableArray alloc] init];
	
	return self;
}
- (void)awakeFromNib
{
	NSMethodSignature *signature = [self methodSignatureForSelector:@selector(setNeedsDisplay:)];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	invocation.selector = @selector(setNeedsDisplay:);
	invocation.target = self;
	BOOL arg = YES;
	[invocation setArgument:&arg atIndex:2];
	
	_renderTimer = [[NSTimer timerWithTimeInterval:0.001
										invocation:invocation
										   repeats:YES] retain];
	[[NSRunLoop currentRunLoop] addTimer:_renderTimer 
								 forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:_renderTimer 
								 forMode:NSEventTrackingRunLoopMode];
}
- (void)prepareOpenGL
{
	GLint vSync = 1;
    [[self openGLContext] setValues:&vSync forParameter:NSOpenGLCPSwapInterval];
}

- (void)render
{
	double time = clock()/1000000.0;
	glClearColor(sin(time), 0, cos(time), 1);
	glClear(GL_COLOR_BUFFER_BIT);
    for(id<TOpenGLRenderable> renderable in _renderables)
		[renderable render];
	
	glFinish();
    [[self openGLContext] flushBuffer];
}

- (void)drawRect:(NSRect)dirtyRect
{
	[self render];
}

- (void)dealloc
{
	[_renderTimer invalidate];
	[_renderTimer release];
	[_renderables release];
	
	[super dealloc];
}

- (void)addRenderable:(id<TOpenGLRenderable>)aRenderable
{
	[_renderables addObject:aRenderable];
}
@end
