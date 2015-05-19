#import <Asterism/Asterism.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "DataStore.h"
#import "DrinkConsumption.h"

#import "OverviewViewModel.h"

@interface OverviewViewModel ()

@property (readwrite, nonatomic, strong) DataStore *dataStore;

@property (readwrite, nonatomic, strong) NSString *todayCount;
@property (readwrite, nonatomic, strong) NSString *averageCount;

@end

@implementation OverviewViewModel

- (id)initWithDataStore:(DataStore *)dataStore {
    self = [super init];
    if (!self) return nil;

    self.dataStore = dataStore;

    return self;
}

#pragma mark - KVO

+ (NSSet *)keyPathsForValuesAffectingTodayCount {
    return [NSSet setWithObject:@keypath(OverviewViewModel.new, dataStore.drinks)];
}

+ (NSSet *)keyPathsForValuesAffectingAverageCount {
    return [NSSet setWithObject:@keypath(OverviewViewModel.new, dataStore.drinks)];
}

+ (NSSet *)keyPathsForValuesAffectingTodayDrinksText {
    return [NSSet setWithObject:@keypath(OverviewViewModel.new, dataStore.drinks)];
}

+ (NSSet *)keyPathsForValuesAffectingAverageDrinksText {
    return [NSSet setWithObject:@keypath(OverviewViewModel.new, dataStore.drinks)];
}

#pragma mark -

- (NSString *)todayCount {
    NSCalendar *calendar = NSCalendar.currentCalendar;
    NSArray *today = ASTFilter(self.dataStore.drinks, ^BOOL(DrinkConsumption *drink) {
        return [calendar isDateInToday:drink.timestamp];
    });

    return @(today.count).stringValue;
}

- (NSString *)averageCount {
    NSCalendar *calendar = NSCalendar.currentCalendar;

    NSArray *days = [ASTGroupBy(self.dataStore.drinks, ^id<NSCopying>(DrinkConsumption *drink) {
        return [calendar startOfDayForDate:drink.timestamp];
    }) allKeys];

    days = ASTSort(days);

    NSDate *first = days.firstObject;
    NSDate *last = days.lastObject;
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay fromDate:first toDate:last options:0];
    NSInteger totalDays = MAX(ABS(difference.day), 1);

    CGFloat average = (CGFloat)self.dataStore.drinks.count / totalDays;
    if (fabs(average - roundf(average)) <= 0.25) {
        average = roundf(average);
        return [NSString stringWithFormat:@"%lu", (unsigned long)average];
    } else {
        unsigned long bottom = (int)floorf(average);
        unsigned long top = (int)ceilf(average);
        return [NSString stringWithFormat:@"%lu-%lu", bottom, top];
    }
}

- (NSString *)todayDrinksText {
    NSString *string = @"CAFFEINATED\nDRINK";
    if (![self.todayCount isEqualToString:@"1"]) {
        string = [string stringByAppendingString:@"S"];
    }
    return string;
}

- (NSString *)averageDrinksText {
    NSString *string = @"CAFFEINATED\nDRINK";
    if (![self.averageCount isEqualToString:@"1"]) {
        string = [string stringByAppendingString:@"S"];
    }
    return string;
}
@end
