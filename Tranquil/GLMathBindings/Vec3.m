#import "Vec3.h"

@implementation Vec3
@synthesize vec=_vec;

+ (Vec3 *)withVec:(vec3_t)vec
{
    Vec3 *ret = [[self alloc] init];
    ret->_vec = vec;
    return [ret autorelease];
}
+ (Vec3 *)withX:(TQNumber *)x y:(TQNumber *)y z:(TQNumber *)z
{
    Vec3 *ret = [[self alloc] init];
    ret->_vec.x = [x floatValue];
    ret->_vec.y = [y floatValue];
    ret->_vec.z = [z floatValue];
    return [ret autorelease];
}
+ (Vec3 *)zero
{
    return [self withVec:GLMVec3_zero];
}

#pragma mark - Accessors

- (TQNumber *)x { return [TQNumber numberWithFloat:_vec.x]; }
- (TQNumber *)y { return [TQNumber numberWithFloat:_vec.y]; }
- (TQNumber *)z { return [TQNumber numberWithFloat:_vec.z]; }

- (id)setX:(TQNumber *)val { _vec.x = [val floatValue]; return nil; }
- (id)setY:(TQNumber *)val { _vec.y = [val floatValue]; return nil; }
- (id)setZ:(TQNumber *)val { _vec.z = [val floatValue]; return nil; }

- (NSMutableString *)toString
{
    return [NSMutableString stringWithFormat:@"<%@: %f, %f, %f>", [self class], _vec.x, _vec.y, _vec.z];
}

#pragma mark -

- (id)print
{
    printVec3(_vec);
    return nil;
}

#pragma mark - Operators
- (Vec3 *)add:(id)b
{
    Vec3 *ret = [[[self class] alloc] init];
    if(object_getClass(self) != object_getClass(b))
        ret->_vec = vec3_scalarAdd(_vec, [b floatValue]);
    else
        ret->_vec = vec3_add(_vec, ((Vec3 *)b)->_vec);
    return [ret autorelease];
}
- (Vec3 *)subtract:(id)b
{
    Vec3 *ret = [[[self class] alloc] init];
    if(object_getClass(self) != object_getClass(b))
        ret->_vec = vec3_scalarSub(_vec, [b floatValue]);
    else
        ret->_vec = vec3_sub(_vec, ((Vec3 *)b)->_vec);
    return [ret autorelease];
}
- (Vec3 *)multiply:(id)b
{
    Vec3 *ret = [[[self class] alloc] init];
    if(object_getClass(self) != object_getClass(b))
        ret->_vec = vec3_scalarMul(_vec, [b floatValue]);
    else
        ret->_vec = vec3_mul(_vec, ((Vec3 *)b)->_vec);
    return [ret autorelease];
}
- (Vec3 *)divideBy:(id)b
{
    Vec3 *ret = [[[self class] alloc] init];
    if(object_getClass(self) != object_getClass(b))
        ret->_vec = vec3_scalarDiv(_vec, [b floatValue]);
    else
        ret->_vec = vec3_div(_vec, ((Vec3 *)b)->_vec);
    return [ret autorelease];
}
- (Vec3 *)cross:(Vec3 *)b
{
    TQAssert(object_getClass(self) == object_getClass(b), @"Tried to get the cross product of a %@ and a %@", [self class], [b class]);
    Vec3 *ret = [[[self class] alloc] init];
    ret->_vec = vec3_cross(_vec, ((Vec3 *)b)->_vec);
    return [ret autorelease];
}
- (TQNumber *)dot:(Vec3 *)b
{
    TQAssert(object_getClass(self) == object_getClass(b), @"Tried to get the dot product of a %@ and a %@", [self class], [b class]);
    return [TQNumber numberWithFloat:vec3_dot(_vec, ((Vec3 *)b)->_vec)];
}
- (TQNumber *)dist:(Vec3 *)b
{
    TQAssert(object_getClass(self) == object_getClass(b), @"Tried to get the dot product of a %@ and a %@", [self class], [b class]);
    return [TQNumber numberWithFloat:vec3_dist(_vec, ((Vec3 *)b)->_vec)];
}
- (Vec3 *)negate
{
    Vec3 *ret = [[[self class] alloc] init];
    ret->_vec = vec3_negate(_vec);
    return [ret autorelease];
}
- (Vec3 *)ceil
{
    Vec3 *ret = [[[self class] alloc] init];
    ret->_vec = vec3_negate(_vec);
    return [ret autorelease];
}
- (Vec3 *)floor
{
    Vec3 *ret = [[[self class] alloc] init];
    ret->_vec = vec3_floor(_vec);
    return [ret autorelease];
}
- (Vec3 *)normalize
{
    Vec3 *ret = [[[self class] alloc] init];
    ret->_vec = vec3_normalize(_vec);
    return [ret autorelease];
}
- (TQNumber *)magnitude
{
    return [TQNumber numberWithFloat:vec3_mag(_vec)];
}

#pragma mark - TQBoxedObject compatibility

- (id)init
{
    if(!(self = [super init]))
        return nil;
    _size = sizeof(vec3_t);
    _isOnHeap = YES;
    return self;
}

- (void *)valuePtr
{
    return &_vec;
}

#pragma mark -

- (id)copyWithZone:(NSZone *)aZone
{
    return [[[self class] withVec:_vec] retain];
}
- (void)dealloc
{
    TQ_BATCH_DEALLOC
}
TQ_BATCH_IMPL(Vec3)
@end
