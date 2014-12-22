@import Foundation;
@import HealthKit;

@class DrinkConsumption;

@interface DrinkConsumptionSerializer : NSObject

+ (DrinkConsumption *)drinkFromQuantitySample:(HKQuantitySample *)sample;

@end
