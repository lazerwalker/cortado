#import <Mantle/Mantle.h>

@class Drink;

@interface PreferredDrinks : MTLModel

@property (readonly, nonatomic, strong) Drink *drink;

- (id)initWithDrink:(Drink *)drink;

@end
