#import "DrinkCellViewModel.h"

#import "Drink.h"

@implementation DrinkCellViewModel

- (id)initWithDrink:(Drink *)drink {
    self = [super init];
    if (!self) return nil;

    _drink = drink;

    return self;
}

- (NSString *)title {
    if (self.drink == nil) {
        return @"No drink selected";
    }

    return self.drink.name;
}

- (NSString *)subtitle {
    if (self.drink == nil) {
        return nil;
    }

    if (self.drink.subtype == nil) {
        return [NSString stringWithFormat:@"%@ mg", self.drink.caffeine];
    }

    return [NSString stringWithFormat:@"%@ (%@ mg)", self.drink.subtype, self.drink.caffeine];
}
@end
