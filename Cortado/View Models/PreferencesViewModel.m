#import <ReactiveCocoa/ReactiveCocoa.h>

#import "Drink.h"
#import "DrinkCellViewModel.h"
#import "CoffeeShopNotification.h"
#import "Preferences.h"

#import "PreferencesViewModel.h"

static NSString * const PreferencesKey = @"preferredDrinks";

@interface PreferencesViewModel ()
@property (readwrite, nonatomic, strong) Preferences *drinks;
@end

@implementation PreferencesViewModel

- (id)init {
    self = [super init];
    if (!self) return nil;

    NSData *data = [NSUserDefaults.standardUserDefaults objectForKey:PreferencesKey];
    self.drinks = [NSKeyedUnarchiver unarchiveObjectWithData:data] ?:
    [[Preferences alloc] init];

    [RACObserve(self, drinks) subscribeNext:^(Preferences *drinks) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:drinks];
        [NSUserDefaults.standardUserDefaults setObject:data forKey:PreferencesKey];

        if (self.shouldRegisterNotificationTypeAutomatically) {
            [self registerNotificationType];
        }
    }];

    return self;
}

- (void)setShouldRegisterNotificationTypeAutomatically:(BOOL)shouldRegisterNotificationTypeAutomatically {
    _shouldRegisterNotificationTypeAutomatically = shouldRegisterNotificationTypeAutomatically;
    if (shouldRegisterNotificationTypeAutomatically) {
        [self registerNotificationType];
    }
}

- (void)registerNotificationType {
    [CoffeeShopNotification registerNotificationTypeWithPreferences:self.drinks];
}

- (NSUInteger)numberOfDrinks {
    return self.drinks.drinks.count;
}

- (Drink *)drinkAtIndex:(NSUInteger)index {
    return self.drinks.drinks[index];
}

- (DrinkCellViewModel *)drinkViewModelAtIndex:(NSUInteger)index {
    Drink *drink = [self drinkAtIndex:index];
    return [[DrinkCellViewModel alloc] initWithDrink:drink];
}

#pragma mark -
- (void)setDrink:(Drink *)drink {
    self.drinks = [[Preferences alloc] initWithDrinks:@[drink]];
}

@end
