#import "Preferences.h"

@implementation Preferences

- (id)initWithDrink:(Drink *)drink {
    self = [super init];
    if (!self) return nil;

    _drink = drink;

    return self;
}

@end
