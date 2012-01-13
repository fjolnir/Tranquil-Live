#import <GLMath.h>

__attribute__((visibility("default"))) @interface TLight : NSObject
@property vec4_t position, ambientColor, diffuseColor, specularColor;
@end
