#import <ReactiveCocoa/ReactiveCocoa.h>

#import "LocationFTUEViewController.h"

@interface LocationFTUEViewController ()
@property (readonly) RACSubject *completed;
@end

@implementation LocationFTUEViewController

- (id)initWithAuthorizationBlock:(FTUEAuthorizationBlock)authorizationBlock {
    self = [super init];
    if (!self) return nil;

    _completed = [RACSubject subject];
    _authorizationBlock = authorizationBlock;

    return self;
}

- (IBAction)didTapButton:(id)sender {
    if (self.authorizationBlock) {
        self.authorizationBlock();
    }
    
    [_completed sendNext:self];
    [_completed sendCompleted];
}

@end
