#import <ReactiveCocoa/ReactiveCocoa.h>

#import "AddConsumptionViewModel.h"
#import "DrinkSelectionViewController.h"
#import "DrinkCell.h"

#import "AddConsumptionViewController.h"

static NSString * const CellIdentifier = @"cell";

typedef NS_ENUM(NSInteger, AddConsumptionItem) {
    AddConsumptionItemDrink = 0,
    AddConsumptionItemDate,
    AddConsumptionItemCount
};

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

    [self.tableView registerClass:DrinkCell.class forCellReuseIdentifier:NSStringFromClass(DrinkCell.class)];

    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [RACObserve(self, viewModel.drink) subscribeNext:^(id x) {
        [self.navigationController popToViewController:self animated:YES];
        [self.tableView reloadData];
    }];
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
    return AddConsumptionItemCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    switch(indexPath.section) {
        case AddConsumptionItemDrink:
            return [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass(DrinkCell.class) forIndexPath:indexPath];
        case AddConsumptionItemDate:
            return [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class) forIndexPath:indexPath];
        default:
            return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch(section) {
        case AddConsumptionItemDrink:
            return self.viewModel.drinkTitle;
        case AddConsumptionItemDate:
            return self.viewModel.timestampTitle;
        default:
            return nil;
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    switch(indexPath.section) {
        case AddConsumptionItemDrink:
            [(DrinkCell *)cell setViewModel:self.viewModel.drinkCellViewModel];
            break;
        case AddConsumptionItemDate:
            cell.textLabel.text = self.viewModel.timeString;
            break;
        default:
            break;
    }

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
