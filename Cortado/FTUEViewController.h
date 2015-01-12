@import UIKit;

@class RACSubject;

@interface FTUEViewController : UIPageViewController

@property (readonly, nonatomic, strong) RACSubject *completedSignal;

@end
