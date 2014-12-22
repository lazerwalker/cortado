#import "Drink.h"
#import "DrinkConsumption.h"

#import "DrinkConsumptionSerializer.h"

@implementation DrinkConsumptionSerializer

+ (DrinkConsumption *)consumptionFromQuantitySample:(HKQuantitySample *)sample {
    NSString *name = sample.metadata[@"Name"] ?: sample.metadata[HKMetadataKeyFoodType] ?: @"Unknown Beverage";
    NSString *subtype = sample.metadata[@"Subtype"];

    HKUnit *mg = [HKUnit unitFromString:@"mg"];
    NSNumber *caffeine = @([sample.quantity doubleValueForUnit:mg]);

    NSString *venue = sample.metadata[@"Venue"];
    NSString *coordinate = sample.metadata[@"Coordinate"];

    Drink *drink = [[Drink alloc] initWithName:name subtype:subtype caffeine:caffeine];
    return [[DrinkConsumption alloc] initWithDrink:drink
                                         timestamp:sample.startDate
                                             venue:venue
                                        coordinate:coordinate];
}

+ (DrinkConsumption *)consumptionFromUserInfo:(NSDictionary *)userInfo
                                        drink:(Drink *)drink {
    NSDate *timestamp = userInfo[@"timestamp"];
    NSString *venue = userInfo[@"venue"];
    NSString *coordinate = userInfo[@"latLng"];

    return [[DrinkConsumption alloc] initWithDrink:drink
                                         timestamp:timestamp
                                             venue:venue
                                        coordinate:coordinate];
}
@end
