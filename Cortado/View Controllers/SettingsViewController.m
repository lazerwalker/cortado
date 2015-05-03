#import <IntentKit/INKMailHandler.h>
#import <IntentKit/INKWebViewController.h>
#import <iRate/iRate.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <VTAcknowledgementsViewController/VTAcknowledgementsViewController.h>

// TODO: Remove before shipping
#import "AppDelegate.h"
#import "FTUEViewController.h"

#import "DataStore.h"
#import "VenueBlacklistViewController.h"

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithDataStore:(DataStore *)dataStore {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass(self.class) bundle:NSBundle.mainBundle];
    SettingsViewController *vc = [storyboard instantiateInitialViewController];
    vc.dataStore = dataStore;

    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UILabel *footerView = [[UILabel alloc] init];
    footerView.font = [UIFont systemFontOfSize:UIFont.smallSystemFontSize];

    NSString *version = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
#ifdef DEBUG
    NSString *build = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];

    version = [version stringByAppendingFormat:@" (%@)", build];
#endif

    footerView.text = [NSString stringWithFormat:@"Version %@", version];
    [footerView sizeToFit];
    footerView.frame = ({
        CGRect frame = footerView.frame;
        frame.origin.x = 15;
        frame;
    });
    self.tableView.tableFooterView = footerView;

}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#ifdef DEBUG
    return 4;
#else
    return 3;
#endif
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:@"share"]) {
        [self showShareSheet];
    } else if ([cell.reuseIdentifier isEqualToString:@"acknowledgements"]) {
        [self showAcknowledgements];
    } else if ([cell.reuseIdentifier isEqualToString:@"contact"]) {
        [self showEmailSheet];
    } else if ([cell.reuseIdentifier isEqualToString:@"lazerwalker"]) {
        [self showWebSite];
    } else if ([cell.reuseIdentifier isEqualToString:@"manualcheck"]) {
        [self manuallyCheckLocation];
    } else if ([cell.reuseIdentifier isEqualToString:@"rate"]) {
        [self rateInAppStore];
    } else if ([cell.reuseIdentifier isEqualToString:@"reimport"]) {
        [self reimportFromHealthKit];
    } else if ([cell.reuseIdentifier isEqualToString:@"ftue"]) {
        [self showOnboarding];
    } else if ([cell.reuseIdentifier isEqualToString:@"blacklist"]) {
        [self showBlacklist];

    }
}

#pragma mark - Actions

- (void)showShareSheet {
    UIActivityViewController *shareController = [[UIActivityViewController alloc] initWithActivityItems:@[@"I'm tracking my caffeine consumption using Cortado!", [NSURL URLWithString:@"http://lazerwalker.com"]] applicationActivities:nil];

    shareController.excludedActivityTypes = @[UIActivityTypeCopyToPasteboard, UIActivityTypeAddToReadingList];

    [self.navigationController presentViewController:shareController animated:YES completion:nil];
}

- (void)showAcknowledgements {
    VTAcknowledgementsViewController *viewController = [VTAcknowledgementsViewController acknowledgementsViewController];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)showEmailSheet {
    INKMailHandler *mailHandler = [[INKMailHandler alloc] init];
    mailHandler.subject = @"Cortado Feedback";
    [[mailHandler sendMailTo:@"cortado@lazerwalker.com"] presentModally];
}

- (void)showWebSite {
    NSURL *url = [NSURL URLWithString:@"http://lazerwalker.com"];
    INKWebViewController *vc = [[INKWebViewController alloc] init];
    vc.navigationItem.rightBarButtonItem = nil;
    [vc loadURL:url];

    [self.navigationController pushViewController:vc animated:YES];
}

- (void)rateInAppStore {
    [[iRate sharedInstance] openRatingsPageInAppStore];
}

- (void)reimportFromHealthKit {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [[[self.dataStore importFromHealthKit] deliverOnMainThread]
        subscribeError:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [[[UIAlertView alloc] initWithTitle:@"Uh Oh!"
                message:@"There was an error importing your previous caffeine history from HealthKit Double-check that you have granted Cortado read access to caffeine history in Health.app."
                delegate:nil
                cancelButtonTitle:@"OK"
                otherButtonTitles:nil]
            show];
        } completed:^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [[[UIAlertView alloc] initWithTitle:@"Data Imported!"
                message:@"Your previous caffeine history has been successfully imported from HealthKit."
                delegate:nil
                cancelButtonTitle:@"OK"
                otherButtonTitles:nil]
             show];
        }];
}

- (void)showBlacklist {
    VenueBlacklistViewController *blacklistVC = [[VenueBlacklistViewController alloc] initWithDataStore:self.dataStore];
    [self.navigationController pushViewController:blacklistVC animated:YES];
}

// TODO: Remove before shipping
- (void)manuallyCheckLocation {
    [(AppDelegate *)UIApplication.sharedApplication.delegate manuallyCheckCurrentLocation];
}

- (void)showOnboarding {
    FTUEViewController *ftue = [[FTUEViewController alloc] initWithLocationBlock:^{}
                                                              notificationsBlock:^{}
                                                                  healthKitBlock:^{}];
    [ftue.completedSignal subscribeNext: ^(id _){
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
    [self.navigationController presentViewController:ftue animated:YES completion:nil];
}
@end
