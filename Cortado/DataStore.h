@import Foundation;

@class HealthKitManager;
@class DrinkConsumption;
@class RACSignal;

@interface DataStore : NSObject

- (id)initWithHealthKitManager:(HealthKitManager *)healthKitManager NS_DESIGNATED_INITIALIZER;

@property (readwrite, nonatomic, strong) HealthKitManager *healthKitManager;

- (RACSignal *)addDrink:(DrinkConsumption *)drink;
- (RACSignal *)deleteDrink:(DrinkConsumption *)drink;

- (RACSignal *)editDrink:(DrinkConsumption *)from
                 toDrink:(DrinkConsumption *)to;

- (RACSignal *)fetchHistory;

// This calls `addDrink:` and subscribes to the signal.
// TODO: There has to be a better naming convention for this.
- (void)addDrinkImmediately:(DrinkConsumption *)drink;

@end
