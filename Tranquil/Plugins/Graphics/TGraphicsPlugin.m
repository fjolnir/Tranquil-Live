#import "TGraphicsPlugin.h"
#import "TScriptContext.h"
#import <GLMath.h>
#import "TGLErrorChecking.h"
#import "TScene.h"
#import "Cube.h"
#import "TState.h"
#import "Sphere.h"
#import "Plane.h"


@implementation TGraphicsPlugin
+ (BOOL)loadPlugin
{
	TLog(@"Load graphics %@ %@ %@", TGlobalScene(),TGlobalState(), TGlobalState().shader);

	Cube *cube = [[Cube alloc] initWithSize:1];
	cube.state.transform = mat4_mul(mat4_create_translation(1, 0, 0), mat4_create_rotation(degToRad(0), 1, 1, 0));
	//cube.state.transform = mat4_create_translation(3, -1, 0);
	//cube.state.transform = mat4_mul(cube.state.transform, mat4_create_rotation(45, 1, 1, 0));
	
	Sphere *sphere = [[Sphere alloc] initWithRadius:1 stacks:64 slices:64];
	sphere.state.transform = mat4_create_translation(-1, 0, 0);

	Plane *plane = [[Plane alloc] initWithSubdivisions:vec2_create(20, 20)];
	plane.state.transform = mat4_mul(mat4_create_scale(2, 1, 2), mat4_create_translation(0, 0, 0));
	plane.state.transform = mat4_mul(mat4_create_translation(0, -1, 0), mat4_create_scale(10, 1, 10));
	[[TScene globalScene] addObject:plane];
	[[TScene globalScene] addObject:sphere];
	[[TScene globalScene] addObject:cube];
	[plane release];
	[cube release];
	[sphere release];
	return YES;
}
@end
