#import <Mantle/Mantle.h>

@class Drink;

@interface PreferredDrinks : MTLModel

@property (readonly, nonatomic, strong) Drink *first;
@property (readonly, nonatomic, strong) Drink *second;

- (id)initWithFirst:(Drink *)first
             second:(Drink *)second;

- (id)preferenceByReplacingDrinkAtIndex:(NSUInteger)index
                              withDrink:(Drink *)drink;

@end
