@import UIKit;

@class RACSignal;

@interface DrinkSelectionViewController : UITableViewController

@property (readonly) RACSubject *selectedDrinkSignal;

@end
