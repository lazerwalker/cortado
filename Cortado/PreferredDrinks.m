#import "PreferredDrinks.h"

@implementation PreferredDrinks

- (id)initWithDrink:(Drink *)drink {
    self = [super init];
    if (!self) return nil;

    _drink = drink;

    return self;
}

@end
