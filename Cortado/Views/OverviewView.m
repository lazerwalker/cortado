#import <ReactiveCocoa/ReactiveCocoa.h>

#import "OverviewViewModel.h"

#import "OverviewView.h"

@interface OverviewView ()
@property (weak, nonatomic) IBOutlet UILabel *todayLabel;
@property (weak, nonatomic) IBOutlet UILabel *averageLabel;

@property (weak, nonatomic) IBOutlet UILabel *averageDrinksLabel;
@property (weak, nonatomic) IBOutlet UILabel *todayDrinksLabel;

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

    RAC(self, averageDrinksLabel.text) = RACObserve(self, viewModel.averageDrinksText);
    RAC(self, todayDrinksLabel.text) = RACObserve(self, viewModel.todayDrinksText);
}

@end
