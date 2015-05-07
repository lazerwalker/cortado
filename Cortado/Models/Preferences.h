#import <Mantle/Mantle.h>

@class Drink;

@interface Preferences : MTLModel

@property (readonly, nonatomic, strong) NSArray *drinks;

- (id)initWithDrinks:(NSArray *)drinks;

- (instancetype)preferencesByAddingDrink:(Drink *)drink;
- (instancetype)preferencesByRemovingDrinkAtIndex:(NSUInteger)index;
- (instancetype)preferencesByMovingDrinkAtIndex:(NSUInteger)index1 toIndex:(NSUInteger)index2;
- (instancetype)preferencesByReplacingDrinkAtIndex:(NSUInteger)index withDrink:(Drink *)drink;

@end