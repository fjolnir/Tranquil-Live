#import "TGraphicsPlugin.h"
#import "TScriptContext.h"

@implementation TGraphicsPlugin
+ (BOOL)loadPlugin
{
	NSLog(@"Load graphics");
	return YES;
}
@end
