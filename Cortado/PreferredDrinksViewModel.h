#import <ReactiveViewModel/ReactiveViewModel.h>

@class Drink;
@class PreferredDrinks;

@interface PreferredDrinksViewModel : RVMViewModel

@property (readonly, nonatomic, strong) PreferredDrinks *drinks;
@property (readonly) NSUInteger numberOfDrinks;

- (Drink *)drinkAtIndex:(NSUInteger)index;

- (NSString *)titleAtIndex:(NSUInteger)index;
- (NSString *)subtitleAtIndex:(NSUInteger)index;

- (void)setDrink:(Drink *)drink forIndex:(NSUInteger)index;

@end
