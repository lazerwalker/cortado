#import <ReactiveCocoa/ReactiveCocoa.h>

#import "OverviewViewModel.h"

#import "OverviewView.h"

@interface OverviewView ()
@property (weak, nonatomic) IBOutlet UILabel *todayLabel;
@property (weak, nonatomic) IBOutlet UILabel *averageLabel;

@end

@implementation OverviewView

- (id)initWithViewModel:(OverviewViewModel *)viewModel {
    OverviewView *view = [[NSBundle.mainBundle loadNibNamed:NSStringFromClass(self.class) owner:nil options:nil] firstObject];

    view.viewModel = viewModel;

    return view;
}

- (void)awakeFromNib {
    RAC(self, todayLabel.text) = RACObserve(self, viewModel.todayCount);
    RAC(self, averageLabel.text) = RACObserve(self, viewModel.averageCount);
}

@end
