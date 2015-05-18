#import <ReactiveCocoa/ReactiveCocoa.h>

#import "PreferenceFTUEViewController.h"

@interface PreferenceFTUEViewController ()
@property (readonly) RACSubject *completed;
@property (copy, readonly) FTUEAuthorizationBlock authorizationBlock;
@end

@implementation PreferenceFTUEViewController

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
