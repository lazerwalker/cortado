#import <NotificationCenter/NotificationCenter.h>

#import "AppInterface.h"

#import "TodayViewController.h"

@interface TodayViewController () <NCWidgetProviding>

@property (weak, nonatomic) IBOutlet UIButton *cortadoButton;

@property (readonly, nonatomic, strong) AppInterface *interface;
@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _interface = [[AppInterface alloc] init];
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
    self.cortadoButton.backgroundColor = UIColor.greenColor;
    [self.interface saveBeverage:@"Cortado"
                    withCaffeine:150.0
     completion:^{
         self.cortadoButton.backgroundColor = UIColor.grayColor;
     }];
}


@end
