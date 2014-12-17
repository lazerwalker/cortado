#import "Drink.h"

#import "DrinkConsumption.h"

@implementation DrinkConsumption

- (id)initWithDrink:(Drink *)drink
             timestamp:(NSDate *)timestamp {
    self = [super init];
    if (!self) return nil;

    _name = drink.name;
    _caffeine = drink.caffeine;
    _timestamp = timestamp;

    return self;
}

- (id)initWithDrink:(Drink *)drink {
    return [self initWithDrink:drink
                        timestamp:NSDate.date];
}

@end
