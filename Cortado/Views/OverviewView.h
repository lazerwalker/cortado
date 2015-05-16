@import UIKit;

@class OverviewViewModel;

@interface OverviewView : UIView

@property (readwrite, nonatomic, strong) OverviewViewModel *viewModel;

- (id)initWithViewModel:(OverviewViewModel *)viewModel;

@end
