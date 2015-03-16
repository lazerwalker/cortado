@import UIKit;

@class HistoryViewModel;
@class PreferredDrinksViewModel;

@interface HistoryViewController : UITableViewController

@property (readonly, nonatomic, strong) HistoryViewModel *viewModel;
@property (readonly, nonatomic, strong) PreferredDrinksViewModel *preferredDrinksViewModel;

- (id)initWithHistoryViewModel:(HistoryViewModel *)viewModel
      preferredDrinksViewModel:(PreferredDrinksViewModel *)preferredDrinksViewModel;

@end
