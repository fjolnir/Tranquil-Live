#import <GLMath/GLMath.h>

@interface Light : NSObject
@property vec3_t position;
@property vec4_t ambientColor, diffuseColor, specularColor;
@end
