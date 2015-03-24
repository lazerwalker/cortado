@import UIKit;

@class DataStore;

@interface SettingsViewController : UITableViewController

@property (readwrite, nonatomic, strong) DataStore *dataStore;

- (id)initWithDataStore:(DataStore *)dataStore;

@end
