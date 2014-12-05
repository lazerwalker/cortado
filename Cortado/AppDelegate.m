@import CoreLocation;
@import HealthKit;

#import <CocoaPods-Keys/CortadoKeys.h>
#import <Parse/Parse.h>

#import "BeverageProcessor.h"
#import "FoursquareClient.h"
#import "FoursquareVenue.h"
#import "TodayInterface.h"

#import "AppDelegate.h"

@interface AppDelegate () <CLLocationManagerDelegate>

@property (nonatomic, strong) TodayInterface *interface;
@property (nonatomic, strong) BeverageProcessor *processor;

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.processor = [[BeverageProcessor alloc] init];
    self.interface = [[TodayInterface alloc] initWithProcessor:self.processor];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];

    [application setMinimumBackgroundFetchInterval: UIApplicationBackgroundFetchIntervalMinimum];

    CortadoKeys *keys = [[CortadoKeys alloc] init];
    [Parse setApplicationId:keys.parseAppID
                  clientKey:keys.parseClientKey];

    [UIApplication.sharedApplication registerForRemoteNotifications];

    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self.interface stopListening];
    self.interface = nil;
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    NSLog(@"================> %@", notificationSettings);
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

#pragma mark - CLLocationDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        [manager startMonitoringVisits];
    }
}

- (void)locationManager:(CLLocationManager *)manager didVisit:(CLVisit *)visit {
    UILocalNotification *notif = [[UILocalNotification alloc] init];
    notif.alertBody = [NSString stringWithFormat:@"Received CLVisit. Start? %@", @([visit.departureDate isEqualToDate:NSDate.distantFuture])];
    [UIApplication.sharedApplication scheduleLocalNotification:notif];

    CortadoKeys *keys = [[CortadoKeys alloc] init];
    FoursquareClient *client = [[FoursquareClient alloc] initWithClientID:keys.foursquareClientID
                                                             clientSecret:keys.foursquareClientSecret];
    NSString *coffeeShops = @"4bf58dd8d48988d1e0931735";
    [client fetchVenuesOfCategory:coffeeShops nearCoordinate:visit.coordinate completion:^(NSArray *results, NSError *error) {
        for (FoursquareVenue *result in results) {
            UILocalNotification *notif = [[UILocalNotification alloc] init];
            notif.alertBody = [NSString stringWithFormat:@"Near venue: %@", result.name];
            [UIApplication.sharedApplication scheduleLocalNotification:notif];
        }
    }];

}


@end
