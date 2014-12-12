#import "Beverage.h"

@implementation Beverage

- (id)initWithName:(NSString *)name caffeine:(NSNumber *)caffeine {
    self = [super init];
    if (!self) return nil;

    _name = name;
    _caffeine = caffeine;

    return self;
}

@end
