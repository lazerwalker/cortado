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

- (RACSignal *)processDrink:(DrinkConsumption *)drink {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        HKQuantitySample *sample = [self createSampleFromDrink:drink];
        [self.healthStore saveObject:sample withCompletion:^(BOOL success, NSError *error) {
            if (success) {
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:error];
            }
        }];
        return (RACDisposable *)nil;
    }];
}

- (RACSignal *)deleteDrink:(DrinkConsumption *)drink {
    return [[self fetchSampleFromDrink:drink]
        flattenMap:^RACStream *(HKQuantitySample *sample) {
            return [self.healthStore rac_deleteObject:sample];
        }];
}

- (RACSignal *)fetchHistory {
    return [[[[[RACObserve(self, isAuthorized) startWith:@(self.isAuthorized)]
               ignore:@NO]
              take:1]
             flattenMap:^(id _) {
                 return [self.healthStore rac_queryWithSampleType:self.caffeineType
                                                        predicate:nil
                                                            limit:HKObjectQueryNoLimit
                                                  sortDescriptors:nil];
             }]
            map:^(HKQuantitySample *result) {
                return [DrinkConsumptionSerializer consumptionFromQuantitySample:result];
            }];
}

#pragma mark -
- (RACSignal *)fetchSampleFromDrink:(DrinkConsumption *)drink {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"startDate == %@", drink.timestamp];
    return [self.healthStore rac_queryWithSampleType:self.caffeineType
                                           predicate:predicate
                                               limit:HKObjectQueryNoLimit
                                     sortDescriptors:nil];

}

- (HKQuantitySample *)createSampleFromDrink:(DrinkConsumption *)drink {
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

@end
