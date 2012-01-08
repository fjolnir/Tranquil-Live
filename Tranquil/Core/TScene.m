#import "TScene.h"
#import "TScriptContext.h"

static TScene *_GlobalScene = nil;

@interface TScene () {
@private
	NSMutableArray *_objects;
}
@end
@implementation TScene
@synthesize projMatStack=_projStack, worldMatStack=_worldStack, objects=_objects;

+ (TScene *)globalScene
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_GlobalScene = [[self alloc] init];
	});
	return _GlobalScene;
}

- (id)init
{
	self = [super init];
	if(!self) return nil;
	_projStack = matrix_stack_create(8);
	_worldStack = matrix_stack_create(32);
	_objects = [[NSMutableArray alloc] init];
	
	return self;
}

- (void)dealloc
{
	matrix_stack_destroy(_projStack);
	matrix_stack_destroy(_worldStack);
	[_objects release];
	
	[super dealloc];
}
- (void)render:(TOpenGLView *)aView
{
	
	// Notify the script
	[[TScriptContext sharedContext] callGlobalFunction:@"_frameCallback" withArguments:nil];
}

#pragma - Accessors
- (void)addObject:(id<TSceneObject>)aObject
{
	[_objects removeObject:aObject];
}
- (void)removeObject:(id<TSceneObject>)aObject
{
	[_objects removeObject:aObject];
}
@end
