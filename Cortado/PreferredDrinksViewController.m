#import <Mantle/Mantle.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "UINavigationController+ReactiveCocoa.h"

#import "Beverage.h"
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

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Check" style:UIBarButtonItemStylePlain target:UIApplication.sharedApplication.delegate action:@selector(checkCurrentLocation)];

    self.tableView.delegate = nil;
    self.tableView.delegate = self;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = [self.viewModel titleAtIndex:indexPath.section];
    cell.detailTextLabel.text = [self.viewModel subtitleAtIndex:indexPath.section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DrinkSelectionViewController *drinkVC = [[DrinkSelectionViewController alloc] initWithNoBeverageEnabled:YES];
    [[[[[self.navigationController rac_pushViewController:drinkVC animated:YES]
        concat:drinkVC.selectedDrinkSignal]
        take:1]
        concat:[self.navigationController rac_popToViewController:self animated:YES]]
        subscribeNext:^(Beverage *drink) {
            [self.viewModel setDrink:drink.copy forIndex:indexPath.section];
        }];
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"Drink #%@", @(section + 1)];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.numberOfDrinks;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    }

    return cell;
}


@end
