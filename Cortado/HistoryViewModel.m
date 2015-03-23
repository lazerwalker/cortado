@import CoreLocation;

#import <Asterism/Asterism.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>

#import "AddConsumptionViewModel.h"
#import "DataStore.h"
#import "DrinkConsumption.h"
#import "FTUEViewController.h"
#import "HealthKitManager.h"
#import "HistoryCellViewModel.h"
#import "LocationFetcher.h"

#import "HistoryViewModel.h"

@interface HistoryViewModel ()
@property (readwrite, nonatomic, strong) NSArray *drinks;
@property (readwrite, nonatomic, strong) NSDictionary *clusteredDrinks;
@property (readwrite, nonatomic, strong) NSArray *sortedDateKeys;
@property (readonly, nonatomic, strong) NSDateFormatter *headerDateFormatter;

@end

@implementation HistoryViewModel

- (id)initWithDataStore:(DataStore *)dataStore
        locationFetcher:(LocationFetcher *)locationFetcher {
    self = [super init];
    if (!self) return nil;

    _dataStore = dataStore;
    _locationFetcher = locationFetcher;

    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
    RAC(self, drinks) = [RACObserve(self, dataStore.drinks) map:^id(NSArray *drinks) {
        return [drinks sortedArrayUsingDescriptors:@[sortDescriptor]];
    }];

    RAC(self, clusteredDrinks) = [RACObserve(self, drinks)
        map:^id(NSArray *drinks) {
            NSCalendar *calendar = [NSCalendar currentCalendar];
            return ASTGroupBy(drinks, ^id<NSCopying>(DrinkConsumption *drink) {
                return [calendar startOfDayForDate:drink.timestamp];
            });
        }];

    RAC(self, sortedDateKeys) = [RACObserve(self, clusteredDrinks) map:^id(NSDictionary *dict) {
        return [dict.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSDate *date1, NSDate *date2) {
            return [date1 compare:date2];
        }].reverseObjectEnumerator.allObjects;
    }];

    RAC(self, isEmptyState) = [RACObserve(self, drinks)
        map:^id(NSArray *drinks) {
            return @(drinks.count == 0);
        }];

    _headerDateFormatter = [[NSDateFormatter alloc] init];
    _headerDateFormatter.dateFormat = @"EEEE, MMMM d";

    return self;
}

#pragma mark - KVO
+ (NSSet *)keyPathsForValuesAffectingNumberOfSections {
    return [NSSet setWithObject:@keypath(HistoryViewModel.new, drinks)];
}

+ (NSSet *)keyPathsForValuesAffectingIsEmptyState {
    return [NSSet setWithObject:@keypath(HistoryViewModel.new, drinks)];
}


#pragma mark -
- (NSArray *)drinksForDateAtIndex:(NSInteger)index {
    if (index >= self.sortedDateKeys.count) return nil;
    
    id key = self.sortedDateKeys[index];
    return self.clusteredDrinks[key];
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    if (self.isEmptyState) return 1;
    return [[self drinksForDateAtIndex:section] count];
}

- (NSInteger)numberOfSections {
    if (self.isEmptyState) return 1;

    return self.sortedDateKeys.count;
}

- (NSString *)dateStringForSection:(NSInteger)section {
    if (self.isEmptyState) return nil;

    NSDate *date = self.sortedDateKeys[section];
    NSString *dateString = [self.headerDateFormatter stringFromDate:date];

    NSNumber *caffeine = ASTReduce([self drinksForDateAtIndex:section], @0, ^id(NSNumber *count, DrinkConsumption *drink) {
        return @(count.integerValue + drink.caffeine.integerValue);
    });
    return [NSString stringWithFormat:@"%@ · %@ mg", dateString, caffeine];
}

- (DrinkConsumption *)drinkAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *drinks = [self drinksForDateAtIndex:indexPath.section];
    if (!drinks) return nil;
    if (indexPath.row >= drinks.count) return nil;

    return drinks[indexPath.row];
}


- (AddConsumptionViewModel *)addConsumptionViewModelWithPreferredDrink:(Drink *)drink {
    CLLocation *location = self.locationFetcher.currentLocation;
    AddConsumptionViewModel *vm = [[AddConsumptionViewModel alloc] initWithPreferredDrink:drink
                                                                                 location:location];
    return vm;
}

- (AddConsumptionViewModel *)editViewModelAtIndexPath:(NSIndexPath *)indexPath {
    DrinkConsumption *drink = [self drinkAtIndexPath:indexPath];
    return [[AddConsumptionViewModel alloc] initWithConsumption:drink editing:YES];
}

