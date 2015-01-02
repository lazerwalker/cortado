#import <Asterism/Asterism.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>

#import "AddConsumptionViewModel.h"
#import "CaffeineHistoryManager.h"
#import "DrinkConsumption.h"

#import "HistoryViewModel.h"

static NSString * const HistoryKey = @"History";

@interface HistoryViewModel ()
@property (readwrite, nonatomic, strong) NSArray *drinks;
@property (readwrite, nonatomic, strong) NSDictionary *clusteredDrinks;
@property (readonly, nonatomic, strong) NSDateFormatter *cellDateFormatter;
@property (readonly, nonatomic, strong) NSDateFormatter *headerDateFormatter;
@end

@implementation HistoryViewModel

- (id)initWithCaffeineHistoryManager:(CaffeineHistoryManager *)manager {
    self = [super init];
    if (!self) return nil;

    _manager = manager;

    RAC(self, drinks) = [[[self rac_signalForSelector:@selector(refetchHistory)]
        flattenMap:^RACStream *(id value) {
            return [[manager fetchHistory] collect];
        }] doNext:^(NSArray *drinks) {
            [self persistDrinks:drinks];
        }];

    RAC(self, clusteredDrinks) = [RACObserve(self, drinks)
        map:^id(NSArray *drinks) {
            NSCalendar *calendar = [NSCalendar currentCalendar];
            return ASTGroupBy(drinks, ^id<NSCopying>(DrinkConsumption *drink) {
                return [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:drink.timestamp];
            });
        }];

    _cellDateFormatter = [[NSDateFormatter alloc] init];
    _cellDateFormatter.timeStyle = NSDateFormatterShortStyle;

    _headerDateFormatter = [[NSDateFormatter alloc] init];
    _headerDateFormatter.dateStyle = NSDateFormatterMediumStyle;

    self.drinks = self.cachedDrinks;

    return self;
}

#pragma mark - KVO
+ (NSSet *)keyPathsForValuesAffectingNumberOfSections {
    return [NSSet setWithObject:@keypath(HistoryViewModel.new, drinks)];
}

#pragma mark - Persistence
- (void)persistDrinks:(NSArray *)drinks {
    if (!self.drinks) { return; }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:drinks];
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    [defaults setObject:data forKey:HistoryKey];
    [defaults synchronize];
}

- (NSArray *)cachedDrinks {
    NSData *data = [NSUserDefaults.standardUserDefaults objectForKey:HistoryKey];
    if (!data) return nil;

    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

#pragma mark -
- (NSArray *)drinksForDateAtIndex:(NSInteger)index {
    id key = self.clusteredDrinks.allKeys[index];
    return self.clusteredDrinks[key];
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    return [[self drinksForDateAtIndex:section] count];
}

- (NSInteger)numberOfSections {
    return self.clusteredDrinks.allKeys.count;
}

- (NSString *)dateStringForSection:(NSInteger)section {
    NSDateComponents *components = self.clusteredDrinks.allKeys[section];
    NSDate *date = [NSCalendar.currentCalendar dateFromComponents:components];
    return [self.headerDateFormatter stringFromDate:date];
}

- (NSString *)titleAtIndexPath:(NSIndexPath *)indexPath {
    DrinkConsumption *drink = [self drinkAtIndexPath:indexPath];
    NSString *title = [drink.name stringByAppendingFormat:@" (%@ mg)", drink.caffeine];

    if (drink.venue) {
        title = [title stringByAppendingFormat:@" at %@", drink.venue];
    }

    return title;
}

- (NSString *)subtitleAtIndexPath:(NSIndexPath *)indexPath {
    DrinkConsumption *drink = [self drinkAtIndexPath:indexPath];
    return [self.cellDateFormatter stringFromDate:drink.timestamp];
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

#pragma mark - Actions
- (RACSignal *)deleteAtIndexPath:(NSIndexPath *)indexPath {
    DrinkConsumption *drink = [self drinkAtIndexPath:indexPath];
    return [self.manager deleteDrink:drink];
}

- (RACSignal *)editDrinkAtIndexPath:(NSIndexPath *)indexPath to:(DrinkConsumption *)to {
    DrinkConsumption *from = [self drinkAtIndexPath:indexPath];
    return [self.manager editDrink:from toDrink:to];
}

#pragma mark - Noop
- (void)refetchHistory {}

@end
