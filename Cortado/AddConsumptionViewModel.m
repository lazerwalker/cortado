#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>

#import "Drink.h"
#import "DrinkConsumption.h"
#import "DrinkCellViewModel.h"

#import "AddConsumptionViewModel.h"

@interface AddConsumptionViewModel ()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (readwrite) DrinkCellViewModel *drinkCellViewModel;
@end

@implementation AddConsumptionViewModel

- (id)init {
    self = [super init];
    if (!self) return nil;

    _completedSignal = [RACSubject subject];

    self.timestamp = NSDate.date;

    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    self.dateFormatter.timeStyle = NSDateFormatterShortStyle;

    RAC(self, drinkCellViewModel) = [RACObserve(self, drink) map:^id(Drink *drink) {
        return [[DrinkCellViewModel alloc] initWithDrink:drink];
    }];

    return self;
}

- (id)initWithConsumption:(DrinkConsumption *)consumption {
    self = [self init];

    self.timestamp = consumption.timestamp;
    self.drink = consumption.drink;
    self.venue = consumption.venue;
    self.coordinateString = consumption.coordinateString;

    return self;
}

- (id)initWithConsumption:(DrinkConsumption *)consumption editing:(BOOL)editing {
    self = [self initWithConsumption:consumption];

    _isEditing = editing;

    return self;
}

#pragma mark - KVO
+ (NSSet *)keyPathsForValuesAffectingTimeString {
    return [NSSet setWithObject:@keypath(AddConsumptionViewModel.new, timestamp)];
}

+ (NSSet *)keyPathsForValuesAffectingInputValid {
    return [NSSet setWithObject:@keypath(AddConsumptionViewModel.new, drink)];
}

#pragma mark - Data accessors
- (NSString *)timeString {
    return [self.dateFormatter stringFromDate:self.timestamp];
}

- (NSString *)drinkTitle {
    return @"Drink";
}

- (NSString *)timestampTitle {
    return @"Time";
}

- (BOOL)inputValid {
    return self.drink != nil;
}

#pragma mark - Event handlers
- (void)addDrink {
    DrinkConsumption *consumption = [[DrinkConsumption alloc] initWithDrink:self.drink
                                                                  timestamp:self.timestamp
                                                                      venue:self.venue
                                                                 coordinate:self.coordinateString];
    [self.completedSignal sendNext:consumption];
    [self.completedSignal sendCompleted];
}

- (void)cancel {
    [self.completedSignal sendCompleted];
}

@end
