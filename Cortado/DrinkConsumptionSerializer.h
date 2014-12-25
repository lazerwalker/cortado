@import Foundation;
@import HealthKit;

@class Drink;
@class DrinkConsumption;

@interface DrinkConsumptionSerializer : NSObject

+ (DrinkConsumption *)consumptionFromQuantitySample:(HKQuantitySample *)sample;

+ (DrinkConsumption *)consumptionFromUserInfo:(NSDictionary *)userInfo
                                   identifier:(NSString *)identifier;
@end
