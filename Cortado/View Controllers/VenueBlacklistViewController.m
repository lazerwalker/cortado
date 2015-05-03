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

    [RACObserve(self, dataStore.venueHistory) subscribeNext:^(id _) {
        [self.tableView reloadData];
    }];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == VenueBlacklistSectionHistory) {
        FoursquareVenue *venue = self.dataStore.venueHistory[indexPath.row];
        cell.textLabel.text = venue.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@)", venue.address, venue.crossStreet];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataStore.venueHistory.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:HistoryIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:HistoryIdentifier];
    }

    return cell;
}

@end
