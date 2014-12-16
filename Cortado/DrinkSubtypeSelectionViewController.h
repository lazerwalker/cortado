@import UIKit;

@class RACSignal;

@interface DrinkSubtypeSelectionViewController : UITableViewController

- (id)initWithSubtypes:(NSArray *)subtypes;

@property (readonly, nonatomic, strong) NSArray *subtypes;

@property (readonly) RACSignal *subtypeSelectedSignal;

@end
