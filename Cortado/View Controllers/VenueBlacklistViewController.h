@import UIKit;

@class DataStore;

typedef NS_ENUM(NSInteger, VenueBlacklistSection) {
    VenueBlacklistSectionBlacklisted,
    VenueBlacklistSectionHistory,
    VenueBlacklistSectionCount
};

@interface VenueBlacklistViewController : UITableViewController

@property (readonly, nonatomic, strong) DataStore *dataStore;

- (id)initWithDataStore:(DataStore *)dataStore;

@end
