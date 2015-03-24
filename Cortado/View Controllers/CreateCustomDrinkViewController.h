#import <FXForms/FXForms.h>

@class RACSubject;

@interface CreateCustomDrinkViewController : FXFormViewController

@property (readonly) RACSubject *drinkCreatedSignal;

@end
