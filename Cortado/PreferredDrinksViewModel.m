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
        [[PreferredDrinks alloc] initWithFirst:nil second:nil];

    [RACObserve(self, drinks) subscribeNext:^(id x) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.drinks];
        [NSUserDefaults.standardUserDefaults setObject:data forKey:PreferencesKey];

        [CoffeeShopNotification registerNotificationTypeWithPreferences:self.drinks];
    }];

    return self;
}

- (NSUInteger)numberOfDrinks {
    return 2;
}

- (Drink *)drinkAtIndex:(NSUInteger)index {
    if (index == 0) {
        return self.drinks.first;
    } else if (index == 1) {
        return self.drinks.second;
    } else {
        return nil;
    }
}

- (DrinkCellViewModel *)drinkViewModelAtIndex:(NSUInteger)index {
    Drink *drink = [self drinkAtIndex:index];
    return [[DrinkCellViewModel alloc] initWithDrink:drink];
}

#pragma mark -
- (void)setDrink:(Drink *)drink forIndex:(NSUInteger)index {
    self.drinks = [self.drinks preferenceByReplacingDrinkAtIndex:index withDrink:drink];
}

@end
