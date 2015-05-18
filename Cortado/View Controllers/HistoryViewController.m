@import UIKit; // ARAnalytics
#import <ARAnalytics/ARAnalytics.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>

#import "AddConsumptionViewModel.h"
#import "AddConsumptionViewController.h"
#import "AppDelegate.h"
#import "DrinkConsumption.h"
#import "EmptyStateCell.h"
#import "FTUEViewController.h"
#import "HistoryCell.h"
#import "HistoryViewModel.h"
#import "OverviewView.h"
#import "OverviewViewModel.h"
#import "PreferencesViewController.h"
#import "PreferencesViewModel.h"
#import "SettingsViewController.h"

#import "HistoryViewController.h"

static NSString * const CellIdentifier = @"Cell";

@interface HistoryViewController ()
@end

@implementation HistoryViewController

- (id)initWithHistoryViewModel:(HistoryViewModel *)viewModel preferredDrinksViewModel:(PreferencesViewModel *)preferredDrinksViewModel {

    self = [super initWithStyle:UITableViewStylePlain];
    if (!self) return nil;

    _viewModel = viewModel;
    _preferredDrinksViewModel = preferredDrinksViewModel;

    [[UILabel appearanceWhenContainedIn:UITableViewHeaderFooterView.class, nil] setFont:[UIFont boldSystemFontOfSize:14.0]];

    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = @"Cortado";
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.title = @"History";
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 56.0;

    OverviewView *overview = [[OverviewView alloc] initWithViewModel:[self.viewModel overviewViewModel]];

    RAC(self, tableView.tableHeaderView) = [RACObserve(self, viewModel.isEmptyState) map:^id(NSNumber* isEmptyState) {
        return isEmptyState.boolValue ? nil : overview;
    }];

    UINib *nib = [UINib nibWithNibName:NSStringFromClass(HistoryCell.class) bundle:NSBundle.mainBundle];
    [self.tableView registerNib:nib forCellReuseIdentifier:NSStringFromClass(HistoryCell.class)];

    nib = [UINib nibWithNibName:NSStringFromClass(EmptyStateCell.class) bundle:NSBundle.mainBundle];
    [self.tableView registerNib:nib forCellReuseIdentifier:NSStringFromClass(EmptyStateCell.class)];

    RAC(self, tableView.scrollEnabled) = [RACObserve(self, viewModel.isEmptyState) not];
    [[RACObserve(self, viewModel.isEmptyState)
        distinctUntilChanged]
        subscribeNext:^(id x) {
            [self.tableView reloadData];
        }];
    
    [[self.viewModel.dataChanged deliverOnMainThread]
        subscribeNext:^(RACTuple *update) {
            TableViewChange change = [update.first integerValue];

            if (change == TableViewChangeNone) {
                [self.tableView reloadData];
                return;
            }

            [self.tableView beginUpdates];
            switch (change) {
                case TableViewChangeSectionDeletion: {
                    NSIndexSet *indexSet = update.second;
                    [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
                    break;
                }
                case TableViewChangeSectionInsertion: {
                    NSIndexSet *indexSet = update.second;
                    [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
                    break;
                }
                case TableViewChangeRowDeletion: {
                    NSArray *indexPaths = @[update.second];
                    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                    break;
                }
                case TableViewChangeRowInsertion: {
                    NSArray *indexPaths = @[update.second];
                    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                    break;
                }
                default: { break; }
            }
            [self.tableView endUpdates];
        }];


    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings"] style:UIBarButtonItemStylePlain target:self action:@selector(didTapSettingsButton)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didTapAddButton)];

    // Permissions errors
    if (self.viewModel.shouldPromptForHealthKit) {
        [self promptForHealthKit];
    } else if (self.viewModel.shouldPromptForLocation) {
        [self promptForLocation];
    }
}

- (void)promptForHealthKit {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"HealthKit Not Authorized"
                                                                   message:@"To save your data, Cortado needs access to HealthKit.\n\nPlease open the Health app, navigate to the 'Sources' tab, and grant Cortado access to write caffeine data."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         if (self.viewModel.shouldPromptForLocation) {
                                                             [self promptForLocation];
                                                         }}];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)promptForLocation {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Location Services Disabled"
                                                                   message:@"To get the most out of Cortado, it needs access to your location. Please open the app's location settings and grant it 'Always' permissions."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Open Settings"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) { [self.viewModel authorizeLocation]; }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"No Thanks"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {}];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -

- (void)didTapAddButton {
    Drink *preferredDrink = [self.preferredDrinksViewModel drinkAtIndex:0];
    AddConsumptionViewModel *addVM = [self.viewModel addConsumptionViewModelWithPreferredDrink:preferredDrink];

    AddConsumptionViewController *addVC = [[AddConsumptionViewController alloc] initWithViewModel:addVM];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:addVC];

    [self.navigationController presentViewController:nav animated:YES completion:nil];
    [addVM.completedSignal subscribeNext:^(DrinkConsumption *c) {
        BOOL isRecent = ABS([c.timestamp timeIntervalSinceNow]) < (60 * 60);
        [ARAnalytics event:@"Add via add button" withProperties:@{@"timestamp":c.timestamp,
                                                                  @"drink":c.name,
                                                                  @"isRecent":@(isRecent)}];
        [[self.viewModel addDrink:c] subscribeNext:^(id x) {}];
    } completed:^{
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)didTapSettingsButton {
    SettingsViewController *settingsVC = [[SettingsViewController alloc] initWithDataStore:self.viewModel.dataStore
                                          preferencesViewModel:self.preferredDrinksViewModel];
    [self.navigationController pushViewController:settingsVC animated:YES];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(HistoryCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.viewModel.isEmptyState) {
        cell.viewModel = [self.viewModel cellViewModelAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (self.viewModel.isEmptyState) return;

    [ARAnalytics event:@"Edited drink"];

    AddConsumptionViewModel *addVM = [self.viewModel editViewModelAtIndexPath:indexPath];
    AddConsumptionViewController *addVC = [[AddConsumptionViewController alloc] initWithViewModel:addVM];
    [self.navigationController pushViewController:addVC animated:YES];

    @weakify(self)
    [addVM.completedSignal subscribeNext:^(DrinkConsumption *drink) {
        [[self.viewModel editDrinkAtIndexPath:indexPath to:drink]
            subscribeError:^(NSError *error) {
                [ARAnalytics event:@"Tried to edit HealthKit"];

                NSString *message = @"This entry wasn't created by Cortado. You can only edit it from within Apple's Health app.";
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Delete"
                                                                message:message
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [alert show];
                });

            }];
    } completed:^{
        @strongify(self)
        [self.navigationController popToViewController:self animated:YES];
    }];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return !self.viewModel.isEmptyState;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [ARAnalytics event:@"Deleted a drink"];

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[self.viewModel deleteAtIndexPath:indexPath]
            subscribeError:^(NSError *error) {
                [ARAnalytics event:@"Tried to delete HealthKit"];

                NSString *message = @"This entry wasn't created by Cortado. You can only delete it from within Apple's Health app.";
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Delete"
                                                                message:message
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [alert show];
                });
            }];
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
    NSString *cellClass = NSStringFromClass(HistoryCell.class);
    if (self.viewModel.isEmptyState) cellClass = NSStringFromClass(EmptyStateCell.class);
    
    return [tableView dequeueReusableCellWithIdentifier:cellClass forIndexPath:indexPath];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.viewModel dateStringForSection:section];
}
@end
