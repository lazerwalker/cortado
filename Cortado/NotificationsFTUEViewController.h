@import UIKit;

#import "FTUEScreen.h"

@interface NotificationsFTUEViewController : UIViewController<FTUEScreen>

- (id)initWithAuthorizationBlock:(FTUEAuthorizationBlock)authorizationBlock;

@end
