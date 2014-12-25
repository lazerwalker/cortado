#import <ReactiveCocoa/ReactiveCocoa.h>

#import "AddConsumptionViewController.h"

@implementation AddConsumptionViewController

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (!self) return nil;

    _completedSignal = [RACSubject subject];

    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.completedSignal sendNext:@YES];
}

@end
