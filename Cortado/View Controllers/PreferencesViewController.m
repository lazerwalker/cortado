@import UIKit;
#import <ARAnalytics/ARAnalytics.h>

#import <Mantle/Mantle.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "UINavigationController+ReactiveCocoa.h"
#import "UIViewController+ReactiveCocoa.h"

#import "AddConsumptionViewController.h"
#import "AddConsumptionViewModel.h"
#import "HealthKitManager.h"
#import "Drink.h"
#import "DrinkCell.h"
#import "DrinkCellViewModel.h"
#import "DrinkConsumption.h"
#import "DrinkSelectionViewController.h"
#import "PreferencesViewModel.h"

#import "PreferencesViewController.h"

static NSString * const CellIdentifier = @"cell";

@interface PreferencesViewController ()

@end

@implementation PreferencesViewController

- (id)initWithViewModel:(PreferencesViewModel *)viewModel {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (!self) return nil;

    _viewModel = viewModel;

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"My Drinks";

    @weakify(self)
    [RACObserve(self, viewModel.preferences) subscribeNext:^(id x) {
        @strongify(self)
        [self.tableView reloadData];
    }];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didTapAddButton)];

    self.tableView.delegate = nil;
    self.tableView.delegate = self;

    [self.tableView registerClass:DrinkCell.class forCellReuseIdentifier:NSStringFromClass(DrinkCell.class)];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(DrinkCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.viewModel = [self.viewModel drinkViewModelAtIndex:indexPath.section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    DrinkSelectionViewController *drinkVC = [[DrinkSelectionViewController alloc] initWithNoBeverageEnabled:YES];

    UIViewController *currentVC = self.navigationController.visibleViewController;
    [[[[[self.navigationController rac_pushViewController:drinkVC animated:YES]
        concat:drinkVC.selectedDrinkSignal]
        take:1]
        concat:[self.navigationController rac_popToViewController:currentVC animated:YES]]
        subscribeNext:^(Drink *drink) {
            [ARAnalytics event:@"Set favorite drink" withProperties:@{@"name":drink.name ?: @"No Drink"}];
            [self.viewModel addDrink:drink.copy];
        }];
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [NSString stringWithFormat:@"Preferred Drink"];
    } else {
        return @"History";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.numberOfDrinks + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0 ? 1 : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    return cell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass(DrinkCell.class) forIndexPath:indexPath];
}



@end
