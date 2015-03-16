@import UIKit;

#import "FTUEViewController.h"
#import "FTUEScreen.h"

@interface LocationFTUEViewController : UIViewController <FTUEScreen>

@property (copy, readonly) FTUEAuthorizationBlock authorizationBlock;

- (id)initWithAuthorizationBlock:(FTUEAuthorizationBlock)authorizationBlock;

@end
