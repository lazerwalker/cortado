#import <ReactiveCocoa/ReactiveCocoa.h>

#import "DrinkCellViewModel.h"

#import "DrinkCell.h"

@implementation DrinkCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (!self) return nil;

    self.detailTextLabel.textColor = [UIColor darkGrayColor];
    self.textLabel.numberOfLines = 0;

    return self;
}

- (void)setViewModel:(DrinkCellViewModel *)viewModel {
    // TODO: For some reason, RAC bindings in awakeFromNib weren't working
    _viewModel = viewModel;
    self.textLabel.text = viewModel.title;
    self.detailTextLabel.text = viewModel.subtitle;

    if (viewModel.isPlaceholder) {
        self.accessoryType = UITableViewCellAccessoryNone;
    } else {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
}

@end
