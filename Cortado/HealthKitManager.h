@import Foundation;

@class DrinkConsumption;
@class RACSignal;

@interface HealthKitManager : NSObject

@property (readonly) BOOL isAuthorized;

- (RACSignal *)processDrink:(DrinkConsumption *)drink;
- (RACSignal *)deleteDrink:(DrinkConsumption *)drink;

- (RACSignal *)editDrink:(DrinkConsumption *)from
                 toDrink:(DrinkConsumption *)to;

- (void)processDrinkImmediately:(DrinkConsumption *)drink;

- (RACSignal *)fetchHistory;

@end
