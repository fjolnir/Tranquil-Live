#import "Mat4.h"
#import "Vec3.h"
#import "Vec4.h"

@implementation Mat4
@synthesize mat=_mat;

+ (Mat4 *)withMat:(mat4_t)mat
{
    Mat4 *ret = [[self alloc] init];
    ret->_mat = mat;
    return [ret autorelease];
}

+ (Mat4 *)identity
{
    return [self withMat:GLMMat4_identity];
}

+ (Mat4 *)zero
{
    return [self withMat:GLMMat4_zero];
}

+ (Mat4 *)scale:(Vec3 *)aVec
{
    return [self withMat:mat4_create_scale(aVec.vec.x, aVec.vec.y, aVec.vec.z)];
}
+ (Mat4 *)translation:(Vec3 *)aVec
{
    return [self withMat:mat4_create_translation(aVec.vec.x, aVec.vec.y, aVec.vec.z)];
}
+ (Mat4 *)rotationWithAngle:(TQNumber *)aAngle axis:(Vec3 *)aVec
{
    return [self withMat:mat4_create_rotation([aAngle floatValue], aVec.vec.x, aVec.vec.y, aVec.vec.z)];
}

#pragma mark - Accessors

- (TQNumber *)m00
{
    return [TQNumber numberWithFloat:_mat.m00];
}
- (id)setM00:(TQNumber *)aVal
{
    _mat.m00 = [aVal floatValue];
    return nil;
}
- (TQNumber *)m01
{
    return [TQNumber numberWithFloat:_mat.m01];
}
- (id)setM01:(TQNumber *)aVal
{
    _mat.m01 = [aVal floatValue];
    return nil;
}
- (TQNumber *)m02
{
    return [TQNumber numberWithFloat:_mat.m02];
}
- (id)setM02:(TQNumber *)aVal
{
    _mat.m02 = [aVal floatValue];
    return nil;
}
- (TQNumber *)m03
{
    return [TQNumber numberWithFloat:_mat.m03];
}
- (id)setM03:(TQNumber *)aVal
{
    _mat.m03 = [aVal floatValue];
    return nil;
}
- (TQNumber *)m10
{
    return [TQNumber numberWithFloat:_mat.m10];
}
- (id)setM10:(TQNumber *)aVal
{
    _mat.m10 = [aVal floatValue];
    return nil;
}
- (TQNumber *)m11
{
    return [TQNumber numberWithFloat:_mat.m11];
}
- (id)setM11:(TQNumber *)aVal
{
    _mat.m11 = [aVal floatValue];
    return nil;
}
- (TQNumber *)m12
{
    return [TQNumber numberWithFloat:_mat.m12];
}
- (id)setM12:(TQNumber *)aVal
{
    _mat.m12 = [aVal floatValue];
    return nil;
}
- (TQNumber *)m13
{
    return [TQNumber numberWithFloat:_mat.m13];
}
- (id)setM13:(TQNumber *)aVal
{
    _mat.m13 = [aVal floatValue];
    return nil;
}
- (TQNumber *)m20
{
    return [TQNumber numberWithFloat:_mat.m20];
}
- (id)setM20:(TQNumber *)aVal
{
    _mat.m20 = [aVal floatValue];
    return nil;
}
- (TQNumber *)m21
{
    return [TQNumber numberWithFloat:_mat.m21];
}
- (id)setM21:(TQNumber *)aVal
{
    _mat.m21 = [aVal floatValue];
    return nil;
}
- (TQNumber *)m22
{
    return [TQNumber numberWithFloat:_mat.m22];
}
- (id)setM22:(TQNumber *)aVal
{
    _mat.m22 = [aVal floatValue];
    return nil;
}
- (TQNumber *)m23
{
    return [TQNumber numberWithFloat:_mat.m23];
}
- (id)setM23:(TQNumber *)aVal
{
    _mat.m23 = [aVal floatValue];
    return nil;
}
- (TQNumber *)m30
{
    return [TQNumber numberWithFloat:_mat.m30];
}
- (id)setM30:(TQNumber *)aVal
{
    _mat.m30 = [aVal floatValue];
    return nil;
}
- (TQNumber *)m31
{
    return [TQNumber numberWithFloat:_mat.m31];
}
- (id)setM31:(TQNumber *)aVal
{
    _mat.m31 = [aVal floatValue];
    return nil;
}
- (TQNumber *)m32
{
    return [TQNumber numberWithFloat:_mat.m32];
}
- (id)setM32:(TQNumber *)aVal
{
    _mat.m32 = [aVal floatValue];
    return nil;
}
- (TQNumber *)m3
{
    return [TQNumber numberWithFloat:_mat.m33];
}
- (id)setM33:(TQNumber *)aVal
{
    _mat.m33 = [aVal floatValue];
    return nil;
}

- (NSMutableString *)toString
{
    return [NSMutableString stringWithFormat:@"<%@\n[%.2f, %.2f, %.2f, %.2f]\n[%.2f, %.2f, %.2f, %.2f]\n[%.2f, %.2f, %.2f, %.2f]\n[%.2f, %.2f, %.2f, %.2f]\n>", [self class],
            _mat.m00, _mat.m01, _mat.m02, _mat.m03,
            _mat.m10, _mat.m11, _mat.m12, _mat.m13,
            _mat.m20, _mat.m21, _mat.m22, _mat.m23,
            _mat.m30, _mat.m31, _mat.m32, _mat.m33];
}

#pragma mark -

- (id)print
{
    printMat4(_mat);
    return nil;
}

#pragma mark - Operators

- (id)multiply:(id)b
{
    if([b isKindOfClass:[Vec4 class]])
        return [Vec4 withVec:vec4_mul_mat4([(Vec4 *)b vec], _mat)];
    else if([b isKindOfClass:[self class]])
        return [[self class] withMat:mat4_mul(_mat, ((Mat4 *)b)->_mat)];

    [NSException raise:NSInvalidArgumentException format:@"Matrices cannot be multiplied with a %@", [b class]];
    return nil;
}

- (Mat4 *)inverse
{
    bool succeeded = YES;
    Mat4 *ret = [[self class] withMat:mat4_inverse(_mat, &succeeded)];
    return succeeded ? ret : nil;
}

#pragma mark - TQBoxedObject compatibility

- (id)init
{
    if(!(self = [super init]))
        return nil;
    _size = sizeof(mat4_t);
    _isOnHeap = YES;
    return self;
}

- (void *)valuePtr
{
    return &_mat;
}

#pragma mark -

- (id)copyWithZone:(NSZone *)aZone
{
    return [[[self class] withMat:_mat] retain];
}

- (void)dealloc
{
    TQ_BATCH_DEALLOC
}

TQ_BATCH_IMPL(Mat4)
@end
