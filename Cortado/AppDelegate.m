#import <CocoaPods-Keys/CortadoKeys.h>
#import <Parse/Parse.h>

#import "TodayInterface.h"

#import "AppDelegate.h"

@interface AppDelegate ()

@property (nonatomic, strong) TodayInterface *interface;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.interface = [[TodayInterface alloc] init];

    [application setMinimumBackgroundFetchInterval: UIApplicationBackgroundFetchIntervalMinimum];

    CortadoKeys *keys = [[CortadoKeys alloc] init];
    [Parse setApplicationId:keys.parseAppID
                  clientKey:keys.parseClientKey];

    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil];
    [UIApplication.sharedApplication registerUserNotificationSettings:settings];
    [UIApplication.sharedApplication registerForRemoteNotifications];

    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self.interface stopListening];
    self.interface = nil;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if (!self.interface) {
        self.interface = [[TodayInterface alloc] init];
    }

    [self.interface processAllNewBeveragesWithCompletion:^(NSArray *addedItems) {
        if ([addedItems count] > 0) {
            completionHandler(UIBackgroundFetchResultNewData);
        } else {
            completionHandler(UIBackgroundFetchResultNoData);
        }
        [self.interface stopListening];
    }];
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

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed to register for notifs ================> %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"Received push: %@", userInfo);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"Received BETTER push: %@", userInfo);

    if (!self.interface) {
        self.interface = [[TodayInterface alloc] init];
    }

    [self.interface processAllNewBeveragesWithCompletion:^(NSArray *addedItems) {
        if ([addedItems count] > 0) {
            completionHandler(UIBackgroundFetchResultNewData);
        } else {
            completionHandler(UIBackgroundFetchResultNoData);
        }
        [self.interface stopListening];
    }];
}


@end
