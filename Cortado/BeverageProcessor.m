#import <Asterism/Asterism.h>
@import HealthKit;

#import "Beverage.h"
#import "BeverageConsumption.h"

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

    array = ASTFilter(array, ^BOOL(BeverageConsumption *drink) {
        return [drink isKindOfClass:BeverageConsumption.class];
    });
    array = ASTMap(array, ^id(BeverageConsumption *drink) {
        return [self sampleFromBeverage:drink];
    });

    [self.healthStore saveObjects:array withCompletion:^(BOOL success, NSError *error) {
        NSLog(@"================> %@", @(success));
    }];

}

- (void)processBeverage:(BeverageConsumption *)beverage
         withCompletion:(void(^)(BOOL success, NSError *error))completion {
    HKQuantitySample *sample = [self sampleFromBeverage:beverage];
    [self.healthStore saveObject:sample withCompletion:completion];
}

#pragma mark -
- (HKQuantitySample *)sampleFromBeverage:(BeverageConsumption *)beverage {
    HKUnit *unit = [HKUnit unitFromString:@"mg"];
    HKQuantity *quantity = [HKQuantity quantityWithUnit:unit doubleValue:beverage.caffeine.doubleValue];
    HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCaffeine];
    return [HKQuantitySample quantitySampleWithType:type
                                           quantity:quantity
                                          startDate:beverage.timestamp
                                            endDate:beverage.timestamp
                                           metadata:@{@"name": beverage.name}];
}

@end
