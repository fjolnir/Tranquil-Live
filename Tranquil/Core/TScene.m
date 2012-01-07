#import "TScene.h"
#import "TScriptContext.h"

@implementation TScene
- (void)render
{
	[[TScriptContext sharedContext] callGlobalFunction:@"_frameCallback" withArguments:nil];
}
@end
