@import UIKit;

@class HistoryViewModel;

@interface HistoryViewController : UITableViewController

@property (readonly, nonatomic, strong) HistoryViewModel *viewModel;

- (id)initWithViewModel:(HistoryViewModel *)viewModel;

@end
