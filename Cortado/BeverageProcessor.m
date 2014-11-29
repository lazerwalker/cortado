#import <Asterism/Asterism.h>
@import HealthKit;

#import "BeverageProcessor.h"

@interface BeverageProcessor ()

@property (nonatomic, strong) HKHealthStore *healthStore;
@property (nonatomic, strong) HKQuantityType *caffeineType;
@end

@implementation BeverageProcessor

- (id)init {
    self = [super init];
    if (!self) return nil;

    if ([HKHealthStore isHealthDataAvailable]) {
        self.healthStore = [[HKHealthStore alloc] init];
        self.caffeineType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCaffeine];
        if ([self.healthStore authorizationStatusForType:self.caffeineType] == HKAuthorizationStatusNotDetermined) {
            NSSet *set = [NSSet setWithObject:self.caffeineType];
            [self.healthStore requestAuthorizationToShareTypes:set readTypes:nil completion:^(BOOL success, NSError *error) {

            }];
        }
    }

    return self;
}

- (void)processBeverages:(NSArray *)array {
    if (!(self.healthStore && [self.healthStore authorizationStatusForType:self.caffeineType] == HKAuthorizationStatusSharingAuthorized)) {
        return;
    }

    array = ASTMap(array, ^id(NSArray *beverage) {
        NSString *name = beverage[0];
        NSNumber *caffeine = beverage[1];
        NSDate *timestamp = beverage[2];

        HKUnit *unit = [HKUnit unitFromString:@"mg"];
        HKQuantity *quantity = [HKQuantity quantityWithUnit:unit doubleValue:caffeine.doubleValue];
        HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCaffeine];
        return [HKQuantitySample quantitySampleWithType:type
                                                                   quantity:quantity
                                                                  startDate:timestamp
                                                                    endDate:timestamp
                                                                   metadata:@{@"name": name}];
    });
    [self.healthStore saveObjects:array withCompletion:^(BOOL success, NSError *error) {
        NSLog(@"================> %@", @(success));
    }];

}

@end
