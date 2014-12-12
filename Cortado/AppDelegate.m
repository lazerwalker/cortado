@import CoreLocation;
@import HealthKit;

#import <CocoaPods-Keys/CortadoKeys.h>
#import <Parse/Parse.h>

#import "Beverage.h"
#import "BeverageConsumption.h"
#import "BeverageProcessor.h"
#import "FoursquareClient.h"
#import "FoursquareVenue.h"
#import "TodayInterface.h"
#import "DrinkSelectionViewController.h"

#import "AppDelegate.h"

NSString * const NotificationCategoryBeverage  = @"BEVERAGE";
NSString * const NotificationActionOne = @"DRINK_ONE";
NSString * const NotificationActionTwo = @"DRINK_TWO";

@interface AppDelegate () <CLLocationManagerDelegate>

@property (nonatomic, strong) TodayInterface *interface;
@property (nonatomic, strong) BeverageProcessor *processor;

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

    // Background fetch
    [application setMinimumBackgroundFetchInterval: UIApplicationBackgroundFetchIntervalMinimum];

    CortadoKeys *keys = [[CortadoKeys alloc] init];
    [Parse setApplicationId:keys.parseAppID
                  clientKey:keys.parseClientKey];


    // Notifications
    UIMutableUserNotificationAction *notificationAction1 = [[UIMutableUserNotificationAction alloc] init];
    notificationAction1.identifier = NotificationActionOne;
    notificationAction1.title = @"Cortado";
    notificationAction1.activationMode = UIUserNotificationActivationModeBackground;
    notificationAction1.destructive = NO;
    notificationAction1.authenticationRequired = NO;

    UIMutableUserNotificationAction *notificationAction2 = [[UIMutableUserNotificationAction alloc] init];
    notificationAction2.identifier = NotificationActionTwo;
    notificationAction2.title = @"Iced Latte";
    notificationAction2.activationMode = UIUserNotificationActivationModeBackground;
    notificationAction2.destructive = NO;
    notificationAction2.authenticationRequired = NO;

    UIMutableUserNotificationCategory *notificationCategory = [[UIMutableUserNotificationCategory alloc] init];
    notificationCategory.identifier = NotificationCategoryBeverage;
    [notificationCategory setActions:@[notificationAction1,notificationAction2] forContext:UIUserNotificationActionContextDefault];
    [notificationCategory setActions:@[notificationAction1,notificationAction2] forContext:UIUserNotificationActionContextMinimal];

    NSSet *category = [NSSet setWithObject:notificationCategory];

    UIUserNotificationType notificationType = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:notificationType categories:category];
    [UIApplication.sharedApplication registerUserNotificationSettings:notificationSettings];
    [UIApplication.sharedApplication registerForRemoteNotifications];

    DrinkSelectionViewController *vc = [[DrinkSelectionViewController alloc] initWithStyle:UITableViewStyleGrouped];
    self.window = [[UIWindow alloc] init];
    self.window.rootViewController = vc;
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
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {

    UILocalNotification *notif = [[UILocalNotification alloc] init];
    notif.alertBody = @"Perform background fetch.";
    [UIApplication.sharedApplication scheduleLocalNotification:notif];

    [self.interface processAllNewBeveragesWithCompletion:^(NSArray *addedItems) {
        if ([addedItems count] > 0) {
            completionHandler(UIBackgroundFetchResultNewData);
        } else {
            completionHandler(UIBackgroundFetchResultNoData);
        }
        [self.interface stopListening];
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {

    UILocalNotification *notif = [[UILocalNotification alloc] init];
    notif.alertBody = @"Remote notification received.";
    [UIApplication.sharedApplication scheduleLocalNotification:notif];

    [self.interface processAllNewBeveragesWithCompletion:^(NSArray *addedItems) {
        if ([addedItems count] > 0) {
            completionHandler(UIBackgroundFetchResultNewData);
        } else {
            completionHandler(UIBackgroundFetchResultNoData);
        }
        [self.interface stopListening];
    }];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler {
    NSDate *timestamp = notification.userInfo[@"timestamp"];
    Beverage *beverage;
    if ([identifier isEqualToString:NotificationActionOne]) {
        beverage = [[Beverage alloc] initWithName:@"Cortado" caffeine:@150];
    } else {
        beverage = [[Beverage alloc] initWithName:@"Iced Latte" caffeine:@150];
    }

    BeverageConsumption *consumption = [[BeverageConsumption alloc] initWithBeverage:beverage timestamp:timestamp];

    [self.processor processBeverage:consumption
                     withCompletion:^(BOOL success, NSError *error) {
        UILocalNotification *notif = [[UILocalNotification alloc] init];
        notif.alertBody = [NSString stringWithFormat:@"Processed beverage %@ at %@? %@", consumption.name, timestamp, @(success)];
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

    [self checkForCoordinate:visit.coordinate];
}

- (void)checkForCoordinate:(CLLocationCoordinate2D)coordinate {
    CortadoKeys *keys = [[CortadoKeys alloc] init];
    FoursquareClient *client = [[FoursquareClient alloc] initWithClientID:keys.foursquareClientID
                                                             clientSecret:keys.foursquareClientSecret];
    NSString *coffeeShops = @"4bf58dd8d48988d1e0931735";
    [client fetchVenuesOfCategory:coffeeShops nearCoordinate:coordinate completion:^(NSArray *results, NSError *error) {
        FoursquareVenue *result = results.firstObject;
        if (result == nil) return;

        UILocalNotification *notif = [[UILocalNotification alloc] init];
        notif.category = NotificationCategoryBeverage;
        notif.userInfo = @{@"timestamp":NSDate.date};
        notif.alertBody = [NSString stringWithFormat:@"It looks like you're at %@. Whatcha drinkin'?", result.name];
        [UIApplication.sharedApplication scheduleLocalNotification:notif];
    }];
}


@end
