#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>

#import "AddConsumptionViewModel.h"
#import "AddConsumptionViewController.h"
#import "HistoryViewModel.h"

#import "HistoryViewController.h"

static NSString * const CellIdentifier = @"Cell";

@implementation HistoryViewController

- (id)initWithViewModel:(HistoryViewModel *)viewModel {
    self = [super initWithStyle:UITableViewStylePlain];
    if (!self) return nil;

    _viewModel = viewModel;

    self.title = @"History";

    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.viewModel refetchHistory];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    @weakify(self)
    [[RACObserve(self.viewModel, drinks)
        deliverOn:RACScheduler.mainThreadScheduler]
        subscribeNext:^(id obj) {
            @strongify(self)
            [self.tableView reloadData];
        }];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = [self.viewModel titleAtIndexPath:indexPath];
    cell.detailTextLabel.text = [self.viewModel subtitleAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    AddConsumptionViewModel *addVM = [self.viewModel editViewModelAtIndexPath:indexPath];
    AddConsumptionViewController *addVC = [[AddConsumptionViewController alloc] initWithViewModel:addVM];
    [self.navigationController pushViewController:addVC animated:YES];
    [addVM.completedSignal subscribeNext:^(DrinkConsumption *drink) {
        [self.viewModel editDrinkAtIndexPath:indexPath to:drink];
    } completed:^{
        [self.navigationController popToViewController:self animated:YES];
    }];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.viewModel deleteAtIndexPath:indexPath];
        [self.tableView setEditing:NO];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.viewModel dateStringForSection:section];
}
@end
