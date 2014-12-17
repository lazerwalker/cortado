#import <ReactiveViewModel/ReactiveViewModel.h>

@class Beverage;
@class PreferredDrinks;

@interface PreferredDrinksViewModel : RVMViewModel

@property (readonly, nonatomic, strong) PreferredDrinks *drinks;
@property (readonly) NSUInteger numberOfDrinks;

- (Beverage *)drinkAtIndex:(NSUInteger)index;

- (NSString *)titleAtIndex:(NSUInteger)index;
- (NSString *)subtitleAtIndex:(NSUInteger)index;

- (void)setDrink:(Beverage *)drink forIndex:(NSUInteger)index;

@end
