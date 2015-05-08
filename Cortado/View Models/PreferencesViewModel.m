#import <ReactiveCocoa/ReactiveCocoa.h>

#import "Drink.h"
#import "DrinkCellViewModel.h"
#import "CoffeeShopNotification.h"
#import "Preferences.h"

#import "PreferencesViewModel.h"

static NSString * const PreferencesKey = @"preferredDrinks";

@interface PreferencesViewModel ()
@property (readwrite, nonatomic, strong) Preferences *preferences;
@property (readwrite, nonatomic, assign) BOOL canAddMore;
@end

@implementation PreferencesViewModel

- (id)init {
    self = [super init];
    if (!self) return nil;

    NSData *data = [NSUserDefaults.standardUserDefaults objectForKey:PreferencesKey];
    self.preferences = [NSKeyedUnarchiver unarchiveObjectWithData:data] ?: [[Preferences alloc] init];

    [RACObserve(self, preferences) subscribeNext:^(Preferences *drinks) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:drinks];
        [NSUserDefaults.standardUserDefaults setObject:data forKey:PreferencesKey];

        if (self.shouldRegisterNotificationTypeAutomatically) {
            [self registerNotificationType];
        }
    }];

    RAC(self, canAddMore) = [RACObserve(self, preferences.drinks) map:^id(NSArray *drinks) {
        return @(drinks.count < 3);
    }];

    return self;
}

+ (NSSet *)keyPathsForValuesAffectingNumberOfDrinks {
    return [NSSet setWithObject:@keypath(PreferencesViewModel.new, preferences.drinks)];
}

+ (NSSet *)keyPathsForValuesAffectingCanAddMore {
    return [NSSet setWithObject:@keypath(PreferencesViewModel.new, preferences)];
}

- (void)setShouldRegisterNotificationTypeAutomatically:(BOOL)shouldRegisterNotificationTypeAutomatically {
    _shouldRegisterNotificationTypeAutomatically = shouldRegisterNotificationTypeAutomatically;
    if (shouldRegisterNotificationTypeAutomatically) {
        [self registerNotificationType];
    }
}

- (void)registerNotificationType {
    [CoffeeShopNotification registerNotificationTypeWithPreferences:self.preferences];
}

- (NSUInteger)numberOfDrinks {
    return self.preferences.drinks.count;
}

- (Drink *)drinkAtIndex:(NSUInteger)index {
    if (index >= self.preferences.drinks.count) return nil;
    return self.preferences.drinks[index];
}

- (DrinkCellViewModel *)drinkViewModelAtIndex:(NSUInteger)index {
    Drink *drink = [self drinkAtIndex:index];
    return [[DrinkCellViewModel alloc] initWithDrink:drink];
}

#pragma mark -
- (void)addDrink:(Drink *)drink {
    self.preferences = [self.preferences preferencesByAddingDrink:drink];
}

- (void)removeDrinkAtIndex:(NSUInteger)index {
    self.preferences = [self.preferences preferencesByRemovingDrinkAtIndex:index];
}

- (void)moveDrinkAtIndex:(NSUInteger)index1 toIndex:(NSUInteger)index2 {
    self.preferences = [self.preferences preferencesByMovingDrinkAtIndex:index1 toIndex:index2];
}

- (void)replaceDrinkAtIndex:(NSUInteger)index withDrink:(Drink *)drink {
    self.preferences = [self.preferences preferencesByReplacingDrinkAtIndex:index withDrink:drink];
}

@end
