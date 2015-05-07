#import <ReactiveViewModel/ReactiveViewModel.h>

@class Drink;
@class DrinkCellViewModel;
@class Preferences;

@interface PreferencesViewModel : RVMViewModel

@property (readonly, nonatomic, strong) Preferences *preferences;
@property (readonly) NSUInteger numberOfDrinks;

@property (readwrite, nonatomic, assign) BOOL shouldRegisterNotificationTypeAutomatically;

- (void)registerNotificationType;

- (Drink *)drinkAtIndex:(NSUInteger)index;
- (DrinkCellViewModel *)drinkViewModelAtIndex:(NSUInteger)index;

- (void)addDrink:(Drink *)drink;
- (void)removeDrink:(Drink *)drink;
- (void)moveDrink:(Drink *)drink toIndex:(NSUInteger)index;
- (void)editDrinkAtIndex:(NSUInteger)index toDrink:(Drink *)drink;

@end
