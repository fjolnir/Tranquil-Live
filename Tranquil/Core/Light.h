@class Vec3, Vec4;

@interface Light : NSObject
@property(readwrite, copy) Vec3 *position;
@property(readwrite, copy) Vec4 *ambientColor, *diffuseColor, *specularColor;
@end
