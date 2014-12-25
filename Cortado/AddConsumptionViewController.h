@import UIKit;

@class Drink;
@class RACSubject;

@interface AddConsumptionViewController : UITableViewController

@property (readonly) RACSubject *completedSignal;

@property (readwrite, nonatomic, strong) Drink *drink;
@property (readwrite, nonatomic, strong) NSDate *date;

@end
