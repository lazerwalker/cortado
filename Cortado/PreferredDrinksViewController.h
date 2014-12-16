@import UIKit;

@class PreferredDrinksViewModel;

@interface PreferredDrinksViewController : UITableViewController

@property (readonly, nonatomic, strong) PreferredDrinksViewModel *viewModel;

- (id)initWithViewModel:(PreferredDrinksViewModel *)viewModel;

@end
