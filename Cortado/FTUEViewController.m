#import <ReactiveCocoa/ReactiveCocoa.h>

#import "FTUEViewController.h"

@interface FTUEViewController ()
@end

@implementation FTUEViewController

- (id)init {
    self = [super init];
    if (!self) return nil;

    _completedSignal = [RACSubject subject];

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blueColor;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.completedSignal sendCompleted];
    });
}
@end
