#import <Asterism/Asterism.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>

#import "HealthKitManager.h"

#import "DataStore.h"

static NSString * const HistoryKey = @"History";
static NSString * const VenueHistoryKey = @"VenueHistory";
static NSString * const BlacklistedVenuesKey = @"BlacklistedVenues";

@interface DataStore ()
@property (readwrite, nonatomic, strong) NSArray *drinks;
@property (readwrite, nonatomic, strong) NSOrderedSet *venueHistory;
@property (readwrite, nonatomic, strong) NSOrderedSet *blacklistedVenues;
@end

@implementation DataStore

+ (void)eraseStoredData {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    [defaults setObject:nil forKey:HistoryKey];
    [defaults setObject:nil forKey:VenueHistoryKey];
    [defaults setObject:nil forKey:BlacklistedVenuesKey];
    [defaults synchronize];
}

#pragma mark -

- (id)init {
    return [self initWithHealthKitManager:nil];
}

- (id)initWithHealthKitManager:(HealthKitManager *)healthKitManager {
    self = [super init];
    if (!self) return nil;

    _healthKitManager = healthKitManager;
    self.drinks = self.cachedDrinks ?: @[];
    self.venueHistory = self.cachedVenueHistory ?: [[NSOrderedSet alloc] init];
    self.blacklistedVenues = self.cachedBlacklistedVenues ?: [[NSOrderedSet alloc] init];

    [RACObserve(self, drinks) subscribeNext:^(NSArray *drinks) {
        [self persistDrinks:drinks];
    }];

    [RACObserve(self, venueHistory) subscribeNext:^(NSOrderedSet *venues) {
        [self persistVenueHistory:venues];
    }];

    [RACObserve(self, blacklistedVenues) subscribeNext:^(NSOrderedSet *blacklist) {
        [self persistBlacklistedVenues:blacklist];
    }];

    return self;
}

- (RACSignal *)importFromHealthKit {
    return [[[self.healthKitManager fetchHistory]
        collect]
        doNext:^(id drinks) {
            self.drinks = drinks;
        }];
}

#pragma mark -

- (void)addVenue:(FoursquareVenue *)venue {
    NSMutableOrderedSet *set = [self.venueHistory mutableCopy];

    NSInteger idx = [set indexOfObject:venue];
    if (idx == NSNotFound) {
        [set insertObject:venue atIndex:0];
    } else {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:idx];
        [set moveObjectsAtIndexes:indexSet toIndex:0];
    }

    self.venueHistory = set;
}

- (void)blacklistVenue:(FoursquareVenue *)venue {
    NSMutableSet *set = [self.blacklistedVenues mutableCopy];
    [set addObject:venue];
    self.blacklistedVenues = set.copy;
}

- (void)unblacklistVenue:(FoursquareVenue *)venue {
    NSMutableSet *set = [self.blacklistedVenues mutableCopy];
    [set removeObject:venue];
    self.blacklistedVenues = set.copy;
}

#pragma mark -

- (RACSignal *)addDrink:(DrinkConsumption *)drink {
    self.drinks = [self.drinks arrayByAddingObject:drink];
    return [self.healthKitManager addDrink:drink];
}

- (RACSignal *)deleteDrink:(DrinkConsumption *)drink {
    self.drinks = ASTWithout(self.drinks, drink);
    return [self.healthKitManager deleteDrink:drink];
}

- (RACSignal *)editDrink:(DrinkConsumption *)from toDrink:(DrinkConsumption *)to {
    NSUInteger index = [self.drinks indexOfObject:from];
    NSMutableArray *mutableDrinks = self.drinks.mutableCopy;
    [mutableDrinks replaceObjectAtIndex:index withObject:to];
    self.drinks = mutableDrinks.copy;

    return [self.healthKitManager editDrink:from toDrink:to];
}

- (void)addDrinkImmediately:(DrinkConsumption *)drink {
    [[self addDrink:drink] subscribeNext:^(id x) {}];
}

#pragma mark - Persistence
- (void)persistDrinks:(NSArray *)drinks {
    if (!self.drinks) { return; }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:drinks];
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    [defaults setObject:data forKey:HistoryKey];
    [defaults synchronize];
}

- (void)persistVenueHistory:(NSOrderedSet *)venues {
    if (!self.venueHistory) { return; }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:venues];
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    [defaults setObject:data forKey:VenueHistoryKey];
    [defaults synchronize];
}

- (void)persistBlacklistedVenues:(NSOrderedSet *)blacklistedVenues {
    if (!blacklistedVenues) { return; }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:blacklistedVenues];
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    [defaults setObject:data forKey:BlacklistedVenuesKey];
    [defaults synchronize];
}

- (NSArray *)cachedDrinks {
    NSData *data = [NSUserDefaults.standardUserDefaults objectForKey:HistoryKey];
    if (!data) return nil;

    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (NSOrderedSet *)cachedVenueHistory {
    NSData *data = [NSUserDefaults.standardUserDefaults objectForKey:VenueHistoryKey];
    if (!data) return nil;

    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (NSOrderedSet *)cachedBlacklistedVenues {
    NSData *data = [NSUserDefaults.standardUserDefaults objectForKey:BlacklistedVenuesKey];
    if (!data) return nil;

    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}
@end
