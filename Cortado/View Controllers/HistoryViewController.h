@import UIKit;

@class HistoryViewModel;
@class PreferencesViewModel;

@interface HistoryViewController : UITableViewController

@property (readonly, nonatomic, strong) HistoryViewModel *viewModel;
@property (readonly, nonatomic, strong) PreferencesViewModel *preferredDrinksViewModel;

- (id)initWithHistoryViewModel:(HistoryViewModel *)viewModel
      preferredDrinksViewModel:(PreferencesViewModel *)preferredDrinksViewModel;

@end