- (HistoryCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath {
    DrinkConsumption *drink = [self drinkAtIndexPath:indexPath];
    return [[HistoryCellViewModel alloc] initWithConsumption:drink];
}

#pragma mark - Actions
- (RACSignal *)deleteAtIndexPath:(NSIndexPath *)indexPath {
    DrinkConsumption *drink = [self drinkAtIndexPath:indexPath];
    return [self.dataStore deleteDrink:drink];
}

- (RACSignal *)editDrinkAtIndexPath:(NSIndexPath *)indexPath to:(DrinkConsumption *)to {
    DrinkConsumption *from = [self drinkAtIndexPath:indexPath];
    return [self.dataStore editDrink:from toDrink:to];
}

- (RACSignal *)addDrink:(DrinkConsumption *)drink {
    return [self.dataStore addDrink:drink];
}

#pragma mark - FTUE
- (BOOL)shouldPromptForLocation {
    // TODO: Abstract CLLocationManager away in LocationFetcher
    return [FTUEViewController hasBeenSeen] &&
        CLLocationManager.authorizationStatus != kCLAuthorizationStatusAuthorizedAlways;
}

- (void)authorizeLocation {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    [UIApplication.sharedApplication openURL:url];
}

- (BOOL)shouldPromptForHealthKit {
    // TODO: Law of Demeter!
    return [FTUEViewController hasBeenSeen] &&
        !self.dataStore.healthKitManager.isAuthorized;
}

#pragma mark -
- (RACSignal *)dataChanged {
    RACSignal *sectionChanges = [[[RACObserve(self, sortedDateKeys)
        combinePreviousWithStart:nil reduce:^id(NSArray *previous, NSArray *current) {
            if (previous == nil
                || previous.count == current.count
                || previous.count == 0
                || current.count == 0) {
                    return nil;
            }

            TableViewChange change;
            NSInteger index;

            if (previous.count > current.count) {
                change = TableViewChangeSectionDeletion;
                NSString *key = [ASTDifference(previous, current) firstObject];
                index = [previous indexOfObject:key];
            } else if (previous.count < current.count) {
                change = TableViewChangeSectionInsertion;
                NSString *key = [ASTDifference(current, previous) firstObject];
                index = [current indexOfObject:key];
            }

            return [RACTuple tupleWithObjects:@(change), @(index), nil];
        }]
        ignore: nil]
        map:^id(RACTuple *tuple) {
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:[tuple.second integerValue]];
            return [RACTuple tupleWithObjects:tuple.first, indexSet, nil];
        }];

    NSArray *(^sortedKeys)(NSArray *) = ^NSArray *(NSArray *keys) {
        return [keys sortedArrayUsingComparator:^NSComparisonResult(NSDate *date1, NSDate *date2) {
            return [date1 compare:date2];
        }].reverseObjectEnumerator.allObjects;
    };

    RACSignal *rowChanges = [[[RACObserve(self, clusteredDrinks)
        sample:RACObserve(self, sortedDateKeys)]
        combinePreviousWithStart:nil reduce:^id(NSDictionary *previous, NSDictionary *current) {
            if (previous == nil) return nil;

            NSArray *keys = ASTIntersection(previous.allKeys, current.allKeys);
            id changedKey = ASTFind(keys, ^BOOL(id key) {
                return ![previous[key] isEqualToArray:current[key]];
            });
            if (changedKey == nil) return nil;

            NSArray *previousArray = previous[changedKey];
            NSArray *currentArray = current[changedKey];

            TableViewChange change;
            NSIndexPath *indexPath;

            if (previousArray.count > currentArray.count) {
                Drink *drink = [ASTDifference(previousArray, currentArray) firstObject];
                NSInteger index = [previousArray indexOfObject:drink];
                NSInteger section = [sortedKeys(previous.allKeys) indexOfObject:changedKey];

                indexPath = [NSIndexPath indexPathForRow:index inSection:section];
                change = TableViewChangeRowDeletion;
            } else if (previousArray.count < currentArray.count) {
                Drink *drink = [ASTDifference(currentArray, previousArray) firstObject];
                NSInteger index = [currentArray indexOfObject:drink];
                NSInteger section = [sortedKeys(current.allKeys) indexOfObject:changedKey];

                indexPath = [NSIndexPath indexPathForRow:index inSection:section];
                change = TableViewChangeRowInsertion;
            } else {
                indexPath = nil;
                change = TableViewChangeNone;
            }
            
            return [RACTuple tupleWithObjects:@(change), indexPath, nil];
        }]
        ignore:nil];

    return [RACSignal merge:@[sectionChanges, rowChanges]];
}

@end
