#import "TScene.h"
#import "TGLErrorChecking.h"

extern NSOpenGLContext *TGlobalGLContext(void);
#define TGlobalScene() [TScene globalScene]
#define TGlobalState() [[TScene globalScene] currentState]

#pragma mark - Debug logging

#ifdef DEBUG
#define TLog(fmt, ...) NSLog([@"%@:%u (%s): " stringByAppendingFormat:@"%@\n", fmt], [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __func__, ## __VA_ARGS__)
#else
#define TLog(fmt, ...)
#endif