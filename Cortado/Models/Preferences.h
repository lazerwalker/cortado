#import <Mantle/Mantle.h>

@class Drink;

@interface Preferences : MTLModel

@property (readonly, nonatomic, strong) Drink *drink;

- (id)initWithDrink:(Drink *)drink;

@end
