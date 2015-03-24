@import UIKit;

#import "FTUEScreen.h"

@interface LocationFTUEViewController : UIViewController <FTUEScreen>

- (id)initWithAuthorizationBlock:(FTUEAuthorizationBlock)authorizationBlock;

@end
