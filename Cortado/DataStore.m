#import <ReactiveCocoa/ReactiveCocoa.h>

#import "HealthKitManager.h"

#import "DataStore.h"

@implementation DataStore

- (id)initWithHealthKitManager:(HealthKitManager *)healthKitManager {
    self = [super init];
    if (!self) return nil;

    _healthKitManager = healthKitManager;

    return self;
}

- (RACSignal *)addDrink:(DrinkConsumption *)drink {
    return [self.healthKitManager addDrink:drink];
}

- (RACSignal *)deleteDrink:(DrinkConsumption *)drink {
    return [self.healthKitManager deleteDrink:drink];
}

- (RACSignal *)editDrink:(DrinkConsumption *)from toDrink:(DrinkConsumption *)to {
    return [self.healthKitManager editDrink:from toDrink:to];
}

- (void)addDrinkImmediately:(DrinkConsumption *)drink {
    [self.healthKitManager addDrinkImmediately:drink];
}

- (RACSignal *)fetchHistory {
    return [self.healthKitManager fetchHistory];
}

@end
