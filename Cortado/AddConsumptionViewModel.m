#import <ReactiveCocoa/ReactiveCocoa.h>

#import "Drink.h"
#import "DrinkConsumption.h"

#import "AddConsumptionViewModel.h"

@implementation AddConsumptionViewModel

- (id)init {
    self = [super init];
    if (!self) return nil;

    _completedSignal = [RACSubject subject];

    self.timestamp = [NSDate date];

    return self;
}

#pragma mark - Data accessors
- (NSString *)titleForItem:(AddConsumptionItem)item {
    switch(item) {
        case AddConsumptionItemDrink:
            return @"Drink";
            break;
        case AddConsumptionItemDate:
            return @"Time";
            break;
        default:
            return nil;
    }
}

- (NSString *)valueForItem:(AddConsumptionItem)item {
    switch(item) {
        case AddConsumptionItemDrink:
            return self.drink.name;
            break;
        case AddConsumptionItemDate:
            return self.timestamp.description;
            break;
        default:
            return nil;
    }
}

- (NSInteger)numberOfItems {
    return AddConsumptionItemCount;
}

#pragma mark - Event handlers
- (void)addDrink {
    DrinkConsumption *consumption = [[DrinkConsumption alloc] initWithDrink:self.drink
                                                                  timestamp:self.timestamp];
    [self.completedSignal sendNext:consumption];
    [self.completedSignal sendCompleted];
}

- (void)cancel {
    [self.completedSignal sendCompleted];
}

@end
