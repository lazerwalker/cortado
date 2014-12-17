#import <ReactiveCocoa/ReactiveCocoa.h>

#import "Beverage.h"

#import "CreateCustomDrinkViewController.h"

@implementation CreateCustomDrinkViewController

- (id)init {
    self = [super init];
    if (!self) { return nil; }

    _drinkCreatedSignal = [RACSubject subject];

    return self;
}

- (void)viewDidLoad {
    Beverage *beverage = [[Beverage alloc] initWithName:@"Test Drink" subtype:@"Subtype" caffeine:@150];
    [self.drinkCreatedSignal sendNext:beverage];
    [self.drinkCreatedSignal sendCompleted];
}
@end
