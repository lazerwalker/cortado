@import CoreLocation;
@import HealthKit;

#import <CocoaPods-Keys/CortadoKeys.h>
#import <Parse/Parse.h>

#import "Beverage.h"
#import "BeverageConsumption.h"
#import "BeverageProcessor.h"
#import "CoffeeShopNotification.h"
#import "FoursquareClient.h"
#import "FoursquareVenue.h"
#import "LocationDetector.h"
#import "PreferredDrinksViewController.h"
#import "PreferredDrinksViewModel.h"
#import "TodayInterface.h"

#import "AppDelegate.h"



@interface AppDelegate () <CLLocationManagerDelegate>

@property (nonatomic, strong) TodayInterface *interface;
@property (nonatomic, strong) BeverageProcessor *processor;

@property (nonatomic, strong) FoursquareClient *foursquareClient;
@property (nonatomic, strong) LocationDetector *detector;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.processor = [[BeverageProcessor alloc] init];
    self.interface = [[TodayInterface alloc] initWithProcessor:self.processor];

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


    [CoffeeShopNotification registerNotificationType];
    [UIApplication.sharedApplication registerForRemoteNotifications];

    PreferredDrinksViewModel *viewModel = [[PreferredDrinksViewModel alloc] init];
    PreferredDrinksViewController *vc = [[PreferredDrinksViewController alloc] initWithViewModel:viewModel];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self.interface stopListening];
    self.interface = nil;
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    NSLog(@"================> %@", notificationSettings);
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self.interface processAllNewBeveragesWithCompletion:nil];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];

    NSString *tokenString = [[[[NSString stringWithFormat:@"ID%@",deviceToken]
        stringByReplacingOccurrencesOfString:@"<" withString:@""]
        stringByReplacingOccurrencesOfString:@">" withString:@""]
        stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"===============> Registered PNs with token: %@", tokenString);

    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.cortado"];
    [defaults setObject:tokenString forKey:@"channel"];
    [defaults synchronize];

    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation addUniqueObject:tokenString forKey:@"channels"];
    [currentInstallation saveInBackground];
}

#pragma mark - Processing

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler {
    BeverageConsumption *consumption = [CoffeeShopNotification drinkForIdentifier:identifier notification:notification];
    [self.processor processBeverage:consumption
                     withCompletion:^(BOOL success, NSError *error) {
        UILocalNotification *notif = [[UILocalNotification alloc] init];
        notif.alertBody = [NSString stringWithFormat:@"Processed beverage %@ at %@? %@", consumption.name, consumption.timestamp, @(success)];
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
- (void)checkCurrentLocation {
    [self.detector checkForCoordinate:self.locationManager.location.coordinate];
}

@end
