@import UIKit;

#import "FTUEScreen.h"

@interface HealthKitFTUEViewController : UIViewController<FTUEScreen>

- (id)initWithAuthorizationBlock:(FTUEAuthorizationBlock)authorizationBlock;

@end
