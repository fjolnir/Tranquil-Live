// Shaders in Tranquil must use the following variable names (u_:uniform a_:attribute):
// u_worldMatrix
// u_projMatrix
// u_cameraPosition
// u_globalAmbientColor
// u_lightCount
// u_lightPositions
// u_ambientColors
// u_diffuseColors
// u_specularColors

// a_position
// a_normal
// a_texCoord
// a_color
// a_shininess

#import <OpenGL/gl.h>
#import <OpenGL/glext.h>

#define ShaderLoadError @"shader.loaderror"

@interface Shader : NSObject
@property(readonly, nonatomic) GLuint program;
@property(retain, nonatomic) NSString *name;

+ (Shader *)activeShader;

+ (Shader *)shaderWithName:(NSString *)aName fragmentShader:(NSString *)aFragSrc vertexShader:(NSString *)aVertSrc;
- (id)initWithWithFragmentShader:(NSString *)aFragSrc vertexShader:(NSString *)aVertSrc;

- (NSArray *)getUniforms;
- (NSArray *)getAttributes;
- (GLint)getUniformLocation:(NSString *)aUniformName;
- (GLint)getAttributeLocation:(NSString *)aAttribName;

// Takes a block and calls it with the location of the requested variable only if it exists
-(void)withUniform:(NSString *)aUniformName do:(void (^)(GLuint))block;
-(void)withAttribute:(NSString *)aAttribName do:(void (^)(GLuint))block;

- (void)makeActive;
- (void)makeInactive;
@end
