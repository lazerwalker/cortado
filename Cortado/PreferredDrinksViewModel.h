#import <ReactiveViewModel/ReactiveViewModel.h>

@class Beverage;

@interface PreferredDrinksViewModel : RVMViewModel

@property (readonly, nonatomic, strong) NSArray *drinks;
@property (readonly) NSUInteger numberOfDrinks;

- (Beverage *)drinkAtIndex:(NSUInteger)index;
- (NSString *)titleAtIndex:(NSUInteger)index;
- (void)setDrink:(Beverage *)drink forIndex:(NSUInteger)index;

@end
