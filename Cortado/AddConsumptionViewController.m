#import <ReactiveCocoa/ReactiveCocoa.h>

#import "DrinkSelectionViewController.h"

#import "AddConsumptionViewController.h"

@interface DrinkConsumptionForm : NSObject <FXForm>
@property (nonatomic, strong) Drink *drink;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, strong) NSString *venue;
@end

@implementation DrinkConsumptionForm

- (NSDictionary *)drinkField {
    return @{FXFormFieldAction: @"showDrinkPicker"};
}

@end


@implementation AddConsumptionViewController

- (id)init {
    self = [super init];
    if (!self) return nil;

    _completedSignal = [RACSubject subject];
    self.formController.form = [[DrinkConsumptionForm alloc] init];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(didTapCancelButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(didTapDoneButton)];


    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark -
- (void)showDrinkPicker {
    DrinkSelectionViewController *drinkVC = [[DrinkSelectionViewController alloc] initWithNoBeverageEnabled:NO];

    [self.navigationController pushViewController:drinkVC animated:YES];
    [[drinkVC.selectedDrinkSignal take:1]
        subscribeNext:^(Drink *drink) {
            [(DrinkConsumptionForm *)self.formController.form setDrink:drink];
            [self.navigationController popToViewController:self animated:YES];
            [self.tableView reloadData];
        }];

}

#pragma mark - Event handlers

- (void)didTapDoneButton {
    [self.completedSignal sendNext:@YES];
    [self.completedSignal sendCompleted];
}

- (void)didTapCancelButton {
    [self.completedSignal sendCompleted];
}

@end
