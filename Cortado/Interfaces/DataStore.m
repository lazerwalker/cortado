#import <Asterism/Asterism.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>

#import "HealthKitManager.h"

#import "DataStore.h"

static NSString * const HistoryKey = @"History";

@interface DataStore ()
@property (readwrite, nonatomic, strong) NSArray *drinks;
@end

@implementation DataStore

- (id)initWithHealthKitManager:(HealthKitManager *)healthKitManager {
    self = [super init];
    if (!self) return nil;

    _healthKitManager = healthKitManager;
    self.drinks = self.cachedDrinks ?: [[NSArray alloc] init];

    [RACObserve(self, drinks) subscribeNext:^(NSArray *drinks) {
        [self persistDrinks:drinks];
    }];

    return self;
}

- (RACSignal *)importFromHealthKit {
    return [[[self.healthKitManager fetchHistory]
        collect]
        doNext:^(id drinks) {
            self.drinks = drinks;
        }];
}

#pragma mark -

- (RACSignal *)addDrink:(DrinkConsumption *)drink {
    self.drinks = [self.drinks arrayByAddingObject:drink];
    return [self.healthKitManager addDrink:drink];
}

- (RACSignal *)deleteDrink:(DrinkConsumption *)drink {
    self.drinks = ASTWithout(self.drinks, drink);
    return [self.healthKitManager deleteDrink:drink];
}

- (RACSignal *)editDrink:(DrinkConsumption *)from toDrink:(DrinkConsumption *)to {
    NSUInteger index = [self.drinks indexOfObject:from];
    NSMutableArray *mutableDrinks = self.drinks.mutableCopy;
    [mutableDrinks replaceObjectAtIndex:index withObject:to];
    self.drinks = mutableDrinks.copy;

    return [self.healthKitManager editDrink:from toDrink:to];
}

- (void)addDrinkImmediately:(DrinkConsumption *)drink {
    [[self addDrink:drink] subscribeNext:^(id x) {}];
}

#pragma mark - Persistence
- (void)persistDrinks:(NSArray *)drinks {
    if (!self.drinks) { return; }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:drinks];
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    [defaults setObject:data forKey:HistoryKey];
    [defaults synchronize];
}

- (NSArray *)cachedDrinks {
    NSData *data = [NSUserDefaults.standardUserDefaults objectForKey:HistoryKey];
    if (!data) return nil;

    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

@end
