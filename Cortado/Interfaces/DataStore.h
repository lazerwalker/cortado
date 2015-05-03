@import Foundation;

@class HealthKitManager;
@class DrinkConsumption;
@class FoursquareVenue;
@class RACSignal;

@interface DataStore : NSObject

+ (void)eraseStoredData;

- (id)initWithHealthKitManager:(HealthKitManager *)healthKitManager NS_DESIGNATED_INITIALIZER;

@property (readonly, nonatomic, strong) NSArray *drinks;
@property (readonly, nonatomic, strong) NSOrderedSet *venueHistory;

@property (readonly, nonatomic, strong) HealthKitManager *healthKitManager;

- (RACSignal *)importFromHealthKit;

- (RACSignal *)addDrink:(DrinkConsumption *)drink;
- (RACSignal *)deleteDrink:(DrinkConsumption *)drink;

- (RACSignal *)editDrink:(DrinkConsumption *)from
                 toDrink:(DrinkConsumption *)to;

- (void)addVenue:(FoursquareVenue *)venue;

// This calls `addDrink:` and subscribes to the signal.
// TODO: There has to be a better naming convention for this.
- (void)addDrinkImmediately:(DrinkConsumption *)drink;

@end
