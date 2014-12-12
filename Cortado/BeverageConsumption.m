#import "Beverage.h"

#import "BeverageConsumption.h"

@implementation BeverageConsumption

- (id)initWithBeverage:(Beverage *)beverage
             timestamp:(NSDate *)timestamp {
    self = [super init];
    if (!self) return nil;

    _name = beverage.name;
    _caffeine = beverage.caffeine;
    _timestamp = timestamp;

    return self;
}

- (id)initWithBeverage:(Beverage *)beverage {
    return [self initWithBeverage:beverage
                        timestamp:NSDate.date];
}

@end
