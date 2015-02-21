@import Foundation;

@class DrinkConsumption;
@class RACSignal;

@interface HealthKitManager : NSObject

@property (readonly) BOOL isAuthorized;

- (RACSignal *)addDrink:(DrinkConsumption *)drink;
- (RACSignal *)deleteDrink:(DrinkConsumption *)drink;

- (RACSignal *)editDrink:(DrinkConsumption *)from
                 toDrink:(DrinkConsumption *)to;

- (RACSignal *)fetchHistory;

// This calls `addDrink:` and subscribes to the signal.
// TODO: There has to be a better naming convention for this.
- (void)addDrinkImmediately:(DrinkConsumption *)drink;

@end
