@import UIKit;
#import <ARAnalytics/ARAnalytics.h>

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "Drink.h"

#import "CreateCustomDrinkViewController.h"

@interface CustomDrinkForm : NSObject <FXForm>
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *caffeine;
@end

@implementation CustomDrinkForm
- (NSDictionary *)caffeineField {
    return @{FXFormFieldTitle: @"Caffeine Content (mg)",
             FXFormFieldDefaultValue: @150,
             FXFormFieldType: FXFormFieldTypeUnsigned};
}
@end

@implementation CreateCustomDrinkViewController

- (id)init {
    self = [super init];
    if (!self) { return nil; }

    _drinkCreatedSignal = [RACSubject subject];

    self.formController.form = [[CustomDrinkForm alloc] init];

    self.title = @"Add Custom Drink";

    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStyleDone target:self action:@selector(didTapDoneButton)];
    self.navigationItem.rightBarButtonItem = done;

    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // TODO: Is there a better way to do this purely using FXForms?
    NSIndexPath *namePath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *nameCell = [self.tableView cellForRowAtIndexPath:namePath];
    [nameCell becomeFirstResponder];
}

#pragma mark -
- (void)didTapDoneButton {
    CustomDrinkForm *form = (CustomDrinkForm *)self.formController.form;

    Drink *drink = [[Drink alloc] initWithName:form.name
                                               caffeine:form.caffeine];

    [ARAnalytics event:@"Created custom drink" withProperties:@{@"name":drink.name, @"caffeine":drink.caffeine}];
    [self.drinkCreatedSignal sendNext:drink];
    [self.drinkCreatedSignal sendCompleted];
}

@end
