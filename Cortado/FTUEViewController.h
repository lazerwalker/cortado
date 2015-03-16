@import UIKit;

@class RACSignal;

@interface FTUEViewController : UINavigationController

@property (readonly, nonatomic, strong) RACSignal *completedSignal;

+ (BOOL)hasBeenSeen;
+ (void)setAsSeen;

@end
