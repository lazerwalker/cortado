#import <ReactiveCocoa/ReactiveCocoa.h>

#import "Beverage.h"

#import "CreateCustomDrinkViewController.h"

@interface CustomDrinkForm : NSObject <FXForm>
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *caffeine;
@end

@implementation CustomDrinkForm
- (NSDictionary *)caffeineField {
    return @{FXFormFieldTitle: @"Caffeine Content (mg)",
             FXFormFieldDefaultValue: @150};
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

#pragma mark -
- (void)didTapDoneButton {
    CustomDrinkForm *form = (CustomDrinkForm *)self.formController.form;

    Beverage *beverage = [[Beverage alloc] initWithName:form.name
                                               caffeine:form.caffeine];
    [self.drinkCreatedSignal sendNext:beverage];
    [self.drinkCreatedSignal sendCompleted];
}

@end
