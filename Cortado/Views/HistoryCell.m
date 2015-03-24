#import <ReactiveCocoa/ReactiveCocoa.h>

#import "HistoryCellViewModel.h"

#import "HistoryCell.h"

@interface HistoryCell ()

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *caffeineLabel;
@property (weak, nonatomic) IBOutlet UILabel *drinkLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;

@end

@implementation HistoryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    self.detailTextLabel.textColor = [UIColor darkGrayColor];
    return self;
}

- (void)setViewModel:(HistoryCellViewModel *)viewModel {
    _viewModel = viewModel;
    self.drinkLabel.attributedText = viewModel.title;
    self.timeLabel.text = viewModel.timestamp;
    self.sizeLabel.text = viewModel.size;

    self.caffeineLabel.hidden = YES;
}


@end
