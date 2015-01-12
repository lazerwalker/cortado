#import <Mantle/Mantle.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "UINavigationController+ReactiveCocoa.h"
#import "UIViewController+ReactiveCocoa.h"

#import "AddConsumptionViewController.h"
#import "AddConsumptionViewModel.h"
#import "CaffeineHistoryManager.h"
#import "Drink.h"
#import "DrinkCell.h"
#import "DrinkCellViewModel.h"
#import "DrinkConsumption.h"
#import "DrinkSelectionViewController.h"
#import "PreferredDrinksViewModel.h"

#import "PreferredDrinksViewController.h"

static NSString * const CellIdentifier = @"cell";

@interface PreferredDrinksViewController ()

@end

@implementation PreferredDrinksViewController

- (id)initWithViewModel:(PreferredDrinksViewModel *)viewModel {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (!self) return nil;

    _viewModel = viewModel;

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"My Drinks";

    @weakify(self)
    [RACObserve(self, viewModel.drinks) subscribeNext:^(id x) {
        @strongify(self)
        [self.tableView reloadData];
    }];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Check" style:UIBarButtonItemStylePlain target:UIApplication.sharedApplication.delegate action:@selector(manuallyCheckCurrentLocation)];

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
            [self.viewModel setDrink:drink.copy];
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
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    return cell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass(DrinkCell.class) forIndexPath:indexPath];
}

#pragma mark -

- (void)didTapAddButton {
    AddConsumptionViewModel *addVM = [[AddConsumptionViewModel alloc] init];
    addVM.drink = [self.viewModel drinkAtIndex:0];
    AddConsumptionViewController *addVC = [[AddConsumptionViewController alloc] initWithViewModel:addVM];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:addVC];

    [self.navigationController presentViewController:nav animated:YES completion:nil];
    [addVM.completedSignal subscribeNext:^(DrinkConsumption *c) {
        // TODO: This belongs elsewhere.
        CaffeineHistoryManager *manager = [[CaffeineHistoryManager alloc] init];
        [manager processDrinkImmediately:c];
    } completed:^{
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
}


@end
