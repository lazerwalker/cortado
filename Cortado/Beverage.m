#import "Beverage.h"

@implementation Beverage

- (id)initWithName:(NSString *)name
           subtype:(NSString *)subtype
          caffeine:(NSNumber *)caffeine {
    self = [super init];
    if (!self) return nil;

    _name = name;
    _subtype = subtype;
    _caffeine = caffeine;

    return self;
}

- (id)initWithName:(NSString *)name caffeine:(NSNumber *)caffeine {
    return [self initWithName:name subtype:nil caffeine:caffeine];
}

@end
