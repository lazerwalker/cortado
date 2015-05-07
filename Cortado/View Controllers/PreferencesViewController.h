@import UIKit;

@class PreferencesViewModel;

@interface PreferencesViewController : UITableViewController

@property (readonly, nonatomic, strong) PreferencesViewModel *viewModel;

- (id)initWithViewModel:(PreferencesViewModel *)viewModel;

@end
