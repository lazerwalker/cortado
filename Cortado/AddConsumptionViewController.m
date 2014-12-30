#import <ReactiveCocoa/ReactiveCocoa.h>

#import "AddConsumptionViewModel.h"
#import "DrinkSelectionViewController.h"

#import "AddConsumptionViewController.h"

static NSString * const CellIdentifier = @"cell";

@interface AddConsumptionViewController ()

@end

@implementation AddConsumptionViewController

- (id)initWithViewModel:(AddConsumptionViewModel *)viewModel {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (!self) return nil;

    self.title = @"Add Caffeine";

    _viewModel = viewModel;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self.viewModel action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self.viewModel action:@selector(addDrink)];

    [RACObserve(self, viewModel.drink) subscribeNext:^(id x) {
        [self.navigationController popToViewController:self animated:YES];
        [self.tableView reloadData];
    }];

    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
        
}

#pragma mark -
- (void)showDrinkPicker {
    DrinkSelectionViewController *drinkVC = [[DrinkSelectionViewController alloc] initWithNoBeverageEnabled:NO];

    [self.navigationController pushViewController:drinkVC animated:YES];
    [[drinkVC.selectedDrinkSignal take:1]
        subscribeNext:^(Drink *drink) {
            self.viewModel.drink = drink;
        }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.numberOfItems;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.viewModel titleForItem:section];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = [self.viewModel valueForItem:indexPath.section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    switch(indexPath.section) {
        case AddConsumptionItemDrink:
            [self showDrinkPicker];
            break;
        case AddConsumptionItemDate:
            break;
        default:
            break;
    }
}

@end
