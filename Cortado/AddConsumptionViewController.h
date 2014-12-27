#import <FXForms/FXForms.h>

@class Drink;
@class RACSubject;

@interface AddConsumptionViewController : FXFormViewController

@property (readonly) RACSubject *completedSignal;

@end
