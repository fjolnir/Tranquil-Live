#import <OpenGL/gl.h>
#import "Texture.h"

@implementation Texture {
@private
    GLuint _texId;
}

@synthesize texId = _texId;


+ (GLuint)loadTextureAtPath:(NSString *)aPath
                  minFilter:(GLuint)aMinFilter
                  maxFilter:(GLuint)aMaxFilter
               buildMipMaps:(BOOL)aShouldBuildMipMaps {
    glEnable(GL_TEXTURE_2D);
    CFURLRef textureUrl = (CFURLRef)[NSURL fileURLWithPath:[aPath stringByExpandingTildeInPath]];
    assert(textureUrl != nil);
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL(textureUrl, NULL);
    assert(imageSource != NULL);
    assert(CGImageSourceGetCount(imageSource) > 0);
    
    CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
    assert(image != NULL);
    
    NSInteger width = CGImageGetWidth(image);
    NSInteger height = CGImageGetHeight(image);
    
    void *data = malloc(width * height * 4);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    assert(colorSpace != NULL);
    
    CGContextRef context = CGBitmapContextCreate(data,
                                                 width,
                                                 height,
                                                 8,
                                                 width * 4,
                                                 colorSpace,
                                                 kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);
    assert(context != NULL);
    CGContextSetBlendMode(context, kCGBlendModeCopy);

    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1, -1);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    
    glPixelStorei(GL_UNPACK_ROW_LENGTH, width);
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    GLuint textureId;
    glGenTextures(1, &textureId);
    glBindTexture(GL_TEXTURE_2D, textureId);

    glTexImage2D(GL_TEXTURE_2D,
                 0,
                 GL_RGBA,
                 (GLsizei)width,
                 (GLsizei)height,
                 0,
                 GL_BGRA,
                 GL_UNSIGNED_INT_8_8_8_8_REV,
                 data);
    glTexParameteri(GL_TEXTURE_2D,
                    GL_TEXTURE_WRAP_S,
                    GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D,
                    GL_TEXTURE_WRAP_T,
                    GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D,
                    GL_TEXTURE_MAG_FILTER,
                    aMaxFilter);
    glTexParameteri(GL_TEXTURE_2D,
                    GL_TEXTURE_MIN_FILTER,
                    aMinFilter);
    
    if(aShouldBuildMipMaps)
        glGenerateMipmap(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    CFRelease(context);
    CFRelease(colorSpace);
    free(data);
    CFRelease(image);
    CFRelease(imageSource);
    
    return textureId;
}

+ (Texture *)textureWithContentsOfFile:(NSString *)aPath minFilter:(GLuint)aMinFilter maxFilter:(GLuint)aMaxFilter buildMipMaps:(BOOL)aShouldBuildMipMaps
{
    return [[[self alloc] initWithContentsOfFile:aPath
                                      minFilter:aMinFilter
                                      maxFilter:aMaxFilter
                                    buildMipMaps:aShouldBuildMipMaps] autorelease];
}

- (id)initWithContentsOfFile:(NSString *)aPath minFilter:(GLuint)aMinFilter maxFilter:(GLuint)aMaxFilter buildMipMaps:(BOOL)aShouldBuildMipMaps
{
    if(!(self = [super init]))
        return nil;

    _texId = [[self class] loadTextureAtPath:aPath
                                   minFilter:aMinFilter
                                   maxFilter:aMaxFilter
                                buildMipMaps:aShouldBuildMipMaps];

    return self;
}

@end
