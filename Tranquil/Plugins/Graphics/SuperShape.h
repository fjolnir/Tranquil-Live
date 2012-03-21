#import <TranquilCore/State.h>
#import <TranquilCore/Scene.h>

@interface SuperShape : NSObject <SceneObject>
@property(readwrite) float ss1a, ss1b, ss1m, ss1n1, ss1n2, ss1n3;
@property(readwrite) float ss2a, ss2b, ss2m, ss2n1, ss2n2, ss2n3;
@property(readwrite, nonatomic) float step;
@property(readwrite, retain) State *state;
@end
