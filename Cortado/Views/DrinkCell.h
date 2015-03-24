@import UIKit;

@class Drink;
@class DrinkCellViewModel;

@interface DrinkCell : UITableViewCell

@property (readwrite, nonatomic, strong) DrinkCellViewModel *viewModel;

@end
