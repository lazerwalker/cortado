@import UIKit;

@class RACSubject;

@interface CreateCustomDrinkViewController : UIViewController

@property (readonly) RACSubject *drinkCreatedSignal;

@end
