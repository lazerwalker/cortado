@import UIKit;

@class RACSignal;

@interface DrinkSelectionViewController : UITableViewController

@property (readonly) RACSubject *selectedDrinkSignal;

@property (readonly, nonatomic, assign) BOOL noBeverageEnabled;

- (id)initWithNoBeverageEnabled:(BOOL)enabled;

@end
