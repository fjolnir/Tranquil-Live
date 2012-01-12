#import "TGraphicsPlugin.h"
#import "TScriptContext.h"
#import <GLMath.h>
#import "TGLErrorChecking.h"
#import "TScene.h"
#import "TCube.h"
#import "TState.h"
#import "TSphere.h"

@implementation TGraphicsPlugin
+ (BOOL)loadPlugin
{
	NSLog(@"Load graphics");

	TCube *cube = [[TCube alloc] initWithSize:1];
	cube.state.transform = mat4_mul(mat4_create_translation(1, 0, 0), mat4_create_rotation(degToRad(0), 1, 1, 0));
	//cube.state.transform = mat4_create_translation(3, -1, 0);
	//cube.state.transform = mat4_mul(cube.state.transform, mat4_create_rotation(45, 1, 1, 0));
	
	TSphere *sphere = [[TSphere alloc] initWithRadius:1 stacks:32 slices:32];
	sphere.state.transform = mat4_create_translation(-1, 0, 0);

	[[TScene globalScene] addObject:sphere];
	[[TScene globalScene] addObject:cube];
	
	return YES;
}
@end
