#import <ReactiveCocoa/ReactiveCocoa.h>

#import "DrinkSubtype.h"

#import "DrinkSubtypeSelectionViewController.h"

static NSString * const CellIdentifier = @"Cell";

@interface DrinkSubtypeSelectionViewController ()

@end

@implementation DrinkSubtypeSelectionViewController

- (id)initWithSubtypes:(NSArray *)subtypes {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (!self) return nil;

    _subtypes = subtypes;
    _subtypeSelectedSignal = [RACSubject subject];

    return self;
}

#pragma mark -

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    DrinkSubtype *subtype = self.subtypes[indexPath.row];
    cell.textLabel.text = subtype.name;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DrinkSubtype *subtype = self.subtypes[indexPath.row];
    [(RACSubject *)self.subtypeSelectedSignal sendNext:subtype];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.subtypes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    return cell;
}

@end
