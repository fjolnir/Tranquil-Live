#import "Quat.h"
#import "Vec4.h"
#import "Vec3.h"

@implementation Quat
@synthesize quat=_quat;

+ (Quat *)withQuat:(quat_t)quat
{
    Quat *ret = [[self alloc] init];
    ret->_quat = quat;
    return [ret autorelease];
}
+ (Quat *)withX:(TQNumber *)x y:(TQNumber *)y z:(TQNumber *)z angle:(TQNumber *)theta
{
    return [self withQuat:quat_createf([x floatValue], [y floatValue], [z floatValue], [theta floatValue])];
}

+ (Quat *)withX:(TQNumber *)x y:(TQNumber *)y z:(TQNumber *)z w:(TQNumber *)w
{
    Quat *ret = [[self alloc] init];
    ret->_quat.vec.x  = [x floatValue];
    ret->_quat.vec.y  = [y floatValue];
    ret->_quat.vec.z  = [z floatValue];
    ret->_quat.scalar = [w floatValue];
    return [ret autorelease];
}

#pragma mark - Accessors

- (TQNumber *)x { return [TQNumber numberWithFloat:_quat.vec.x];  }
- (TQNumber *)y { return [TQNumber numberWithFloat:_quat.vec.y];  }
- (TQNumber *)z { return [TQNumber numberWithFloat:_quat.vec.z];  }
- (TQNumber *)w { return [TQNumber numberWithFloat:_quat.scalar]; }
- (Vec3 *)vec   { return [Vec3 withVec:_quat.vec];                }

- (id)setX:(TQNumber *)val { _quat.vec.x  = [val floatValue]; return nil; }
- (id)setY:(TQNumber *)val { _quat.vec.y  = [val floatValue]; return nil; }
- (id)setZ:(TQNumber *)val { _quat.vec.z  = [val floatValue]; return nil; }
- (id)setW:(TQNumber *)val { _quat.scalar = [val floatValue]; return nil; }
- (id)setVec:(Vec3 *)vec   { _quat.vec = vec.vec;             return nil; }

- (NSMutableString *)toString
{
    return [NSMutableString stringWithFormat:@"<%@: %f, %f, %f, %f>", [self class], _quat.vec.x, _quat.vec.y, _quat.vec.z, _quat.scalar];
}

#pragma mark -

- (id)print
{
    printQuat(_quat);
    return nil;
}

#pragma mark - Operators
- (Quat *)multiply:(id)b
{
    Quat *ret = [[self class] new];
    if(object_getClass(self) != object_getClass(b))
        TQAssert(NO, @"Quaternions can only be multiplied with quaternions"); // TODO implement vector mul
    else
        ret->_quat = quat_multQuat(_quat, ((Quat *)b)->_quat);
    return [ret autorelease];
}
- (TQNumber *)dot:(Quat *)b
{
    TQAssert(object_getClass(self) != object_getClass(b), @"Tried to take the dot product of a %@ and %@", [self class], [b class]);
    return [TQNumber numberWithFloat:quat_dotProduct(_quat, ((Quat *)b)->_quat)];
}
- (id)rotatePoint:(id)b
{
    if([b isKindOfClass:[Vec3 class]]) {
        vec3_t v3 = [(Vec3 *)b vec];
        vec4_t v4 = vec4_create(v3.x, v3.y, v3.z, 1);
        v4 = quat_rotatePoint(_quat, v4);
        v3.x = v4.x;
        v3.y = v4.y;
        v3.z = v4.z;
        return [Vec3 withVec:v3];
    }
    TQAssert([b isKindOfClass:[Vec4 class]], @"Quaternions can only rotate Vec3&4s");
    return [Vec4 withVec:quat_rotatePoint(_quat, [(Vec4 *)b vec])];
}

- (Quat *)inverse
{
    return [[self class] withQuat:quat_inverse(_quat)];
}
- (Quat *)normalize
{
    return [[self class] withQuat:quat_normalize(_quat)];
}

#pragma mark - TQBoxedObject compatibility

- (id)init
{
    if(!(self = [super init]))
        return nil;
    _size = sizeof(quat_t);
    _isOnHeap = YES;
    return self;
}

- (void *)valuePtr
{
    return &_quat;
}

#pragma mark -

- (id)copyWithZone:(NSZone *)aZone
{
    return [[[self class] withQuat:_quat] retain];
}
- (void)dealloc
{
    TQ_BATCH_DEALLOC
}
TQ_BATCH_IMPL(Quat)
@end
