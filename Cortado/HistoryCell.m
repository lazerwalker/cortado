#import <ReactiveCocoa/ReactiveCocoa.h>

#import "HistoryCellViewModel.h"

#import "HistoryCell.h"

@implementation HistoryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    self.detailTextLabel.textColor = [UIColor darkGrayColor];
    return self;
}

//- (void)awakeFromNib {
//    RAC(self, textLabel.text) = RACObserve(self, viewModel.title);
//    RAC(self, detailTextLabel.text) = RACObserve(self, viewModel.subtitle);
//}

- (void)setViewModel:(HistoryCellViewModel *)viewModel {
    _viewModel = viewModel;
    self.textLabel.text = viewModel.title;
    self.detailTextLabel.text = viewModel.subtitle;
}


@end
