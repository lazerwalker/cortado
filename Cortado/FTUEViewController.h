@import UIKit;

@class RACSignal;

@interface FTUEViewController : UINavigationController

typedef void (^FTUEAuthorizationBlock)();

@property (readonly, nonatomic, strong) RACSignal *completedSignal;

+ (BOOL)hasBeenSeen;
+ (void)setAsSeen;

- (id)initWithLocationBlock:(FTUEAuthorizationBlock)locationBlock;

@end
