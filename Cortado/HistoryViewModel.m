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

#import "HistoryViewModel.h"

@interface HistoryViewModel ()
@property (readwrite, nonatomic, strong) NSArray *drinksArray;
@property (readwrite, nonatomic, strong) NSDictionary *clusteredDrinks;
@property (readwrite, nonatomic, strong) NSArray *sortedDateKeys;
@property (readonly, nonatomic, strong) NSDateFormatter *headerDateFormatter;
@end

@implementation HistoryViewModel

- (id)initWithDataStore:(DataStore *)dataStore {
    self = [super init];
    if (!self) return nil;

    _dataStore = dataStore;

    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
    RAC(self, drinksArray) = [RACObserve(self, dataStore.drinks) map:^id(NSArray *drinks) {
        return [drinks sortedArrayUsingDescriptors:@[sortDescriptor]];
    }];

    RAC(self, clusteredDrinks) = [RACObserve(self, drinksArray)
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

    // This is pretty terrible.
    // Since the data source relies on `sortedDateKeys` being set, we don't want
    // consumers to fire until sortedDateKeys is set, but we don't want them
    // observing sortedDateKeys. This... sort of fixes that?
    RAC(self, drinks) = [RACObserve(self, sortedDateKeys) mapReplace:self.drinksArray];

    RAC(self, isEmptyState) = [RACObserve(self, drinksArray) map:^id(NSArray *drinks) {
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
    return [NSSet setWithObject:@keypath(HistoryViewModel.new, drinksArray)];
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

- (AddConsumptionViewModel *)editViewModelAtIndexPath:(NSIndexPath *)indexPath {
    DrinkConsumption *drink = [self drinkAtIndexPath:indexPath];
    return [[AddConsumptionViewModel alloc] initWithConsumption:drink editing:YES];
}

- (HistoryCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isEmptyState) {
        
    }

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

@end
