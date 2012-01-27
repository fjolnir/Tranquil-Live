#import "GLMathWrapper.h"

__attribute__((visibility("default"))) @interface Light : NSObject
@property Vector4 *position, *ambientColor, *diffuseColor, *specularColor;
@end
