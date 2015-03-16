@import UIKit;

#import "FTUEScreen.h"

@class RACSignal;

@interface FTUEViewController : UINavigationController

@property (readonly, nonatomic, strong) RACSignal *completedSignal;

+ (BOOL)hasBeenSeen;
+ (void)setAsSeen;

- (id)initWithLocationBlock:(FTUEAuthorizationBlock)locationBlock
    notificationsBlock:(FTUEAuthorizationBlock)notificationBlock
    healthKitBlock:(FTUEAuthorizationBlock)healthKitBlock;

@end
