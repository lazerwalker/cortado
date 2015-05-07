#import <Mantle/Mantle.h>

@class Drink;

@interface Preferences : MTLModel

@property (readonly, nonatomic, strong) NSArray *drinks;

- (id)initWithDrinks:(NSArray *)drinks;


@end