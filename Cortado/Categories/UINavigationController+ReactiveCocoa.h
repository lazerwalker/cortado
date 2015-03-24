@import UIKit;

@interface UINavigationController (ReactiveCocoa)

- (RACSignal *)rac_pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (RACSignal *)rac_popViewControllerAnimated:(BOOL)animated;
- (RACSignal *)rac_popToViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end
