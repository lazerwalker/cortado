#import <ReactiveViewModel/ReactiveViewModel.h>

@class Drink;
@class DrinkCellViewModel;
@class Preferences;

@interface PreferencesViewModel : RVMViewModel

@property (readonly, nonatomic, strong) Preferences *drinks;
@property (readonly) NSUInteger numberOfDrinks;

@property (readwrite, nonatomic, assign) BOOL shouldRegisterNotificationTypeAutomatically;

- (void)registerNotificationType;

- (Drink *)drinkAtIndex:(NSUInteger)index;
- (DrinkCellViewModel *)drinkViewModelAtIndex:(NSUInteger)index;

- (void)addDrink:(Drink *)drink;

@end
