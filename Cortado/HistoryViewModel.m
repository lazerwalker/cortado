@import CoreLocation;

#import <Asterism/Asterism.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>

#import "AddConsumptionViewModel.h"
#import "DataStore.h"
#import "DrinkConsumption.h"
#import "HealthKitManager.h"
#import "HistoryCellViewModel.h"

#import "HistoryViewModel.h"

static NSString * const FTUECompletedKey = @"completedFTUE";

@interface HistoryViewModel ()
@property (readwrite, nonatomic, strong) NSArray *drinks;
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

    _headerDateFormatter = [[NSDateFormatter alloc] init];
    _headerDateFormatter.dateFormat = @"EEEE, MMMM d";

    return self;
}

#pragma mark - KVO
+ (NSSet *)keyPathsForValuesAffectingNumberOfSections {
    return [NSSet setWithObject:@keypath(HistoryViewModel.new, drinks)];
}


#pragma mark -
- (NSArray *)drinksForDateAtIndex:(NSInteger)index {
    if (index >= self.sortedDateKeys.count) return nil;
    
    id key = self.sortedDateKeys[index];
    return self.clusteredDrinks[key];
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    return [[self drinksForDateAtIndex:section] count];
}

- (NSInteger)numberOfSections {
    return self.sortedDateKeys.count;
}

- (NSString *)dateStringForSection:(NSInteger)section {
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
- (BOOL)shouldShowFTUE {
    return ![NSUserDefaults.standardUserDefaults boolForKey:FTUECompletedKey];
}

- (void)sawFTUE {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    [defaults setBool:YES forKey:FTUECompletedKey];
    [defaults synchronize];
}

- (BOOL)shouldPromptForLocation {
    // TODO: Abstract CLLocationManager away in LocationFetcher
    return [NSUserDefaults.standardUserDefaults boolForKey:FTUECompletedKey] &&
        CLLocationManager.authorizationStatus != kCLAuthorizationStatusAuthorizedAlways;
}

- (void)authorizeLocation {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    [UIApplication.sharedApplication openURL:url];
}

- (BOOL)shouldPromptForHealthKit {
    // TODO: Law of Demeter!
    return [NSUserDefaults.standardUserDefaults boolForKey:FTUECompletedKey] &&
        !self.dataStore.healthKitManager.isAuthorized;
}

@end
