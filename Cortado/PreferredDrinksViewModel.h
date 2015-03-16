#import <ReactiveViewModel/ReactiveViewModel.h>

@class Drink;
@class DrinkCellViewModel;
@class PreferredDrinks;

@interface PreferredDrinksViewModel : RVMViewModel

@property (readonly, nonatomic, strong) PreferredDrinks *drinks;
@property (readonly) NSUInteger numberOfDrinks;

- (void)registerNotificationType;

- (Drink *)drinkAtIndex:(NSUInteger)index;
- (DrinkCellViewModel *)drinkViewModelAtIndex:(NSUInteger)index;

- (void)setDrink:(Drink *)drink;

@end
