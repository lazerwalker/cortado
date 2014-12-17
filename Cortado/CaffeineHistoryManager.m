#import <Asterism/Asterism.h>
@import HealthKit;

#import "Drink.h"
#import "DrinkConsumption.h"

#import "CaffeineHistoryManager.h"

@interface CaffeineHistoryManager ()

@property (nonatomic, strong) HKHealthStore *healthStore;
@property (nonatomic, strong) HKQuantityType *caffeineType;
@end

@implementation CaffeineHistoryManager

- (id)init {
    self = [super init];
    if (!self) return nil;

    if ([HKHealthStore isHealthDataAvailable]) {
        self.healthStore = [[HKHealthStore alloc] init];
        self.caffeineType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCaffeine];

        if ([self.healthStore authorizationStatusForType:self.caffeineType] == HKAuthorizationStatusNotDetermined) {
            NSSet *set = [NSSet setWithObject:self.caffeineType];
            [self.healthStore requestAuthorizationToShareTypes:set readTypes:set completion:^(BOOL success, NSError *error) {

            }];
        }
    }

    return self;
}

- (void)processDrinks:(NSArray *)array {
    if (!(self.healthStore && [self.healthStore authorizationStatusForType:self.caffeineType] == HKAuthorizationStatusSharingAuthorized)) {
        return;
    }

    array = ASTFilter(array, ^BOOL(DrinkConsumption *drink) {
        return [drink isKindOfClass:DrinkConsumption.class];
    });
    array = ASTMap(array, ^id(DrinkConsumption *drink) {
        return [self sampleFromDrink:drink];
    });

    [self.healthStore saveObjects:array withCompletion:^(BOOL success, NSError *error) {
        NSLog(@"================> %@", @(success));
    }];

}

- (void)processDrink:(DrinkConsumption *)drink
         withCompletion:(void(^)(BOOL success, NSError *error))completion {
    HKQuantitySample *sample = [self sampleFromDrink:drink];
    [self.healthStore saveObject:sample withCompletion:completion];
}

#pragma mark -
- (HKQuantitySample *)sampleFromDrink:(DrinkConsumption *)drink {
    HKUnit *unit = [HKUnit unitFromString:@"mg"];
    HKQuantity *quantity = [HKQuantity quantityWithUnit:unit doubleValue:drink.caffeine.doubleValue];
    HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCaffeine];
    return [HKQuantitySample quantitySampleWithType:type
                                           quantity:quantity
                                          startDate:drink.timestamp
                                            endDate:drink.timestamp
                                           metadata:@{@"name": drink.name}];
}

@end
