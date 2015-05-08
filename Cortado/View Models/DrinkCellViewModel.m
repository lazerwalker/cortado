#import "DrinkCellViewModel.h"

#import "Drink.h"

@implementation DrinkCellViewModel

- (id)initWithDrink:(Drink *)drink {
    self = [super init];
    if (!self) return nil;

    _drink = drink;
    _isPlaceholder = (drink == nil);

    return self;
}

- (NSString *)title {
    if (self.isPlaceholder) {
        return @"Tap the '+' button to add a preference.";
    }

    return self.drink.name;
}

- (NSString *)subtitle {
    if (self.isPlaceholder) {
        return nil;
    }

    if (self.drink.subtype == nil) {
        return [NSString stringWithFormat:@"%@ mg", self.drink.caffeine];
    }

    return [NSString stringWithFormat:@"%@ (%@ mg)", self.drink.subtype, self.drink.caffeine];
}
@end
