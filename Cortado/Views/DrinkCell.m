#import <ReactiveCocoa/ReactiveCocoa.h>

#import "DrinkCellViewModel.h"

#import "DrinkCell.h"

@implementation DrinkCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (!self) return nil;

    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.detailTextLabel.textColor = [UIColor darkGrayColor];

    return self;
}

- (void)setViewModel:(DrinkCellViewModel *)viewModel {
    // TODO: For some reason, RAC bindings in awakeFromNib weren't working
    _viewModel = viewModel;
    self.textLabel.text = viewModel.title;
    self.detailTextLabel.text = viewModel.subtitle;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
