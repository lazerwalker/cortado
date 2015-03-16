@import UIKit;

#import "FTUEScreen.h"

@interface FTUEViewController1 : UIViewController <FTUEScreen>

@property (readonly) RACSubject *completed;

@end
