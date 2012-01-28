#import "Scene.h"
#import "GLErrorChecking.h"

extern NSOpenGLContext *GlobalGLContext(void);
#define GlobalScene() [Scene globalScene]
#define GlobalState() [[Scene globalScene] currentState]

#pragma mark - Debug logging

#ifdef DEBUG
#define TLog(fmt, ...) NSLog([@"%@:%u (%s): " stringByAppendingFormat:@"%@\n", fmt], [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __func__, ## __VA_ARGS__)
#else
#define TLog(fmt, ...)
#endif