@interface Texture : NSObject
@property(readonly, nonatomic) GLuint texId;

+ (Texture *)load:(NSString *)aPath;

+ (GLuint)loadTextureAtPath:(NSString *)aPath
                  minFilter:(GLuint)aMinFilter
                  maxFilter:(GLuint)aMaxFilter
               buildMipMaps:(BOOL)aShouldBuildMipMaps;

+ (Texture *)textureWithContentsOfFile:(NSString *)aPath
                             minFilter:(GLuint)aMinFilter
                             maxFilter:(GLuint)aMaxFilter
                          buildMipMaps:(BOOL)aShouldBuildMipMaps;

- (id)initWithContentsOfFile:(NSString *)aPath
                   minFilter:(GLuint)aMinFilter
                   maxFilter:(GLuint)aMaxFilter
                buildMipMaps:(BOOL)aShouldBuildMipMaps;
@end
