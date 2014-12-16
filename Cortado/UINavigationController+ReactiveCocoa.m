#import <ReactiveCocoa/ReactiveCocoa.h>

#import "UINavigationController+ReactiveCocoa.h"

@implementation UINavigationController (ReactiveCocoa)

- (RACSignal *)rac_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    return [RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        [self pushViewController:viewController animated:animated];
        [subscriber sendCompleted];

        return (RACDisposable *)nil;
    }];
}

- (RACSignal *)rac_popViewControllerAnimated:(BOOL)animated {
    return [RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        [self popViewControllerAnimated:animated];
        [subscriber sendCompleted];

        return (RACDisposable *)nil;
    }];
}

- (RACSignal *)rac_popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    return [RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        [self popToViewController:viewController animated:animated];
        [subscriber sendCompleted];

        return (RACDisposable *)nil;
    }];
}

@end
