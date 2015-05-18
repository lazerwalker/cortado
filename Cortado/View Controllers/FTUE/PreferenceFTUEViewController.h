@import UIKit;

#import "FTUEScreen.h"

@interface PreferenceFTUEViewController : UIViewController<FTUEScreen>

- (id)initWithAuthorizationBlock:(FTUEAuthorizationBlock)authorizationBlock;

@end
