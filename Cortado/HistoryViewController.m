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

            } completed:^{
                @strongify(self)
                [self.viewModel refetchHistory];
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
        @weakify(self)
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
            } completed:^{
                @strongify(self)
                [self.viewModel refetchHistory];
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
