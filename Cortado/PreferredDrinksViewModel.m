#import "Beverage.h"

#import "PreferredDrinksViewModel.h"

@interface PreferredDrinksViewModel ()
@property (readwrite, nonatomic, strong) NSArray *drinks;
@end

@implementation PreferredDrinksViewModel

- (id)init {
    self = [super init];
    if (!self) return nil;

    _drinks = @[NSNull.null, NSNull.null];

    return self;
}

- (NSUInteger)numberOfDrinks {
    return 2;
}

- (Beverage *)drinkAtIndex:(NSUInteger)index {
    if (self.drinks.count <= index) {
        return nil;
    }
    
    Beverage *drink = self.drinks[index];
    if (drink == (Beverage *)NSNull.null) {
        return nil;
    }

    return drink;
}

- (NSString *)titleAtIndex:(NSUInteger)index {
    Beverage *drink = [self drinkAtIndex:index];
    if (drink == nil) {
        return @"No drink selected";
    }

    if (drink.subtype == nil) {
        return drink.name;
    } else {
        return [NSString stringWithFormat:@"%@ (%@)", drink.name, drink.subtype];
    }

}
- (void)setDrink:(Beverage *)drink forIndex:(NSUInteger)index {
    if (index >= self.numberOfDrinks) return;

    NSMutableArray *newDrinks = self.drinks.mutableCopy;
    newDrinks[index] = drink;
    self.drinks = newDrinks.copy;
}

@end
