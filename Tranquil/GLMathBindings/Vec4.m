#import "Vec4.h"

@implementation Vec4
@synthesize vec=_vec;

+ (Vec4 *)withVec:(vec4_t)vec
{
    Vec4 *ret = [[self alloc] init];
    ret->_vec = vec;
    return [ret autorelease];
}
+ (Vec4 *)withX:(TQNumber *)x y:(TQNumber *)y z:(TQNumber *)z w:(TQNumber *)w
{
    Vec4 *ret = [[self alloc] init];
    ret->_vec.x = [x floatValue];
    ret->_vec.y = [y floatValue];
    ret->_vec.z = [z floatValue];
    ret->_vec.w = [w floatValue];
    return [ret autorelease];
}
+ (Vec4 *)zero
{
    return [self withVec:GLMVec4_zero];
}

#pragma mark - Accessors

- (TQNumber *)x { return [TQNumber numberWithFloat:_vec.x]; }
- (TQNumber *)y { return [TQNumber numberWithFloat:_vec.y]; }
- (TQNumber *)z { return [TQNumber numberWithFloat:_vec.z]; }
- (TQNumber *)w { return [TQNumber numberWithFloat:_vec.w]; }

- (id)setX:(TQNumber *)val { _vec.x = [val floatValue]; return nil; }
- (id)setY:(TQNumber *)val { _vec.y = [val floatValue]; return nil; }
- (id)setZ:(TQNumber *)val { _vec.z = [val floatValue]; return nil; }
- (id)setW:(TQNumber *)val { _vec.w = [val floatValue]; return nil; }

- (NSMutableString *)toString
{
    return [NSMutableString stringWithFormat:@"<%@: %f, %f, %f, %f>", [self class], _vec.x, _vec.y, _vec.z, _vec.w];
}

#pragma mark -

- (id)print
{
    printVec4(_vec);
    return nil;
}

#pragma mark - Operators
- (Vec4 *)add:(id)b
{
    Vec4 *ret = [[[self class] alloc] init];
    if(object_getClass(self) != object_getClass(b))
        ret->_vec = vec4_scalarAdd(_vec, [b floatValue]);
    else
        ret->_vec = vec4_add(_vec, ((Vec4 *)b)->_vec);
    return [ret autorelease];
}
- (Vec4 *)subtract:(id)b
{
    Vec4 *ret = [[[self class] alloc] init];
    if(object_getClass(self) != object_getClass(b))
        ret->_vec = vec4_scalarSub(_vec, [b floatValue]);
    else
        ret->_vec = vec4_sub(_vec, ((Vec4 *)b)->_vec);
    return [ret autorelease];
}
- (Vec4 *)multiply:(id)b
{
    Vec4 *ret = [[[self class] alloc] init];
    if(object_getClass(self) != object_getClass(b))
        ret->_vec = vec4_scalarMul(_vec, [b floatValue]);
    else
        ret->_vec = vec4_mul(_vec, ((Vec4 *)b)->_vec);
    return [ret autorelease];
}
- (Vec4 *)divideBy:(id)b
{
    Vec4 *ret = [[[self class] alloc] init];
    if(object_getClass(self) != object_getClass(b))
        ret->_vec = vec4_scalarDiv(_vec, [b floatValue]);
    else
        ret->_vec = vec4_div(_vec, ((Vec4 *)b)->_vec);
    return [ret autorelease];
}
- (Vec4 *)cross:(Vec4 *)b
{
    TQAssert(object_getClass(self) == object_getClass(b), @"Tried to get the cross product of a %@ and a %@", [self class], [b class]);
    Vec4 *ret = [[[self class] alloc] init];
    ret->_vec = vec4_cross(_vec, ((Vec4 *)b)->_vec);
    return [ret autorelease];
}
- (TQNumber *)dot:(Vec4 *)b
{
    TQAssert(object_getClass(self) == object_getClass(b), @"Tried to get the dot product of a %@ and a %@", [self class], [b class]);
    return [TQNumber numberWithFloat:vec4_dot(_vec, ((Vec4 *)b)->_vec)];
}
- (TQNumber *)dist:(Vec4 *)b
{
    TQAssert(object_getClass(self) == object_getClass(b), @"Tried to get the dot product of a %@ and a %@", [self class], [b class]);
    return [TQNumber numberWithFloat:vec4_dist(_vec, ((Vec4 *)b)->_vec)];
}
- (Vec4 *)negate
{
    Vec4 *ret = [[[self class] alloc] init];
    ret->_vec = vec4_negate(_vec);
    return [ret autorelease];
}
- (Vec4 *)ceil
{
    Vec4 *ret = [[[self class] alloc] init];
    ret->_vec = vec4_negate(_vec);
    return [ret autorelease];
}
- (Vec4 *)floor
{
    Vec4 *ret = [[[self class] alloc] init];
    ret->_vec = vec4_floor(_vec);
    return [ret autorelease];
}
- (Vec4 *)normalize
{
    Vec4 *ret = [[[self class] alloc] init];
    ret->_vec = vec4_normalize(_vec);
    return [ret autorelease];
}
- (TQNumber *)magnitude
{
    return [TQNumber numberWithFloat:vec4_mag(_vec)];
}

#pragma mark - TQBoxedObject compatibility

- (id)init
{
    if(!(self = [super init]))
        return nil;
    _size = sizeof(vec4_t);
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

TQ_BATCH_IMPL(Vec4)
@end
