#import <Mantle/Mantle.h>

@class Beverage;

@interface PreferredDrinks : MTLModel

@property (readonly, nonatomic, strong) Beverage *first;
@property (readonly, nonatomic, strong) Beverage *second;

- (id)initWithFirst:(Beverage *)first
             second:(Beverage *)second;

- (id)preferenceByReplacingDrinkAtIndex:(NSUInteger)index
                              withDrink:(Beverage *)drink;

@end
