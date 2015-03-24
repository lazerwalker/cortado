#import <ReactiveCocoa/ReactiveCocoa.h>

#import "UIViewController+ReactiveCocoa.h"

@implementation UIViewController (ReactiveCocoa)

- (RACSignal *)rac_presentViewController:(UIViewController *)modal
                                animated:(BOOL)animated {
    return [RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        [self presentViewController:modal animated:animated completion:^{
            [subscriber sendCompleted];
        }];

        return (RACDisposable *)nil;
    }];
}

- (RACSignal *)rac_dismissViewControllerAnimated:(BOOL)animated {
    return [RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        [self dismissViewControllerAnimated:animated completion:^{
            [subscriber sendCompleted];
        }];

        return (RACDisposable *)nil;
    }];
}
@end
