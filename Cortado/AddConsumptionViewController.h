@import UIKit;

@class Drink;
@class RACSubject;
@class AddConsumptionViewModel;

@interface AddConsumptionViewController : UITableViewController

@property (readonly) AddConsumptionViewModel *viewModel;

- (id)initWithViewModel:(AddConsumptionViewModel *)viewModel;

@end
