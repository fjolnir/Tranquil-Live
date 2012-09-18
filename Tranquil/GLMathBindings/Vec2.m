#import "Vec2.h"

@implementation Vec2
@synthesize vec=_vec;

+ (Vec2 *)withVec:(vec2_t)vec
{
    Vec2 *ret = [[self alloc] init];
    ret->_vec = vec;
    return [ret autorelease];
}
+ (Vec2 *)withX:(TQNumber *)x y:(TQNumber *)y
{
    Vec2 *ret = [[self alloc] init];
    ret->_vec.x = [x floatValue];
    ret->_vec.y = [y floatValue];
    return [ret autorelease];
}
+ (Vec2 *)zero
{
    return [self withVec:GLMVec2_zero];
}

#pragma mark - Accessors

- (TQNumber *)x { return [TQNumber numberWithFloat:_vec.x]; }
- (TQNumber *)y { return [TQNumber numberWithFloat:_vec.y]; }

- (id)setX:(TQNumber *)val { _vec.x = [val floatValue]; return nil; }
- (id)setY:(TQNumber *)val { _vec.y = [val floatValue]; return nil; }

- (NSMutableString *)toString
{
    return [NSMutableString stringWithFormat:@"<%@: %f, %f>", [self class], _vec.x, _vec.y];
}

#pragma mark -

- (id)print
{
    printVec2(_vec);
    return nil;
}

#pragma mark - Operators
- (Vec2 *)add:(id)b
{
    Vec2 *ret = [[[self class] alloc] init];
    if(object_getClass(self) != object_getClass(b))
        ret->_vec = vec2_scalarAdd(_vec, [b floatValue]);
    else
        ret->_vec = vec2_add(_vec, ((Vec2 *)b)->_vec);
    return [ret autorelease];
}
- (Vec2 *)subtract:(id)b
{
    Vec2 *ret = [[[self class] alloc] init];
    if(object_getClass(self) != object_getClass(b))
        ret->_vec = vec2_scalarSub(_vec, [b floatValue]);
    else
        ret->_vec = vec2_sub(_vec, ((Vec2 *)b)->_vec);
    return [ret autorelease];
}
- (Vec2 *)multiply:(id)b
{
    Vec2 *ret = [[[self class] alloc] init];
    if(object_getClass(self) != object_getClass(b))
        ret->_vec = vec2_scalarMul(_vec, [b floatValue]);
    else
        ret->_vec = vec2_mul(_vec, ((Vec2 *)b)->_vec);
    return [ret autorelease];
}
- (Vec2 *)divideBy:(id)b
{
    Vec2 *ret = [[[self class] alloc] init];
    if(object_getClass(self) != object_getClass(b))
        ret->_vec = vec2_scalarDiv(_vec, [b floatValue]);
    else
        ret->_vec = vec2_div(_vec, ((Vec2 *)b)->_vec);
    return [ret autorelease];
}

- (TQNumber *)dist:(Vec2 *)b
{
    TQAssert(object_getClass(self) == object_getClass(b), @"Tried to get the dot product of a %@ and a %@", [self class], [b class]);
    return [TQNumber numberWithFloat:vec2_dist(_vec, ((Vec2 *)b)->_vec)];
}
- (Vec2 *)negate
{
    Vec2 *ret = [[[self class] alloc] init];
    ret->_vec = vec2_negate(_vec);
    return [ret autorelease];
}
- (Vec2 *)ceil
{
    Vec2 *ret = [[[self class] alloc] init];
    ret->_vec = vec2_negate(_vec);
    return [ret autorelease];
}
- (Vec2 *)floor
{
    Vec2 *ret = [[[self class] alloc] init];
    ret->_vec = vec2_floor(_vec);
    return [ret autorelease];
}
- (Vec2 *)normalize
{
    Vec2 *ret = [[[self class] alloc] init];
    ret->_vec = vec2_normalize(_vec);
    return [ret autorelease];
}
- (TQNumber *)magnitude
{
    return [TQNumber numberWithFloat:vec2_mag(_vec)];
}

#pragma mark - TQBoxedObject compatibility

- (id)init
{
    if(!(self = [super init]))
        return nil;
    _size = sizeof(vec2_t);
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
TQ_BATCH_IMPL(Vec2)
@end
