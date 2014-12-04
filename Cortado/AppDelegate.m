#import <CocoaPods-Keys/CortadoKeys.h>
@import HealthKit;
#import <Parse/Parse.h>

#import "BeverageProcessor.h"
#import "TodayInterface.h"

#import "AppDelegate.h"

@interface AppDelegate ()

@property (nonatomic, strong) TodayInterface *interface;
@property (nonatomic, strong) BeverageProcessor *processor;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.processor = [[BeverageProcessor alloc] init];
    self.interface = [[TodayInterface alloc] initWithProcessor:self.processor];

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
    }];
}


@end
