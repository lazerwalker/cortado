#import <ReactiveCocoa/ReactiveCocoa.h>

#import "Drink.h"
#import "DrinkCellViewModel.h"
#import "CoffeeShopNotification.h"
#import "PreferredDrinks.h"

#import "PreferredDrinksViewModel.h"

static NSString * const PreferencesKey = @"preferredDrinks";

@interface PreferredDrinksViewModel ()
@property (readwrite, nonatomic, strong) PreferredDrinks *drinks;
@end

@implementation PreferredDrinksViewModel

- (id)init {
    self = [super init];
    if (!self) return nil;

    NSData *data = [NSUserDefaults.standardUserDefaults objectForKey:PreferencesKey];
    self.drinks = [NSKeyedUnarchiver unarchiveObjectWithData:data] ?:
    [[PreferredDrinks alloc] initWithDrink:nil];

    [RACObserve(self, drinks) subscribeNext:^(id x) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.drinks];
        [NSUserDefaults.standardUserDefaults setObject:data forKey:PreferencesKey];

        [CoffeeShopNotification registerNotificationTypeWithPreferences:self.drinks];
    }];

    return self;
}

- (NSUInteger)numberOfDrinks {
    return 1;
}

- (Drink *)drinkAtIndex:(NSUInteger)index {
    return self.drinks.drink;
}

- (DrinkCellViewModel *)drinkViewModelAtIndex:(NSUInteger)index {
    Drink *drink = [self drinkAtIndex:index];
    return [[DrinkCellViewModel alloc] initWithDrink:drink];
}

#pragma mark -
- (void)setDrink:(Drink *)drink {
    self.drinks = [[PreferredDrinks alloc] initWithDrink:drink];
}

@end
