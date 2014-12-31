@import CoreLocation;
@import HealthKit;

#import <CocoaPods-Keys/CortadoKeys.h>
#import <Parse/Parse.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "Drink.h"
#import "DrinkConsumption.h"
#import "CaffeineHistoryManager.h"
#import "CoffeeShopNotification.h"
#import "FoursquareClient.h"
#import "FoursquareVenue.h"
#import "HistoryViewController.h"
#import "HistoryViewModel.h"
#import "LocationDetector.h"
#import "PreferredDrinksViewController.h"
#import "PreferredDrinksViewModel.h"

#import "AppDelegate.h"



@interface AppDelegate () <CLLocationManagerDelegate>

@property (nonatomic, strong) CaffeineHistoryManager *processor;

@property (nonatomic, strong) FoursquareClient *foursquareClient;
@property (nonatomic, strong) LocationDetector *detector;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) UITabBarController *tabBar;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.processor = [[CaffeineHistoryManager alloc] init];

    // CLVisit
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];

    CortadoKeys *keys = [[CortadoKeys alloc] init];

    self.foursquareClient = [[FoursquareClient alloc] initWithClientID:keys.foursquareClientID
                                                             clientSecret:keys.foursquareClientSecret];
    self.detector = [[LocationDetector alloc] initWithFoursquareClient:self.foursquareClient];

    // Background fetch
    [application setMinimumBackgroundFetchInterval: UIApplicationBackgroundFetchIntervalMinimum];

    [Parse setApplicationId:keys.parseAppID
                  clientKey:keys.parseClientKey];


    [UIApplication.sharedApplication registerForRemoteNotifications];

    // TODO: Abstract this out somewhere else

    // Preferred drinks
    PreferredDrinksViewModel *preferredVM = [[PreferredDrinksViewModel alloc] init];
    PreferredDrinksViewController *preferredVC = [[PreferredDrinksViewController alloc] initWithViewModel:preferredVM];
    UINavigationController *preferredNav = [[UINavigationController alloc] initWithRootViewController:preferredVC];

    // History
    HistoryViewModel *historyVM = [[HistoryViewModel alloc] initWithCaffeineHistoryManager:self.processor];
    HistoryViewController *historyVC = [[HistoryViewController alloc] initWithViewModel:historyVM];
    UINavigationController *historyNav = [[UINavigationController alloc] initWithRootViewController:historyVC];
    self.tabBar = [[UITabBarController alloc] init];
    self.tabBar.viewControllers = @[preferredNav, historyNav];

    [RACObserve(self.tabBar, selectedViewController) subscribeNext:^(UINavigationController *navController) {
        [navController popToRootViewControllerAnimated:NO];
    }];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.tabBar;
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
    DrinkConsumption *consumption = [CoffeeShopNotification drinkForIdentifier:identifier notification:notification];
    NSLog(@"================> %@", consumption);
    if (!consumption) {
        completionHandler();
        return;
    }

    [[self.processor processDrink:consumption] subscribeCompleted:^{
        UILocalNotification *notif = [[UILocalNotification alloc] init];
        notif.alertBody = [NSString stringWithFormat:@"Processed beverage %@ at %@?", consumption.name, consumption.timestamp];
        [UIApplication.sharedApplication scheduleLocalNotification:notif];

        completionHandler();
    }];

}

#pragma mark - CLLocationDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        [manager startMonitoringVisits];
    }
}

- (void)locationManager:(CLLocationManager *)manager didVisit:(CLVisit *)visit {
    BOOL isStart = [visit.departureDate isEqualToDate:NSDate.distantFuture];
    if (!isStart) return;

    [self.detector checkForCoordinate:visit.coordinate];
}

#pragma mark -
// TODO: This shouldn't be the purview of the app delegate,
// but this will make debugging easy for now.
- (void)manuallyCheckCurrentLocation {
    [self.detector manuallyCheckForCoordinate:self.locationManager.location.coordinate];
}

@end
