#import <ReactiveCocoa/ReactiveCocoa.h>

#import "IntroFTUEViewController.h"

@interface IntroFTUEViewController ()
@property (readonly) RACSubject *completed;
@end

@implementation IntroFTUEViewController

- (id)init {
    self = [super init];
    if (!self) return nil;

    _completed = [RACSubject subject];

    return self;
}

- (IBAction)didTapButton:(id)sender {
    [_completed sendNext:self];
    [_completed sendCompleted];
}


@end
