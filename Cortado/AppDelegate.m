@import CoreLocation;
@import HealthKit;
@import UIKit; // Needed to stop ARAnalytics from failing to build?!

#import <ARAnalytics/ARAnalytics.h>
#import <iRate/iRate.h>
#import <Keys/CortadoKeys.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "UIViewController+ReactiveCocoa.h"

#import "AddConsumptionViewModel.h"
#import "AddConsumptionViewController.h"
#import "DataStore.h"
#import "Drink.h"
#import "DrinkConsumption.h"
#import "DrinkConsumptionSerializer.h"
#import "DrinkSelectionViewController.h"
#import "HealthKitManager.h"
#import "CoffeeShopNotification.h"
#import "FoursquareClient.h"
#import "FoursquareVenue.h"
#import "FTUEViewController.h"
#import "HistoryViewController.h"
#import "HistoryViewModel.h"
#import "LocationFetcher.h"
#import "PreferencesViewController.h"
#import "PreferencesViewModel.h"

#import "AppDelegate.h"



@interface AppDelegate ()

@property (nonatomic, strong) DataStore *dataStore;

@end

@implementation AppDelegate

// Permanently disable iRate's auto-prompt
+ (void)initialize {
    [[iRate sharedInstance] setPromptAtLaunch:NO];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

#ifdef SNAPSHOT
    [self fakeData];
#endif

    HealthKitManager *healthKitManager = [[HealthKitManager alloc] init];
    self.dataStore = [[DataStore alloc] initWithHealthKitManager:healthKitManager];

    CortadoKeys *keys = [[CortadoKeys alloc] init];

    FoursquareClient *client = [[FoursquareClient alloc] initWithClientID:keys.foursquareClientID
                                  clientSecret:keys.foursquareClientSecret];
    self.fetcher = [[LocationFetcher alloc] initWithFoursquareClient:client dataStore:self.dataStore];

    [ARAnalytics setupMixpanelWithToken:keys.mixpanelToken];
    NSString *userId = [[UIDevice.currentDevice identifierForVendor] UUIDString];
    [ARAnalytics identifyUserWithID:userId andEmailAddress:userId];

    // History
    HistoryViewModel *historyVM = [[HistoryViewModel alloc] initWithDataStore:self.dataStore
                                                              locationFetcher:self.fetcher];
    PreferencesViewModel *preferredDrinksVM = [[PreferencesViewModel alloc] init];
    HistoryViewController *historyVC = [[HistoryViewController alloc] initWithHistoryViewModel:historyVM preferredDrinksViewModel:preferredDrinksVM];
    UINavigationController *historyNav = [[UINavigationController alloc] initWithRootViewController:historyVC];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = historyNav;
    [self.window makeKeyAndVisible];
    
    if (![FTUEViewController hasBeenSeen]) {
        void (^locationBlock)() = ^{
            [self.fetcher promptForPermissions];
        };

        void (^notificationsBlock)() = ^{
            [UIApplication.sharedApplication registerForRemoteNotifications];
            preferredDrinksVM.shouldRegisterNotificationTypeAutomatically = YES;
        };

        void (^healthKitBlock)() = ^{
            [healthKitManager promptForPermissions];
        };

        void (^preferenceBlock)() = ^{
            DrinkSelectionViewController *drinkVC = [[DrinkSelectionViewController alloc] initWithNoBeverageEnabled:YES];
            drinkVC.title = @"Set Preferred Drink";
            drinkVC.navigationItem.leftBarButtonItem = nil;

            UINavigationController *drinkNav = [[UINavigationController alloc] initWithRootViewController:drinkVC];

            [drinkVC.selectedDrinkSignal subscribeNext:^(Drink *drink) {
                [preferredDrinksVM addDrink:drink];
                [drinkVC.presentingViewController dismissViewControllerAnimated:YES completion:nil];;
            }];

            UIViewController *presenter = self.window.rootViewController;
            if (presenter.presentedViewController) {
                presenter = presenter.presentedViewController;
            }

            [presenter presentViewController:drinkNav animated:YES completion:nil];
        };

        FTUEViewController *ftue = [[FTUEViewController alloc] initWithLocationBlock:locationBlock
                                                                  notificationsBlock:notificationsBlock
                                                                      healthKitBlock:healthKitBlock
                                                                     preferenceBlock:preferenceBlock];
        [ftue.completedSignal subscribeNext: ^(id _){
            [FTUEViewController setAsSeen];
            [historyNav dismissViewControllerAnimated:YES completion:nil];
        }];

        [historyNav presentViewController:ftue animated:NO completion:nil];
    } else {
        // FIXME
        preferredDrinksVM.shouldRegisterNotificationTypeAutomatically = YES;
    }

    return YES;
}

#pragma mark - Processing

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler {

    DrinkConsumption *consumption = [DrinkConsumptionSerializer consumptionFromUserInfo:notification.userInfo identifier:identifier];

    if (consumption.isValid) {
        [ARAnalytics event:@"Added favorite drink from notif"];
        [[self.dataStore addDrink:consumption]
            subscribeCompleted:completionHandler];
    } else {
        [ARAnalytics event:@"Tapped 'other' on notif"];
        UINavigationController *nav = (UINavigationController *)self.window.rootViewController;
        if (nav.presentedViewController) {
            [nav dismissViewControllerAnimated:NO completion:nil];
        }
        [nav popToRootViewControllerAnimated:NO];

        AddConsumptionViewModel *addVM = [[AddConsumptionViewModel alloc] initWithConsumption:(DrinkConsumption *)consumption];
        AddConsumptionViewController *addVC = [[AddConsumptionViewController alloc] initWithViewModel:addVM];
        UINavigationController *addNav = [[UINavigationController alloc] initWithRootViewController:addVC];

        [addVC showDrinkPicker];

        [nav presentViewController:addNav animated:NO completion:nil];
        [[addVM.completedSignal
            flattenMap:^RACStream *(DrinkConsumption *c) {
                BOOL changedTime = ![c.timestamp isEqualToDate:consumption.timestamp];
                [ARAnalytics event:@"Add other" withProperties:@{@"changedTime":@(changedTime),
                                                                 @"name":c.name,
                                                                 @"timestamp":c.timestamp}];

                return [self.dataStore addDrink:c];
            }] subscribeCompleted:^{
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

- (void)fakeData {
    NSString *path = [NSBundle.mainBundle pathForResource:@"testData" ofType:@"plist"];
    NSDictionary *testData = [NSDictionary dictionaryWithContentsOfFile:path];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    for (NSString *key in testData) {
        [defaults setObject:testData[key] forKey:key];
    }
    [defaults synchronize];
}

@end
