@import HealthKit;

#import <Asterism/Asterism.h>
#import <Mantle/Mantle.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "Drink.h"
#import "DrinkConsumption.h"

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
    return [[[[RACObserve(self, isAuthorized) startWith:@(self.isAuthorized)]
        ignore:@NO]
        take:1]
        flattenMap:^RACStream *(id value) {
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:self.caffeineType
                                                                       predicate:nil
                                                                           limit:HKObjectQueryNoLimit
                                                                 sortDescriptors:nil
                                                                  resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {

                    NSArray *parsedResults = ASTMap(results, ^id(HKQuantitySample *result) {
                        NSString *name = result.metadata[@"Name"] ?: result.metadata[HKMetadataKeyFoodType] ?: @"Unknown Beverage";
                        NSString *subtype = result.metadata[@"Subtype"];
                        NSNumber *caffeine = @([result.quantity doubleValueForUnit:self.mgUnit]);
                        NSString *venue = result.metadata[@"Venue"];
                        NSString *coordinate = result.metadata[@"Coordinate"];

                        Drink *drink = [[Drink alloc] initWithName:name subtype:subtype caffeine:caffeine];
                        return [[DrinkConsumption alloc] initWithDrink:drink
                                                             timestamp:result.startDate
                                                                 venue:venue
                                                            coordinate:coordinate];
                    });

                    for (id result in parsedResults) {
                      [subscriber sendNext:result];
                    }

                    [subscriber sendCompleted];
                }];
                [self.healthStore executeQuery:query];

                return (RACDisposable *)nil;
            }];
    }];
    return nil;
}


@end
