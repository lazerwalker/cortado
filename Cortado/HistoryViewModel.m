#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>

#import "CaffeineHistoryManager.h"
#import "DrinkConsumption.h"

#import "HistoryViewModel.h"

@interface HistoryViewModel ()
@property (readwrite, nonatomic, strong) NSArray *drinks;
@property (readonly, nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation HistoryViewModel

- (id)initWithCaffeineHistoryManager:(CaffeineHistoryManager *)manager {
    self = [super init];
    if (!self) return nil;

    _manager = manager;

    RAC(self, drinks) = [[[self rac_signalForSelector:@selector(refetchHistory)]
        flattenMap:^RACStream *(id value) {
            return [[manager fetchHistory] collect];
        }] map:^id(NSArray *drinks) {
            return drinks.reverseObjectEnumerator.allObjects;
        }];

    _dateFormatter = [[NSDateFormatter alloc] init];
    _dateFormatter.timeStyle = NSDateFormatterShortStyle;
    _dateFormatter.dateStyle = NSDateFormatterShortStyle;

    return self;
}

#pragma mark - KVO
+ (NSSet *)keyPathsForValuesAffectingNumberOfRows {
    return [NSSet setWithObject:@keypath(HistoryViewModel.new, drinks)];
}

#pragma mark -
- (NSInteger)numberOfRows {
    return self.drinks.count;
}

- (NSString *)titleAtIndex:(NSUInteger)index {
    DrinkConsumption *drink = [self drinkAtIndex:index];
    if ([drink.name isEqualToString:@"Unknown Beverage"] || drink.subtype == nil) {
        return [drink.name stringByAppendingFormat:@" (%@ mg)", drink.caffeine];
    } else {
        return [drink.name stringByAppendingFormat:@" (%@ · %@ mg)", drink.subtype, drink.caffeine];
    }

    return drink.name;
}

- (NSString *)subtitleAtIndex:(NSUInteger)index {
    DrinkConsumption *drink = [self drinkAtIndex:index];
    return [self.dateFormatter stringFromDate:drink.timestamp];
}

- (DrinkConsumption *)drinkAtIndex:(NSUInteger)index {
    if (index >= self.drinks.count) return nil;
    return self.drinks[index];
}

#pragma mark - Noop
- (void)refetchHistory {}

@end
