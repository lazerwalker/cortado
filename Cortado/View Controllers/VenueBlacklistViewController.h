@import UIKit;

@class DataStore;

typedef NS_ENUM(NSInteger, VenueBlacklistSection) {
    VenueBlacklistSectionBlacklisted,
    VenueBlacklistSectionHistory,
    VenueBlacklistSectionCount
};

@interface VenueBlacklistViewController : UITableViewController

- (id)initWithDataStore:(DataStore *)dataStore;

@end
