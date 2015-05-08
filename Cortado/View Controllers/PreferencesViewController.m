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

typedef void (^PreferencesChangeCompletionBlock)(Drink *);

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

    [RACObserve(self, viewModel.preferences) subscribeNext:^(id _) {
        [self.tableView reloadData];
    }];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didTapAddButton)];

    RAC(self, navigationItem.rightBarButtonItem.enabled) = RACObserve(self, viewModel.canAddMore);
    self.tableView.delegate = nil;
    self.tableView.delegate = self;

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 56.0;

    [self.tableView registerClass:DrinkCell.class forCellReuseIdentifier:NSStringFromClass(DrinkCell.class)];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView setEditing:YES animated:NO];
}

#pragma mark -
- (void)didTapAddButton {
    [self showDrinkSelectionWithCompletion:^(Drink * drink) {
        [ARAnalytics event:@"Added favorite drink" withProperties:@{@"name":drink.name}];
        [self.viewModel addDrink:drink.copy];
    }];

}

- (void)showDrinkSelectionWithCompletion:(PreferencesChangeCompletionBlock)completion {
    DrinkSelectionViewController *drinkVC = [[DrinkSelectionViewController alloc] initWithNoBeverageEnabled:YES];
    [[[[[self.navigationController rac_pushViewController:drinkVC animated:YES]
        concat:drinkVC.selectedDrinkSignal]
       take:1]
      concat:[self.navigationController rac_popToViewController:self animated:YES]]
     subscribeNext:completion];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(DrinkCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.viewModel = [self.viewModel drinkViewModelAtIndex:indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.viewModel.numberOfDrinks == 0) return;

    [self showDrinkSelectionWithCompletion:^(Drink * drink) {
        if (drink == nil) {
            [ARAnalytics event:@"Deleted favorite drink"];
            [self.viewModel removeDrinkAtIndex:indexPath.row];
        } else {
            [ARAnalytics event:@"Edited favorite drink" withProperties:@{@"name":drink.name}];
            [self.viewModel replaceDrinkAtIndex:indexPath.row withDrink:drink.copy];
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [NSString stringWithFormat:@"Favorite Drinks"];
    } else {
        return @"History";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MAX(self.viewModel.numberOfDrinks, 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    return cell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass(DrinkCell.class) forIndexPath:indexPath];
}

#pragma mark - Deleting
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.viewModel.numberOfDrinks > 0;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel removeDrinkAtIndex:indexPath.row];
}

#pragma mark - Moving
- (BOOL) tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    [self.viewModel moveDrinkAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
}


@end
