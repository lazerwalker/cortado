#import <CocoaPods-Keys/CortadoKeys.h>
#import <NotificationCenter/NotificationCenter.h>
#import <Parse/Parse.h>

#import "AppInterface.h"
#import "Beverage.h"

#import "TodayViewController.h"

@interface TodayViewController () <NCWidgetProviding>

@property (weak, nonatomic) IBOutlet UIButton *cortadoButton;

@property (readonly, nonatomic, strong) AppInterface *interface;
@property (readonly, nonatomic, strong) Beverage *beverage;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _interface = [[AppInterface alloc] init];

    _beverage = [[Beverage alloc] initWithName:@"Cortado" caffeine:@150.0];

    CortadoKeys *keys = [[CortadoKeys alloc] init];
    [Parse setApplicationId:keys.parseAppID
                  clientKey:keys.parseClientKey];
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

#pragma mark -
- (IBAction)didTapCortadoButton:(id)sender {
    self.cortadoButton.enabled = NO;
    [self.cortadoButton setTitle:@"Adding..." forState:UIControlStateDisabled];
    [self.interface saveBeverage:self.beverage
                      completion:^{
         NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.cortado"];
         NSString *channel = [defaults objectForKey:@"channel"];

         PFPush *push = [[PFPush alloc] init];
         [push setChannel:channel];
         [push setMessage:@"addedBeverage"];
         [push setData:@{@"content-available":@1,
                        @"sound":@""}];
         [push sendPushInBackground];
                          [self.cortadoButton setTitle:@"Added! ✓" forState:UIControlStateDisabled];
     }];
}


@end
