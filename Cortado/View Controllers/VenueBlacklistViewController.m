#import <ReactiveCocoa/ReactiveCocoa.h>

#import "DataStore.h"
#import "FoursquareVenue.h"

#import "VenueBlacklistViewController.h"

static NSString * const HistoryIdentifier = @"HistoryCell";

@implementation VenueBlacklistViewController

- (id)initWithDataStore:(DataStore *)dataStore {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (!self) return nil;

    _dataStore = dataStore;

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    [RACObserve(self, dataStore.venueHistory) subscribeNext:^(id _) {
        [self.tableView reloadData];
    }];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == VenueBlacklistSectionHistory) {
        if (self.dataStore.venueHistory.count == 0) {
            cell.textLabel.text = @"You haven't been to any coffee shops yet.";
        } else {
            FoursquareVenue *venue = self.dataStore.venueHistory[indexPath.row];
            cell.textLabel.text = venue.name;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@)", venue.address, venue.crossStreet];
        }
    } else if (indexPath.section == VenueBlacklistSectionBlacklisted) {
        FoursquareVenue *venue = self.dataStore.blacklistedVenues[indexPath.row];
        cell.textLabel.text = venue.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@)", venue.address, venue.crossStreet];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.dataStore.blacklistedVenues.count == 0) {
        return 1;
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == VenueBlacklistSectionBlacklisted) {
        return self.dataStore.blacklistedVenues.count;
    } else if (section == VenueBlacklistSectionHistory) {
        if (self.dataStore.venueHistory.count == 0) {
            return 1;
        }
        return self.dataStore.venueHistory.count;
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:HistoryIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:HistoryIdentifier];
        cell.textLabel.numberOfLines = 0;
    }

    return cell;
}

@end
