@import UIKit;

@class RACSignal;

@interface UIViewController (ReactiveCocoa)

- (RACSignal *)rac_presentViewController:(UIViewController *)modal
                                animated:(BOOL)animated;

- (RACSignal *)rac_dismissViewControllerAnimated:(BOOL)animated;

@end
