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
        }] doNext:^(NSArray *drinks) {
            [self persistDrinks:drinks];
        }];

    _dateFormatter = [[NSDateFormatter alloc] init];
    _dateFormatter.timeStyle = NSDateFormatterShortStyle;
    _dateFormatter.dateStyle = NSDateFormatterShortStyle;

    self.drinks = self.cachedDrinks;

    return self;
}

#pragma mark - KVO
+ (NSSet *)keyPathsForValuesAffectingNumberOfRows {
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
- (NSInteger)numberOfRows {
    return self.drinks.count;
}

- (NSString *)titleAtIndex:(NSUInteger)index {
    DrinkConsumption *drink = [self drinkAtIndex:index];
    NSString *title = [drink.name stringByAppendingFormat:@" (%@ mg)", drink.caffeine];

    if (drink.venue) {
        title = [title stringByAppendingFormat:@" at %@", drink.venue];
    }

    return title;
}

- (NSString *)subtitleAtIndex:(NSUInteger)index {
    DrinkConsumption *drink = [self drinkAtIndex:index];
    return [self.dateFormatter stringFromDate:drink.timestamp];
}

- (DrinkConsumption *)drinkAtIndex:(NSUInteger)index {
    if (index >= self.drinks.count) return nil;
    return self.drinks[index];
}

- (AddConsumptionViewModel *)editViewModelAtIndex:(NSUInteger)index {
    DrinkConsumption *drink = [self drinkAtIndex:index];
    return [[AddConsumptionViewModel alloc] initWithConsumption:drink editing:YES];
}

#pragma mark - Actions
- (void)deleteAtIndex:(NSUInteger)index {
    DrinkConsumption *drink = [self drinkAtIndex:index];

    @weakify(self)
    [[self.manager deleteDrink:drink]
     subscribeError:^(NSError *error) {
        NSString *message = @"This entry wasn't created by Cortado. You can only delete it from within Apple's Health app.";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Delete"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
         dispatch_async(dispatch_get_main_queue(), ^{
             [alert show];
         });
     } completed:^{
        @strongify(self)
        self.drinks = ASTWithout(self.drinks, drink);
    }];
}

- (void)editDrinkAtIndex:(NSUInteger)index to:(DrinkConsumption *)to {
    @weakify(self)
    DrinkConsumption *from = [self drinkAtIndex:index];

    [[self.manager editDrink:from toDrink:to] subscribeError:^(NSError *error) {
        NSString *message = @"This entry wasn't created by Cortado. You can only edit it from within Apple's Health app.";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Delete"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });

    } completed:^{
        @strongify(self)
        NSMutableArray *array = self.drinks.mutableCopy;
        [array replaceObjectAtIndex:index withObject:to];

        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
        self.drinks = [array.copy sortedArrayUsingDescriptors:@[sort]];
    }];
}

#pragma mark - Noop
- (void)refetchHistory {}

@end
