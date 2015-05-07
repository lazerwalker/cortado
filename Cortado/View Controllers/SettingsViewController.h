@import UIKit;

@class DataStore;
@class PreferencesViewModel;

@interface SettingsViewController : UITableViewController

@property (readwrite, nonatomic, strong) DataStore *dataStore;
@property (readwrite, nonatomic, strong) PreferencesViewModel *preferencesViewModel;

- (id)initWithDataStore:(DataStore *)dataStore
   preferencesViewModel:(PreferencesViewModel *)preferencesViewModel;

@end
