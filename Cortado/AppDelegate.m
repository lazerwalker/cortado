@import CoreLocation;
@import HealthKit;

#import <CocoaPods-Keys/CortadoKeys.h>
#import <Parse/Parse.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "UIViewController+ReactiveCocoa.h"

#import "AddConsumptionViewModel.h"
#import "AddConsumptionViewController.h"
#import "Drink.h"
#import "DrinkConsumption.h"
#import "DrinkConsumptionSerializer.h"
#import "CaffeineHistoryManager.h"
#import "CoffeeShopNotification.h"
#import "FoursquareClient.h"
#import "FoursquareVenue.h"
#import "FTUEViewController.h"
#import "HistoryViewController.h"
#import "HistoryViewModel.h"
#import "LocationFetcher.h"
#import "PreferredDrinksViewController.h"
#import "PreferredDrinksViewModel.h"

#import "AppDelegate.h"



@interface AppDelegate ()

@property (nonatomic, strong) CaffeineHistoryManager *processor;
@property (nonatomic, strong) LocationFetcher *fetcher;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.processor = [[CaffeineHistoryManager alloc] init];

    CortadoKeys *keys = [[CortadoKeys alloc] init];

    FoursquareClient *client = [[FoursquareClient alloc] initWithClientID:keys.foursquareClientID
                                  clientSecret:keys.foursquareClientSecret];
    self.fetcher = [[LocationFetcher alloc] initWithFoursquareClient:client];

    // Background fetch
    [application setMinimumBackgroundFetchInterval: UIApplicationBackgroundFetchIntervalMinimum];

    [Parse setApplicationId:keys.parseAppID
                  clientKey:keys.parseClientKey];


    [UIApplication.sharedApplication registerForRemoteNotifications];

    // History
    HistoryViewModel *historyVM = [[HistoryViewModel alloc] initWithCaffeineHistoryManager:self.processor];
    HistoryViewController *historyVC = [[HistoryViewController alloc] initWithViewModel:historyVM];
    UINavigationController *historyNav = [[UINavigationController alloc] initWithRootViewController:historyVC];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = historyNav;
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];

    NSString *tokenString = [[[[NSString stringWithFormat:@"ID%@",deviceToken]
        stringByReplacingOccurrencesOfString:@"<" withString:@""]
        stringByReplacingOccurrencesOfString:@">" withString:@""]
        stringByReplacingOccurrencesOfString:@" " withString:@""];

    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.cortado"];
    [defaults setObject:tokenString forKey:@"channel"];
    [defaults synchronize];

    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation addUniqueObject:tokenString forKey:@"channels"];
    [currentInstallation saveInBackground];
}

#pragma mark - Processing

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler {

    DrinkConsumption *consumption = [DrinkConsumptionSerializer consumptionFromUserInfo:notification.userInfo identifier:identifier];

    if (consumption.isValid) {
        [[self.processor processDrink:consumption]
            subscribeCompleted:completionHandler];
    } else {
        UINavigationController *nav = (UINavigationController *)self.window.rootViewController;
        if (nav.presentedViewController) {
            [nav dismissViewControllerAnimated:NO completion:nil];
        }
        [nav popToRootViewControllerAnimated:NO];

        AddConsumptionViewModel *addVM = [[AddConsumptionViewModel alloc] initWithConsumption:(DrinkConsumption *)consumption];
        AddConsumptionViewController *addVC = [[AddConsumptionViewController alloc] initWithViewModel:addVM];
        UINavigationController *addNav = [[UINavigationController alloc] initWithRootViewController:addVC];

        [nav presentViewController:addNav animated:NO completion:nil];
        [addVM.completedSignal subscribeNext:^(DrinkConsumption *c) {
            // TODO: This belongs elsewhere.
            CaffeineHistoryManager *manager = [[CaffeineHistoryManager alloc] init];
            [manager processDrinkImmediately:c];
        } completed:^{
            [nav dismissViewControllerAnimated:YES completion:nil];
            completionHandler();
        }];

    }
}

#pragma mark -
// TODO: This shouldn't be the purview of the app delegate,
// but this will make debugging easy for now.
- (void)manuallyCheckCurrentLocation {
    [self.fetcher manuallyCheckCurrentLocation];
}

@end
