@import UIKit;

@class RACSignal;

@interface FTUEViewController : UINavigationController

@property (readonly, nonatomic, strong) RACSignal *completedSignal;

@end
