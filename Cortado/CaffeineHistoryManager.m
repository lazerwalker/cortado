@import HealthKit;

#import <Asterism/Asterism.h>
#import <Mantle/Mantle.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "HKHealthStore+ReactiveCocoa.h"

#import "Drink.h"
#import "DrinkConsumption.h"
#import "DrinkConsumptionSerializer.h"

#import "CaffeineHistoryManager.h"

@interface CaffeineHistoryManager ()

@property (nonatomic, strong) HKHealthStore *healthStore;
@property (nonatomic, strong) HKQuantityType *caffeineType;
@property (nonatomic, strong) HKUnit *mgUnit;

@property (readwrite, nonatomic, assign) BOOL isAuthorized;

@end

@implementation CaffeineHistoryManager

- (id)init {
    self = [super init];
    if (!self) return nil;

    self.isAuthorized = false;

    if ([HKHealthStore isHealthDataAvailable]) {
        self.healthStore = [[HKHealthStore alloc] init];
        self.caffeineType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCaffeine];
        self.mgUnit = [HKUnit unitFromString:@"mg"];

        HKAuthorizationStatus status = [self.healthStore authorizationStatusForType:self.caffeineType];
        if (status == HKAuthorizationStatusSharingAuthorized) {
            self.isAuthorized = YES;
        } else if (status == HKAuthorizationStatusNotDetermined) {
            NSSet *set = [NSSet setWithObject:self.caffeineType];
            [self.healthStore requestAuthorizationToShareTypes:set readTypes:set completion:^(BOOL success, NSError *error) {
                self.isAuthorized = success;
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
    HKQuantity *quantity = [HKQuantity quantityWithUnit:self.mgUnit doubleValue:drink.caffeine.doubleValue];
    HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCaffeine];

    NSString *name = drink.name;
    if (drink.subtype) {
        name = [NSString stringWithFormat:@"%@ (%@)", drink.name, drink.subtype];
    }
    
    NSDictionary *metadata = ASTExtend(@{
        HKMetadataKeyFoodType: name,
        HKMetadataKeyWasUserEntered: @YES
    },
    [MTLJSONAdapter JSONDictionaryFromModel:drink]);

    return [HKQuantitySample quantitySampleWithType:type
                                           quantity:quantity
                                          startDate:drink.timestamp
                                            endDate:drink.timestamp
                                           metadata:metadata];
}

- (RACSignal *)fetchHistory {
    return [[[[[RACObserve(self, isAuthorized) startWith:@(self.isAuthorized)]
        ignore:@NO]
        take:1]
        flattenMap:^RACStream *(id value) {
            return [self.healthStore rac_queryWithSampleType:self.caffeineType
                                                   predicate:nil
                                                       limit:HKObjectQueryNoLimit
                                             sortDescriptors:nil];
        }] map:^id(HKQuantitySample *result) {
            return [DrinkConsumptionSerializer consumptionFromQuantitySample:result];
        }];
}


@end
