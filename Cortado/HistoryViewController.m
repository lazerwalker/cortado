#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>

#import "AddConsumptionViewModel.h"
#import "AddConsumptionViewController.h"
#import "AppDelegate.h"
#import "FTUEViewController.h"
#import "HistoryCell.h"
#import "HistoryViewModel.h"
#import "PreferredDrinksViewController.h"
#import "PreferredDrinksViewModel.h"

#import "HistoryViewController.h"

static NSString * const CellIdentifier = @"Cell";

@interface HistoryViewController ()
@property (readonly, nonatomic, strong) PreferredDrinksViewModel *preferredDrinksViewModel;
@end

@implementation HistoryViewController

- (id)initWithViewModel:(HistoryViewModel *)viewModel {
    self = [super initWithStyle:UITableViewStylePlain];
    if (!self) return nil;

    _viewModel = viewModel;

    self.title = @"Cortado";

    [[UILabel appearanceWhenContainedIn:UITableViewHeaderFooterView.class, nil] setFont:[UIFont boldSystemFontOfSize:14.0]];

    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.viewModel.shouldShowFTUE) {
        FTUEViewController *ftue = [[FTUEViewController alloc] init];
        [ftue.completedSignal subscribeCompleted:^{
            [self.viewModel sawFTUE];
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [self presentViewController:ftue animated:NO completion:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _preferredDrinksViewModel = [[PreferredDrinksViewModel alloc] init];
    PreferredDrinksViewController *pvc = [[PreferredDrinksViewController alloc] initWithViewModel:self.preferredDrinksViewModel];
    pvc.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 156);
    pvc.tableView.scrollEnabled = NO;

    self.tableView.tableHeaderView = pvc.view;
    self.tableView.tableHeaderView.clipsToBounds = YES;
    [self addChildViewController:pvc];

    UINib *nib = [UINib nibWithNibName:NSStringFromClass(HistoryCell.class) bundle:NSBundle.mainBundle];
    [self.tableView registerNib:nib forCellReuseIdentifier:NSStringFromClass(HistoryCell.class)];
    self.tableView.rowHeight = 56.0;

    [[RACObserve(self.viewModel, drinks)
        subscribeOn:RACScheduler.mainThreadScheduler]
        subscribeNext:^(id obj) {
            [self.tableView reloadData];
        }];


    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Trigger Notification" style:UIBarButtonItemStylePlain target:UIApplication.sharedApplication.delegate action:@selector(manuallyCheckCurrentLocation)];

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
    AddConsumptionViewModel *addVM = [[AddConsumptionViewModel alloc] init];
    addVM.drink = [self.preferredDrinksViewModel drinkAtIndex:0];
    AddConsumptionViewController *addVC = [[AddConsumptionViewController alloc] initWithViewModel:addVM];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:addVC];

    [self.navigationController presentViewController:nav animated:YES completion:nil];
    [addVM.completedSignal subscribeNext:^(DrinkConsumption *c) {
        [[self.viewModel addDrink:c] subscribeNext:^(id x) {}];
    } completed:^{
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(HistoryCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.viewModel = [self.viewModel cellViewModelAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    AddConsumptionViewModel *addVM = [self.viewModel editViewModelAtIndexPath:indexPath];
    AddConsumptionViewController *addVC = [[AddConsumptionViewController alloc] initWithViewModel:addVM];
    [self.navigationController pushViewController:addVC animated:YES];

    @weakify(self)
    [addVM.completedSignal subscribeNext:^(DrinkConsumption *drink) {
        [[self.viewModel editDrinkAtIndexPath:indexPath to:drink]
            subscribeError:^(NSError *error) {
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
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[self.viewModel deleteAtIndexPath:indexPath]
            subscribeError:^(NSError *error) {
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
    return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(HistoryCell.class) forIndexPath:indexPath];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.viewModel dateStringForSection:section];
}
@end
